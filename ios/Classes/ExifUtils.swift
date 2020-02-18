// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

// Metadata related links:
// https://developer.apple.com/library/archive/qa/qa1895/_index.html
// https://gist.github.com/nyg/c90f36abbd30f72c8b6681ef23db886b
// https://stackoverflow.com/questions/42860455/get-uiimage-metadata-without-using-uiimagepickercontroller
// https://gist.github.com/osteslag/085b1265fb3c6a23b60c318b15922185
// https://gist.github.com/lacyrhoades/09d8a367125b6225df5038aec68ed9e7

func getPropertiesFromImageData(_ sourceImageData: Data) throws -> NSDictionary? {
    if let imageSource = CGImageSourceCreateWithData(sourceImageData as CFData, nil) {
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
        // log("imageProperties: ", imageProperties)
        return imageProperties
    } else {
        return nil
    }
}

func getMetadataFromImageData(_ sourceImageData: Data) throws -> CGImageMetadata? {
    if let imageSource = CGImageSourceCreateWithData(sourceImageData as CFData, nil) {
        let metadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil)!
        // print("metadata: ", metadata)
        return metadata
    } else {
        return nil
    }
}
