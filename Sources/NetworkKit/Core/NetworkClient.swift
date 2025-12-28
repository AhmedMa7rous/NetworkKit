//
//  NetworkClient.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Main network client implementation
///
/// Coordinates all networking operations including retries, caching,
/// interception, and validation. Follows Clean Architecture principles.
///
/// Example:
/// ```swift
/// let client = NetworkClient(
///     interceptors: [loggingInterceptor, authInterceptor],
///     retrier: DefaultRetryPolicy(),
///     cacheStorage: HybridCacheStorage(),
///     cachePolicy: .hybrid(ttl: 300)
/// )
///
/// let users: [User] = try await client.request(request)
/// ```
public final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private var interceptors: [any RequestInterceptor]
    private let retrier: any RequestRetrier
    private let cacheStorage: (any CacheStorage)?
    private let cachePolicy: NetworkCachePolicy
    
    /// Initialize network client
    ///
    /// - Parameters:
    ///   - session: URLSession to use (default: URLSession.shared)
    ///   - decoder: JSONDecoder for response decoding (default: JSONDecoder())
    ///   - interceptors: Array of request interceptors (default: empty)
    ///   - retrier: Retry policy (default: DefaultRetryPolicy())
    ///   - cacheStorage: Cache storage implementation (default: nil)
    ///   - cachePolicy: Cache policy (default: .never)
    public init(
        session: any URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        interceptors: [any RequestInterceptor] = [],
        retrier: any RequestRetrier = DefaultRetryPolicy(),
        cacheStorage: (any CacheStorage)? = nil,
        cachePolicy: NetworkCachePolicy = .never
    ) {
        self.httpClient = HTTPClient(session: session)
        self.decoder = decoder
        self.interceptors = interceptors
        self.retrier = retrier
        self.cacheStorage = cacheStorage
        self.cachePolicy = cachePolicy
    }
    
    // MARK: - NetworkClientProtocol
    
    public func request<T: Decodable>(_ request: NetworkRequest) async throws -> T {
        let data = try await self.request(request)
        return try decode(data)
    }
    
    public func request(_ request: NetworkRequest) async throws -> Data {
        // Check cache
        if let cachedData = retrieveFromCache(request) {
            return cachedData
        }
        
        // Execute with retry
        let response = try await executeWithRetry(request)
        
        // Store in cache
        storeInCache(response.data, for: request)
        
        return response.data
    }
    
    public func upload(
        _ request: NetworkRequest,
        data: Data,
        progressHandler: (@Sendable (UploadProgress) -> Void)?
    ) async throws -> Data {
        let urlRequest = try await buildURLRequest(from: request)
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = UploadDelegate(progressHandler: progressHandler)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
            
            let task = session.uploadTask(with: urlRequest, from: data) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: self.mapError(error))
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: NetworkError.noData)
                    return
                }
                
                continuation.resume(returning: data)
            }
            
            task.resume()
        }
    }
    
    public func download(
        _ request: NetworkRequest,
        progressHandler: (@Sendable (DownloadProgress) -> Void)?
    ) async throws -> URL {
        let urlRequest = try await buildURLRequest(from: request)
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = DownloadDelegate(progressHandler: progressHandler)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
            
            let task = session.downloadTask(with: urlRequest) { location, response, error in
                if let error = error {
                    continuation.resume(throwing: self.mapError(error))
                    return
                }
                
                guard let location = location else {
                    continuation.resume(throwing: NetworkError.noData)
                    return
                }
                
                do {
                    let destination = try self.moveToDocuments(from: location)
                    continuation.resume(returning: destination)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: - Private Methods
    
    private func executeWithRetry(_ request: NetworkRequest) async throws -> NetworkResponse {
        var attemptCount = 0
        var lastError: (any Error)?
        
        repeat {
            attemptCount += 1
            
            do {
                let urlRequest = try await buildURLRequest(from: request)
                let response = try await httpClient.execute(urlRequest)
                
                await notifyInterceptors(result: .success(response), for: urlRequest)
                
                return response
                
            } catch {
                lastError = error
                
                if let urlRequest = try? await buildURLRequest(from: request) {
                    await notifyInterceptors(result: .failure(error), for: urlRequest)
                }
                
                let shouldRetry = retrier.shouldRetry(
                    request: request,
                    error: error,
                    attemptCount: attemptCount
                )
                
                if shouldRetry {
                    await retrier.delayBeforeRetry(attemptCount: attemptCount)
                    continue
                } else {
                    throw error
                }
            }
        } while true
        
        throw lastError ?? NetworkError.unknown("Request failed")
    }
    
    private func buildURLRequest(from request: NetworkRequest) async throws -> URLRequest {
        guard let url = URL(string: request.url) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = request.timeout
        
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil && request.body != nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Apply interceptors
        var adaptedRequest = urlRequest
        for interceptor in interceptors {
            adaptedRequest = try await interceptor.adapt(adaptedRequest)
        }
        
        return adaptedRequest
    }
    
    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
    
    private func retrieveFromCache(_ request: NetworkRequest) -> Data? {
        guard case .never = cachePolicy else {
            return cacheStorage?.retrieve(forKey: request.cacheKey)
        }
        return nil
    }
    
    private func storeInCache(_ data: Data, for request: NetworkRequest) {
        guard case .never = cachePolicy else {
            cacheStorage?.store(data, forKey: request.cacheKey, ttl: cachePolicy.timeToLive)
            return
        }
    }
    
    private func notifyInterceptors(result: Result<NetworkResponse, any Error>, for request: URLRequest) async {
        for interceptor in interceptors {
            await interceptor.didReceive(result, for: request)
        }
    }
    
    private func mapError(_ error: any Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .cancelled:
                return .cancelled
            default:
                return .unknown(urlError.localizedDescription)
            }
        }
        return .unknown(error.localizedDescription)
    }
    
    private func moveToDocuments(from location: URL) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination = documentsPath.appendingPathComponent(UUID().uuidString)
        
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: location, to: destination)
        
        return destination
    }
}

// MARK: - Upload Delegate
private final class UploadDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let progressHandler: (@Sendable (UploadProgress) -> Void)?
    
    init(progressHandler: (@Sendable (UploadProgress) -> Void)?) {
        self.progressHandler = progressHandler
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        let progress = UploadProgress(
            bytesWritten: bytesSent,
            totalBytesWritten: totalBytesSent,
            totalBytesExpectedToWrite: totalBytesExpectedToSend
        )
        
        DispatchQueue.main.async {
            self.progressHandler?(progress)
        }
    }
}

// MARK: - Download Delegate
private final class DownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private let progressHandler: (@Sendable (DownloadProgress) -> Void)?
    
    init(progressHandler: (@Sendable (DownloadProgress) -> Void)?) {
        self.progressHandler = progressHandler
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let progress = DownloadProgress(
            bytesWritten: bytesWritten,
            totalBytesWritten: totalBytesWritten,
            totalBytesExpectedToWrite: totalBytesExpectedToWrite
        )
        
        DispatchQueue.main.async {
            self.progressHandler?(progress)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Handled in completion
    }
}
