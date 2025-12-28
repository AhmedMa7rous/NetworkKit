//
//  LoggingInterceptor.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation
import os.log

/// Logs network requests and responses
///
/// Provides configurable logging for debugging network issues.
///
/// Example:
/// ```swift
/// let logger = LoggingInterceptor(level: .detailed)
///
/// let client = NetworkClient(
///     interceptors: [logger]
/// )
/// ```
public final class LoggingInterceptor: RequestInterceptor, @unchecked Sendable {
    private let logger: Logger
    private let level: LogLevel
    
    /// Logging verbosity level
    public enum LogLevel: Sendable {
        /// No logging
        case none
        
        /// Log only request method and URL
        case basic
        
        /// Log full request and response details
        case detailed
    }
    
    /// Initialize logging interceptor
    ///
    /// - Parameter level: Logging level (default: .basic)
    public init(level: LogLevel = .basic) {
        self.logger = Logger(subsystem: "com.networkkit", category: "Network")
        self.level = level
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard level != .none else { return request }
        
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "UNKNOWN"
        
        logger.info("➡️ \(method) \(url)")
        
        if level == .detailed {
            logHeaders(request.allHTTPHeaderFields)
            logBody(request.httpBody)
        }
        
        return request
    }
    
    public func didReceive(_ result: Result<NetworkResponse, Error>, for request: URLRequest) async {
        guard level != .none else { return }
        
        let url = request.url?.absoluteString ?? "UNKNOWN"
        
        switch result {
        case .success(let response):
            logger.info("✅ \(response.statusCode) \(url)")
            if level == .detailed {
                logResponseData(response.data)
            }
            
        case .failure(let error):
            logger.error("❌ \(url): \(error.localizedDescription)")
        }
    }
    
    private func logHeaders(_ headers: [String: String]?) {
        guard let headers = headers, !headers.isEmpty else { return }
        logger.debug("Headers: \(String(describing: headers))")
    }
    
    private func logBody(_ body: Data?) {
        guard let body = body,
              let bodyString = String(data: body, encoding: .utf8) else { return }
        logger.debug("Body: \(bodyString)")
    }
    
    private func logResponseData(_ data: Data) {
        guard let responseString = String(data: data, encoding: .utf8) else { return }
        logger.debug("Response: \(responseString)")
    }
}
