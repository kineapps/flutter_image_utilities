// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

package com.kineapps.flutter_image_utilities

import android.media.ExifInterface
import android.util.Log

fun copyExifData(sourceFilePath: String, destinationFilePath: String) {
    try {
        val oldExif = ExifInterface(sourceFilePath)
        val newExif = ExifInterface(destinationFilePath)

        for (tag in exifTags) {
            val oldAttribute = oldExif.getAttribute(tag)
            if (oldAttribute != null) {
                newExif.setAttribute(tag, oldAttribute)
            }
        }

        newExif.saveAttributes()
    } catch (ex: Exception) {
        Log.e("copyExifData", "Error copying Exif data: $ex")
    }

}

private val exifTags = listOf(
        "FNumber",
        "ExposureTime",
        "ISOSpeedRatings",
        "GPSAltitude",
        "GPSAltitudeRef",
        "FocalLength",
        "GPSDateStamp",
        "WhiteBalance",
        "GPSProcessingMethod",
        "GPSTimeStamp",
        "DateTime",
        "Flash",
        "GPSLatitude",
        "GPSLatitudeRef",
        "GPSLongitude",
        "GPSLongitudeRef",
        "Make",
        "Model",
        "Orientation")
