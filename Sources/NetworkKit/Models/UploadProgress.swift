//
//  UploadProgress.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Represents upload progress information
///
/// Provides real-time feedback during file uploads.
///
/// Example:
/// ```swift
/// try await client.upload(request, data: fileData) { progress in
///     print("Upload: \(progress.percentage)%")
///     print("Uploaded: \(progress.totalBytesWritten) bytes")
/// }
/// ```
public struct UploadProgress: Sendable {
    /// Bytes written in current chunk
    public let bytesWritten: Int64
    
    /// Total bytes written so far
    public let totalBytesWritten: Int64
    
    /// Total bytes expected to write
    public let totalBytesExpectedToWrite: Int64
    
    /// Progress as fraction (0.0 to 1.0)
    public var fractionCompleted: Double {
        guard totalBytesExpectedToWrite > 0 else { return 0.0 }
        return Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    }
    
    /// Progress as percentage (0 to 100)
    public var percentage: Int {
        Int(fractionCompleted * 100)
    }
    
    /// Creates upload progress information
    ///
    /// - Parameters:
    ///   - bytesWritten: Bytes written in current chunk
    ///   - totalBytesWritten: Total bytes written so far
    ///   - totalBytesExpectedToWrite: Total bytes expected
    public init(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.bytesWritten = bytesWritten
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
    }
}
