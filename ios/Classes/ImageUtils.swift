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
    var width: Int?
    var height: Int?
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
    canScaleUp: Bool
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
        canScaleUp: canScaleUp,
        properties: sourceImageProperties
    )

    // Uncomment to see written metadata
    // let destImageData = try Data(contentsOf: (URL(fileURLWithPath: destinationImageFile.path)))
    // let destMetadata = try getMetadataFromImageData(destImageData)

    return file
}

extension UIImage {
    func saveAsJpeg(
        destinationFile: URL, imageQuality: Double, maxSize: Size, canScaleUp: Bool, properties: NSDictionary?
    ) throws -> URL? {
        let currentSize = Size(width: Int(size.width), height: Int(size.height))

        let scaleFactor = getScaleFactor(currentSize, maxSize)
      
        if scaleFactor < 1 || (scaleFactor > 1 && canScaleUp) {
            let destinationWidth = Double(currentSize.width!) * scaleFactor
            let destinationHeight = Double(currentSize.height!) * scaleFactor
            log("Saving image to \(destinationFile.path), quality=\(imageQuality), width=\(destinationWidth), height=\(destinationHeight)")
            UIGraphicsBeginImageContextWithOptions(CGSize(width: destinationWidth, height: destinationHeight), true, 1)
            draw(in: CGRect(x: 0, y: 0, width: destinationWidth, height: destinationHeight))
            let scaledBmp = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return try scaledBmp.saveAsJpeg(destinationFile: destinationFile, imageQuality: imageQuality, properties: properties)
        } else {
            log("Saving image to \(destinationFile.path), quality=\(imageQuality), keep original size width=\(currentSize.width), height=\(currentSize.height)")
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

func getScaleFactor(_ sourceSize: Size, _ targetSize: Size) -> Double {
    // e.g. source 1920*1080, target 1024*768 => 0.533, 0.711 => 0.533 => 1023 * 576
    // e.g. source 1024*768, target 1920*1080 => 1.875, 1.406 => 1.406 => 1440 * 1080
    let ratioX: Double = Double(targetSize.width ?? Int.max) / Double(sourceSize.width!)
    let ratioY: Double = Double(targetSize.height ?? Int.max) / Double(sourceSize.height!)
    return min(ratioX, ratioY)
}
