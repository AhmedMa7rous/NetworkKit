//
//  Encodable+Extensions.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//
import Foundation

public extension Encodable {
    /// Encode to JSON Data
    ///
    /// - Parameter encoder: JSONEncoder to use (default: JSONEncoder())
    /// - Returns: Encoded JSON data
    /// - Throws: NetworkError.encodingFailed if encoding fails
    ///
    /// Example:
    /// ```swift
    /// struct User: Encodable {
    ///     let name: String
    ///     let email: String
    /// }
    ///
    /// let user = User(name: "John", email: "john@example.com")
    /// let data = try user.toJSONData()
    /// ```
    func toJSONData(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        do {
            return try encoder.encode(self)
        } catch {
            throw NetworkError.encodingFailed(error.localizedDescription)
        }
    }
    
    /// Encode to pretty-printed JSON string
    ///
    /// Useful for debugging and logging.
    ///
    /// - Parameter encoder: JSONEncoder to use (default: pretty-printing encoder)
    /// - Returns: Formatted JSON string
    /// - Throws: NetworkError.encodingFailed if encoding fails
    ///
    /// Example:
    /// ```swift
    /// let jsonString = try user.toJSONString()
    /// print(jsonString)
    /// // {
    /// //   "name": "John",
    /// //   "email": "john@example.com"
    /// // }
    /// ```
    func toJSONString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        encoder.outputFormatting = .prettyPrinted
        let data = try toJSONData(encoder: encoder)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
