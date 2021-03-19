// Copyright (c) 2021 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

package com.kineapps.flutter_image_utilities

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.util.*
import kotlin.math.min

private const val logTag = "ImageUtils"

data class Size(val width: Int?, val height: Int?)

/**
 * Save [sourceImagePath] to [destinationImagePath] as JPEG using specified [imageQuality]
 * 1-100, [maxWidth], [maxHeight].
 *
 * If [canScaleUp] is true and image is too small, scale it up.
 *
 * Saves JPEG to a temporary file if [destinationImagePath] is not specified.
 *
 * Returns the saved file. Throws exception on error.
 */
internal fun saveImageFileAsJpeg(
        sourceImagePath: String,
        destinationImagePath: String?,
        imageQuality: Int?,
        maxWidth: Int?,
        maxHeight: Int?,
        canScaleUp: Boolean,
        cacheDir: File
): File? {
    Log.d(logTag, "sourceImagePath=${sourceImagePath}, destinationImagePath=${destinationImagePath}," +
            " imageQuality=$imageQuality, maxWidth=${maxWidth}, maxHeight=${maxHeight}, canScaleUp=${canScaleUp}")

    // get destination file
    val destinationImageFile = if (destinationImagePath.isNullOrBlank()) {
        val timestamp =
                android.text.format.DateFormat.format("yyyyMMddhhmmss", Date()).toString()
        File(cacheDir, "$timestamp.jpg")
    } else {
        File(destinationImagePath)
    }

    // delete existing destination file
    if (destinationImageFile.exists()) {
        destinationImageFile.delete()
    }

    val quality =
            if (imageQuality == null || imageQuality < 1 || imageQuality > 100) {
                100
            } else {
                imageQuality
            }

    val bmp = BitmapFactory.decodeFile(sourceImagePath) ?: return null
    val file = saveBitmapToFile(
            bmp, destinationImageFile, quality, Size(maxWidth, maxHeight), canScaleUp)
    copyExifData(sourceImagePath, file.path)
    return file
}

private fun saveBitmapToFile(
        sourceBitmap: Bitmap, destinationFile: File, imageQuality: Int, maxSize: Size, canScaleUp: Boolean): File {

    val sourceSize = Size(sourceBitmap.width, sourceBitmap.height)

    val scaleFactor = getScaleFactor(sourceSize, maxSize)

    if (scaleFactor < 1 || (scaleFactor > 1 && canScaleUp)) {
        val destinationSize = Size((sourceSize.width!!.toDouble() * scaleFactor).toInt(),
                (sourceSize.height!!.toDouble() * scaleFactor).toInt())
        Log.d(logTag, "Saving image to ${destinationFile.path}, " +
                "quality=$imageQuality, " +
                "width=${destinationSize.width}, height=${destinationSize.height}")
        val scaledBmp =
                Bitmap.createScaledBitmap(
                        sourceBitmap, destinationSize.width!!.toInt(), destinationSize.height!!.toInt(), false)
        return saveBitmapToFile(scaledBmp, destinationFile, imageQuality)
    } else {
        Log.d(logTag, "Saving image to ${destinationFile.path}, " +
                "quality=$imageQuality, " +
                "keep original size width=${sourceSize.width}, height=${sourceSize.height}")
        return saveBitmapToFile(sourceBitmap, destinationFile, imageQuality)
    }
}

private fun saveBitmapToFile(bitmap: Bitmap, destinationFile: File, imageQuality: Int): File {
    FileOutputStream(destinationFile).use { fileStream ->
        bitmap.compress(
                Bitmap.CompressFormat.JPEG,
                imageQuality,
                fileStream)
    }
    return destinationFile
}

internal fun getScaleFactor(sourceSize: Size, targetSize: Size): Double {
    // e.g. source 1920*1080, target 1024*768 => 0.533, 0.711 => 0.533 => 1023 * 576
    // e.g. source 1024*768, target 1920*1080 => 1.875, 1.406 => 1.406 => 1440 * 1080
    val ratioX = (targetSize.width?.toDouble() ?: Double.MAX_VALUE) / sourceSize.width!!.toDouble()
    val ratioY = (targetSize.height?.toDouble() ?: Double.MAX_VALUE) / sourceSize.height!!.toDouble()
    return min(ratioX, ratioY)
}
