// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import AVFoundation
import Foundation
import UIKit

// https://developer.apple.com/documentation/avfoundation/avfiletype/2873427-jpg
struct Constants {
    static let jpegUtiType: CFString = "public.jpeg" as CFString
}

struct Size {
    var width: Int
    var height: Int
}

enum ScaleMode: String {
    case FitKeepAspectRatio
    case FillKeepAspectRatio
    case FitAnyDirectionKeepAspectRatio
    case FillAnyDirectionKeepAspectRatio
}

/**
 * Save [sourceImagePath] to [destinationImagePath] as JPEG using specified [imageQuality]
 * 1-100, [maxWidth], [maxHeight] and [scaleMode].
 *
 * Saves JPEG to a temporary file if [destinationImagePath] is not specified.
 *
 * Returns the saved file. Throws exception on error.
 */
func saveImageFileAsJpeg(
    sourceImagePath: String,
    destinationImagePath: String?,
    imageQuality: Int?,
    maxWidth: Int?,
    maxHeight: Int?,
    scaleMode: ScaleMode?
) throws -> URL? {
    // get destination file
    let destinationImageFile: URL
    if destinationImagePath == nil || destinationImagePath!.isEmpty {
        let directory = NSTemporaryDirectory()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        let fileName = dateFormatter.string(from: Date()) + ".jpg"

        destinationImageFile = NSURL.fileURL(withPathComponents: [directory, fileName])!
    } else {
        destinationImageFile = URL(fileURLWithPath: destinationImagePath!)
    }

    // delete existing destination file
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: destinationImageFile.path) {
        try fileManager.removeItem(atPath: destinationImageFile.path)
    }

    // get quality 0-1
    let quality = (imageQuality == nil || imageQuality! < 1 || imageQuality! > 100) ? 1 : Double(imageQuality!) / 100.0

    // get source image
    let sourceImageData = try Data(contentsOf: URL(fileURLWithPath: sourceImagePath))
    let sourceImage = UIImage(data: sourceImageData)

    // get source metadata
    let sourceImageProperties = try getPropertiesFromImageData(sourceImageData)

    // save scaled and compressed image to destination file with the original metadata
    let file = try sourceImage!.saveAsJpeg(
        destinationFile: destinationImageFile,
        imageQuality: quality,
        maxSize: Size(width: maxWidth!, height: maxHeight!),
        scaleMode: scaleMode ?? ScaleMode.FitAnyDirectionKeepAspectRatio,
        properties: sourceImageProperties
    )

    // Uncomment to see written metadata
    // let destImageData = try Data(contentsOf: (URL(fileURLWithPath: destinationImageFile.path)))
    // let destMetadata = try getMetadataFromImageData(destImageData)

    return file
}

extension UIImage {
    func saveAsJpeg(
        destinationFile: URL, imageQuality: Double, maxSize: Size, scaleMode: ScaleMode, properties: NSDictionary?
    ) throws -> URL? {
        let currentSize = Size(width: Int(size.width), height: Int(size.height))
        let destinationSize = getDownScaledSize(originalSize: currentSize, maxSize: maxSize, scaleMode: scaleMode)

        log("Saving image to \(destinationFile.path), quality=\(imageQuality), width=\(destinationSize.width), height=\(destinationSize.height)")
        if destinationSize.width != currentSize.width || destinationSize.height != currentSize.height {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: destinationSize.width, height: destinationSize.height), true, 1)
            draw(in: CGRect(x: 0, y: 0, width: destinationSize.width, height: destinationSize.height))
            let scaledBmp = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return try scaledBmp.saveAsJpeg(destinationFile: destinationFile, imageQuality: imageQuality, properties: properties)
        } else {
            return try saveAsJpeg(destinationFile: destinationFile, imageQuality: imageQuality, properties: properties)
        }
    }

    func saveAsJpeg(destinationFile: URL, imageQuality: Double, properties: NSDictionary?) throws -> URL? {
        if properties != nil {
            let data = NSMutableData()
            let dest = CGImageDestinationCreateWithData(data, Constants.jpegUtiType, 1, nil)!

            let options: NSMutableDictionary = NSMutableDictionary(dictionary: properties!)
            options[kCGImageDestinationLossyCompressionQuality] = imageQuality

            CGImageDestinationAddImage(dest, cgImage!, options)
            CGImageDestinationFinalize(dest)

            try data.write(to: destinationFile)
        } else {
            let jpeg = jpegData(compressionQuality: CGFloat(imageQuality))!
            try jpeg.write(to: destinationFile)
        }
        return destinationFile
    }
}

func updateJpegFileMetadata(file: URL, metadata: CGImageMetadata) throws {
    // https://developer.apple.com/library/archive/qa/qa1895/_index.html

    let src = CGImageSourceCreateWithURL(file as CFURL, nil)

    let data = NSMutableData()
    let dest = CGImageDestinationCreateWithData(data, Constants.jpegUtiType, 1, nil)!

    let destOptions: [String: AnyObject] = [
        kCGImageDestinationMergeMetadata as String: NSNumber(value: 1),
        kCGImageDestinationMetadata as String: metadata
    ]

    let cfDestOptions = destOptions as CFDictionary

    var error: Unmanaged<CFError>?
    withUnsafeMutablePointer(to: &error) {
        errorPtr in
        let result = CGImageDestinationCopyImageSource(dest, src!, cfDestOptions, errorPtr)
        log(String(format: "Write image to file result: %@", result ? "Success" : "Failed"))
    }
    try data.write(to: file)
}

/**
 * Scale down [originalSize] to [maxSize] using [scaleMode]. If [originalSize] is
 * already smaller than [maxSize], return [originalSize].
 */
func getDownScaledSize(originalSize: Size, maxSize: Size, scaleMode: ScaleMode) -> Size {
    switch scaleMode {
    case ScaleMode.FitAnyDirectionKeepAspectRatio,
         ScaleMode.FillAnyDirectionKeepAspectRatio:
        return getDownScaledSizeAnyDirection(originalSize, maxSize, scaleMode)
    default:
        return getDownScaledSizeFixedDirection(originalSize, maxSize, scaleMode)
    }
}

func getDownScaledSizeAnyDirection(_ originalSize: Size, _ maxSize: Size, _ scaleMode: ScaleMode) -> Size {
    let originalWidth = Double(originalSize.width)
    let originalHeight = Double(originalSize.height)

    let originalLongerSideLength = max(originalWidth, originalHeight)
    let originalShorterSideLength = min(originalWidth, originalHeight)

    let minLongerSideLength = Double(max(maxSize.width, maxSize.height))
    let minShorterSideLength = Double(min(maxSize.width, maxSize.height))
    if originalLongerSideLength > minLongerSideLength,
        originalShorterSideLength > minShorterSideLength {
        // Max size in samples is 1920x1080
        // scale factor for the longer side
        // e.g. 1920 / 3264 = 0,58823529
        let longerSideScaleFactor: Double =
            minLongerSideLength / originalLongerSideLength

        // scale factor for the shorter side
        // e.g. 1080 / 2448 = 0,44117647
        let shorterSideScaleFactor: Double =
            minShorterSideLength / originalShorterSideLength

        // Fill: use larger of the two scale factors to achieve the requested
        // minimum width and height
        // Example (fill):
        //  0,58823529 * 3264 = 1920
        //  0,58823529 * 2448 = 1440

        // Fit: use smaller of the two scale factors to achieve the requested
        // maximum width and height
        // Example (fit):
        //  0,44117647 * 3264 = 1440
        //  0,44117647 * 2448 = 1080
        let scaleFactor: Double
        switch scaleMode {
        case ScaleMode.FillAnyDirectionKeepAspectRatio:
            scaleFactor = max(longerSideScaleFactor, shorterSideScaleFactor)
        case ScaleMode.FitAnyDirectionKeepAspectRatio:
            scaleFactor = min(longerSideScaleFactor, shorterSideScaleFactor)
        default:
            scaleFactor = 1
        }

        // calculate target size
        let targetWidth = scaleFactor * originalWidth
        let targetHeight = scaleFactor * originalHeight

        return Size(width: Int(targetWidth), height: Int(targetHeight))
    } else {
        return originalSize
    }
}

/**
 * Scale down [originalSize] to [maxSize] using [scaleMode]. If [originalSize] is
 * already smaller than [maxSize], return [originalSize].
 */
func getDownScaledSizeFixedDirection(_ originalSize: Size, _ maxSize: Size, _ scaleMode: ScaleMode) -> Size {
    let originalWidth = originalSize.width
    let originalHeight = originalSize.height
    if originalWidth > maxSize.width || originalHeight > maxSize.height {
        // Max size in samples is 1920x1080
        // scale factor for the width
        // e.g. 1920 / 3264 = 0,58823529
        let scaleFactorX: Double = Double(maxSize.width) / Double(originalWidth)

        // scale factor for the height
        // e.g. 1080 / 2448 = 0,44117647
        let scaleFactorY: Double = Double(maxSize.height) / Double(originalHeight)

        // Fill: use larger of the two scale factors to achieve the requested
        // minimum width and height
        // Example (fill):
        //  0,58823529 * 3264 = 1920
        //  0,58823529 * 2448 = 1440

        // Fit: use smaller of the two scale factors to achieve the requested
        // maximum width and height
        // Example (fit):
        //  0,44117647 * 3264 = 1440
        //  0,44117647 * 2448 = 1080
        let scaleFactor: Double
        switch scaleMode {
        case ScaleMode.FillKeepAspectRatio:
            scaleFactor = max(scaleFactorX, scaleFactorY)
        case ScaleMode.FitKeepAspectRatio:
            scaleFactor = min(scaleFactorX, scaleFactorY)
        default:
            scaleFactor = 1
        }
        // calculate target size
        let targetWidth = scaleFactor * Double(originalWidth)
        let targetHeight = scaleFactor * Double(originalHeight)

        return Size(width: Int(targetWidth), height: Int(targetHeight))
    } else {
        return originalSize
    }
}
