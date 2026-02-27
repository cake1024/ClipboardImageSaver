// ImageSaveHelper.swift
// ClipboardImageSaver
//
// SPDX-License-Identifier: MIT

import AppKit
import UniformTypeIdentifiers

/// Errors that can occur when saving an image to disk.
enum ImageSaveError: LocalizedError {
    case noImageData
    case conversionFailed(String)
    case writeFailed(String)

    var errorDescription: String? {
        switch self {
        case .noImageData:
            return "Could not extract image data."
        case .conversionFailed(let format):
            return "Failed to convert image to \(format) format."
        case .writeFailed(let path):
            return "Failed to write image to \(path)."
        }
    }
}

/// Handles presenting the save dialog, converting images between formats,
/// and persisting the last-used save directory.
struct ImageSaveHelper {

    // MARK: - User Defaults Keys

    private static let lastDirectoryKey = "LastSaveDirectory"

    // MARK: - Supported Formats

    /// A supported image output format.
    struct ImageFormat {
        let name: String
        let utType: UTType
        let bitmapType: NSBitmapImageRep.FileType
        let fileExtension: String
    }

    static let supportedFormats: [ImageFormat] = [
        ImageFormat(name: "PNG",  utType: .png,  bitmapType: .png,  fileExtension: "png"),
        ImageFormat(name: "JPEG", utType: .jpeg, bitmapType: .jpeg, fileExtension: "jpg"),
        ImageFormat(name: "TIFF", utType: .tiff, bitmapType: .tiff, fileExtension: "tiff"),
        ImageFormat(name: "GIF",  utType: .gif,  bitmapType: .gif,  fileExtension: "gif"),
    ]

    // MARK: - Save Dialog

    /// Presents an `NSSavePanel` for the given image.
    ///
    /// The panel offers format selection (PNG, JPEG, TIFF, GIF), generates a
    /// timestamped default filename, and remembers the last save directory.
    ///
    /// - Parameter image: The image to save.
    /// - Throws: ``ImageSaveError`` if conversion or writing fails.
    @MainActor
    static func showSaveDialog(for image: NSImage) throws {
        let panel = NSSavePanel()
        panel.title = "Save Clipboard Image"
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.showsTagField = true

        // Set allowed file types
        panel.allowedContentTypes = supportedFormats.map { $0.utType }

        // Generate default filename with timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = formatter.string(from: Date())
        panel.nameFieldStringValue = "clipboard-\(timestamp).png"

        // Restore last used directory
        if let lastDir = UserDefaults.standard.string(forKey: lastDirectoryKey) {
            let url = URL(fileURLWithPath: lastDir)
            if FileManager.default.fileExists(atPath: lastDir) {
                panel.directoryURL = url
            }
        }

        // Show the panel
        let response = panel.runModal()
        guard response == .OK, let url = panel.url else {
            return // User cancelled
        }

        // Remember the directory
        UserDefaults.standard.set(url.deletingLastPathComponent().path, forKey: lastDirectoryKey)

        // Determine format from file extension
        let ext = url.pathExtension.lowercased()
        let format = supportedFormats.first { $0.fileExtension == ext }
            ?? supportedFormats[0] // Default to PNG

        // Save the image
        try saveImage(image, to: url, format: format)
    }

    // MARK: - Image Conversion & Write

    /// Converts an `NSImage` to the specified format and writes it to disk.
    ///
    /// - Parameters:
    ///   - image: The source image.
    ///   - url: The destination file URL.
    ///   - format: The target image format.
    /// - Throws: ``ImageSaveError`` if the image data cannot be extracted,
    ///   converted, or written.
    static func saveImage(_ image: NSImage, to url: URL, format: ImageFormat) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            throw ImageSaveError.noImageData
        }

        // For JPEG, set compression quality
        var properties: [NSBitmapImageRep.PropertyKey: Any] = [:]
        if format.bitmapType == .jpeg {
            properties[.compressionFactor] = 0.9
        }

        guard let data = bitmapRep.representation(using: format.bitmapType, properties: properties) else {
            throw ImageSaveError.conversionFailed(format.name)
        }

        do {
            try data.write(to: url)
        } catch {
            throw ImageSaveError.writeFailed(url.path)
        }
    }
}
