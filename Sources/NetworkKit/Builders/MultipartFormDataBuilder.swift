//
//  MultipartFormDataBuilder.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Builder for constructing multipart/form-data bodies
///
/// Used to build multipart form data for file uploads with additional fields.
///
/// Example:
/// ```swift
/// let builder = MultipartFormDataBuilder()
///     .addTextField(named: "userId", value: "123")
///     .addDataField(
///         named: "file",
///         data: fileData,
///         mimeType: "application/pdf",
///         filename: "document.pdf"
///     )
///
/// let data = builder.build()
/// ```
public final class MultipartFormDataBuilder {
    /// Boundary string for separating form parts
    public let boundary: String
    
    private var bodyParts: [Data] = []
    
    /// Initialize with optional custom boundary
    ///
    /// - Parameter boundary: Custom boundary string (default: auto-generated)
    public init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
    }
    
    /// Add a text field to the form
    ///
    /// - Parameters:
    ///   - name: Field name
    ///   - value: Field value
    /// - Returns: Self for chaining
    ///
    /// Example:
    /// ```swift
    /// builder.addTextField(named: "username", value: "john_doe")
    /// ```
    @discardableResult
    public func addTextField(named name: String, value: String) -> Self {
        var fieldData = Data()
        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        fieldData.append("\(value)\r\n")
        bodyParts.append(fieldData)
        return self
    }
    
    /// Add a data field (file) to the form
    ///
    /// - Parameters:
    ///   - name: Field name
    ///   - data: File data
    ///   - mimeType: MIME type of the file
    ///   - filename: Filename to use
    /// - Returns: Self for chaining
    ///
    /// Example:
    /// ```swift
    /// builder.addDataField(
    ///     named: "avatar",
    ///     data: imageData,
    ///     mimeType: "image/jpeg",
    ///     filename: "avatar.jpg"
    /// )
    /// ```
    @discardableResult
    public func addDataField(
        named name: String,
        data: Data,
        mimeType: String,
        filename: String
    ) -> Self {
        var fieldData = Data()
        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")
        bodyParts.append(fieldData)
        return self
    }
    
    /// Build the final multipart form data
    ///
    /// - Returns: Complete multipart form data
    public func build() -> Data {
        var body = Data()
        
        for part in bodyParts {
            body.append(part)
        }
        
        body.append("--\(boundary)--\r\n")
        
        return body
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
