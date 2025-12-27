//
//  NetworkClientProtocol.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Main protocol for network operations
///
/// Defines the contract for making network requests with support for
/// automatic decoding, raw data retrieval, uploads, and downloads.
///
/// Conformance to `Sendable` ensures thread-safety.
///
/// Example:
/// ```swift
/// let client: NetworkClientProtocol = NetworkClient()
/// let users: [User] = try await client.request(request)
/// ```
public protocol NetworkClientProtocol: Sendable {
    /// Perform a request and decode the response
    ///
    /// Automatically decodes the JSON response into the specified type.
    ///
    /// - Parameters:
    ///   - request: The network request to execute
    /// - Returns: Decoded response of type T
    /// - Throws: `NetworkError` if request fails or decoding fails
    ///
    /// Example:
    /// ```swift
    /// let request = NetworkRequestBuilder(url: "https://api.example.com/users")
    ///     .method(.get)
    ///     .build()
    ///
    /// let users: [User] = try await client.request(request)
    /// ```
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> T
    
    /// Perform a request and return raw data
    ///
    /// Returns the raw response data without decoding.
    ///
    /// - Parameters:
    ///   - request: The network request to execute
    /// - Returns: Raw response data
    /// - Throws: `NetworkError` if request fails
    ///
    /// Example:
    /// ```swift
    /// let data = try await client.request(request)
    /// ```
    func request(_ request: NetworkRequest) async throws -> Data
    
    /// Upload data with progress tracking
    ///
    /// Uploads data to the server with optional progress callbacks.
    ///
    /// - Parameters:
    ///   - request: The network request to execute
    ///   - data: Data to upload
    ///   - progressHandler: Optional closure called with upload progress
    /// - Returns: Response data from server
    /// - Throws: `NetworkError` if upload fails
    ///
    /// Example:
    /// ```swift
    /// let imageData = image.jpegData(compressionQuality: 0.8)!
    /// let response = try await client.upload(request, data: imageData) { progress in
    ///     print("Uploaded: \(progress.percentage)%")
    /// }
    /// ```
    func upload(
        _ request: NetworkRequest,
        data: Data,
        progressHandler: (@Sendable (UploadProgress) -> Void)?
    ) async throws -> Data
    
    /// Download file with progress tracking
    ///
    /// Downloads a file to local storage with optional progress callbacks.
    ///
    /// - Parameters:
    ///   - request: The network request to execute
    ///   - progressHandler: Optional closure called with download progress
    /// - Returns: URL of the downloaded file in Documents directory
    /// - Throws: `NetworkError` if download fails
    ///
    /// Example:
    /// ```swift
    /// let fileURL = try await client.download(request) { progress in
    ///     print("Downloaded: \(progress.percentage)%")
    /// }
    /// ```
    func download(
        _ request: NetworkRequest,
        progressHandler: (@Sendable (DownloadProgress) -> Void)?
    ) async throws -> URL
}
