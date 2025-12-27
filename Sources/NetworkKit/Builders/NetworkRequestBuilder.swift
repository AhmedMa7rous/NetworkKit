//
//  NetworkRequestBuilder.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Builder for constructing NetworkRequest instances
///
/// Provides a fluent API for building network requests with various
/// encoding options (JSON, form URL encoded, multipart form data).
///
/// Example:
/// ```swift
/// let request = try NetworkRequestBuilder(url: "https://api.example.com/users")
///     .method(.post)
///     .header(key: "Authorization", value: "Bearer token")
///     .jsonBody(userData)
///     .timeout(60)
///     .build()
/// ```
public final class NetworkRequestBuilder {
    private var url: String
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var timeout: TimeInterval = 30
    private var body: Data?
    
    /// Initialize builder with URL
    ///
    /// - Parameter url: The URL string for the request
    public init(url: String) {
        self.url = url
    }
    
    /// Set HTTP method
    ///
    /// - Parameter method: HTTP method to use
    /// - Returns: Self for chaining
    @discardableResult
    public func method(_ method: HTTPMethod) -> Self {
        self.method = method
        return self
    }
    
    /// Set multiple headers at once
    ///
    /// - Parameter headers: Dictionary of headers
    /// - Returns: Self for chaining
    @discardableResult
    public func headers(_ headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }
    
    /// Add a single header
    ///
    /// - Parameters:
    ///   - key: Header field name
    ///   - value: Header field value
    /// - Returns: Self for chaining
    @discardableResult
    public func header(key: String, value: String) -> Self {
        self.headers[key] = value
        return self
    }
    
    /// Set request timeout
    ///
    /// - Parameter timeout: Timeout interval in seconds
    /// - Returns: Self for chaining
    @discardableResult
    public func timeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }
    
    /// Set raw body data
    ///
    /// - Parameter data: Raw body data
    /// - Returns: Self for chaining
    @discardableResult
    public func body(_ data: Data) -> Self {
        self.body = data
        return self
    }
    
    /// Set JSON-encoded body
    ///
    /// Encodes the provided value as JSON and sets appropriate headers.
    ///
    /// - Parameters:
    ///   - value: Encodable value to encode as JSON
    ///   - encoder: JSONEncoder to use (default: JSONEncoder())
    /// - Returns: Self for chaining
    /// - Throws: EncodingError if encoding fails
    ///
    /// Example:
    /// ```swift
    /// struct User: Encodable {
    ///     let name: String
    ///     let email: String
    /// }
    ///
    /// let user = User(name: "John", email: "john@example.com")
    /// try builder.jsonBody(user)
    /// ```
    @discardableResult
    public func jsonBody<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) throws -> Self {
        self.body = try encoder.encode(value)
        self.headers["Content-Type"] = "application/json"
        return self
    }
    
    /// Add query parameters to URL
    ///
    /// Appends query parameters to the URL string.
    ///
    /// - Parameter parameters: Dictionary of query parameters
    /// - Returns: Self for chaining
    ///
    /// Example:
    /// ```swift
    /// builder.queryParameters(["page": "1", "limit": "10"])
    /// // Results in: https://api.example.com/users?limit=10&page=1
    /// ```
    @discardableResult
    public func queryParameters(_ parameters: [String: String]) -> Self {
        guard !parameters.isEmpty else { return self }
        
        guard var components = URLComponents(string: url) else {
            return self
        }
        
        components.queryItems = parameters.sorted(by: { $0.key < $1.key }).map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        if let newURL = components.url?.absoluteString {
            self.url = newURL
        }
        
        return self
    }
    
    /// Set form URL encoded body
    ///
    /// Encodes parameters as application/x-www-form-urlencoded.
    ///
    /// - Parameter parameters: Form parameters
    /// - Returns: Self for chaining
    ///
    /// Example:
    /// ```swift
    /// builder.formURLEncoded([
    ///     "username": "john",
    ///     "password": "secret"
    /// ])
    /// ```
    @discardableResult
    public func formURLEncoded(_ parameters: [String: String]) -> Self {
        let encodedString = parameters
            .sorted(by: { $0.key < $1.key })
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
        
        self.body = encodedString.data(using: .utf8)
        self.headers["Content-Type"] = "application/x-www-form-urlencoded"
        return self
    }
    
    /// Set multipart form data body
    ///
    /// Uses MultipartFormDataBuilder to construct multipart/form-data body.
    ///
    /// - Parameter builder: Closure that configures the multipart builder
    /// - Returns: Self for chaining
    ///
    /// Example:
    /// ```swift
    /// builder.multipartFormData { multipart in
    ///     multipart
    ///         .addTextField(named: "name", value: "John")
    ///         .addDataField(
    ///             named: "avatar",
    ///             data: imageData,
    ///             mimeType: "image/jpeg",
    ///             filename: "avatar.jpg"
    ///         )
    /// }
    /// ```
    @discardableResult
    public func multipartFormData(_ builder: (MultipartFormDataBuilder) -> Void) -> Self {
        let multipartBuilder = MultipartFormDataBuilder()
        builder(multipartBuilder)
        
        self.body = multipartBuilder.build()
        self.headers["Content-Type"] = "multipart/form-data; boundary=\(multipartBuilder.boundary)"
        return self
    }
    
    /// Build the final NetworkRequest
    ///
    /// - Returns: Configured NetworkRequest instance
    public func build() -> NetworkRequest {
        return NetworkRequest(
            url: url,
            method: method,
            headers: headers,
            body: body,
            timeout: timeout
        )
    }
}
