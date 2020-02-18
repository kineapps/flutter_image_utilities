// Copyright (c) 2020 KineApps. All rights reserved.
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
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

private val logTag = "ImageUtils"

data class Size(val width: Int?, val height: Int?)

enum class ScaleMode {
    FitKeepAspectRatio,
    FillKeepAspectRatio,
    FitAnyDirectionKeepAspectRatio,
    FillAnyDirectionKeepAspectRatio
}

/**
 * Save [sourceImagePath] to [destinationImagePath] as JPEG using specified [imageQuality]
 * 1-100, [maxWidth], [maxHeight] and [scaleMode].
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
        scaleMode: ScaleMode?,
        cacheDir: File
): File? {
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
            bmp, destinationImageFile, quality, Size(maxWidth, maxHeight), scaleMode
            ?: ScaleMode.FitAnyDirectionKeepAspectRatio)
    copyExifData(sourceImagePath, file.path)
    return file
}

private fun saveBitmapToFile(
        sourceBitmap: Bitmap, destinationFile: File, imageQuality: Int, maxSize: Size, scaleMode: ScaleMode): File {

    val currentSize = Size(sourceBitmap.width, sourceBitmap.height)
    val destinationSize = getDownScaledSize(currentSize, maxSize, scaleMode)

    Log.d(logTag, "Saving image to ${destinationFile.path}, quality=$imageQuality, width=${destinationSize.width}, height=${destinationSize.height}")
    if (destinationSize != currentSize) {
        val scaledBmp =
                Bitmap.createScaledBitmap(
                        sourceBitmap, destinationSize.width!!.toInt(), destinationSize.height!!.toInt(), false)
        return saveBitmapToFile(scaledBmp, destinationFile, imageQuality)
    } else {
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

/**
 * Scale down [originalSize] to [maxSize] using [scaleMode]. If [originalSize] is
 * already smaller than [maxSize], return [originalSize].
 */
internal fun getDownScaledSize(originalSize: Size, maxSize: Size, scaleMode: ScaleMode): Size {
    return when (scaleMode) {
        ScaleMode.FitAnyDirectionKeepAspectRatio,
        ScaleMode.FillAnyDirectionKeepAspectRatio ->
            getDownScaledSizeAnyDirection(originalSize, maxSize, scaleMode)
        else ->
            getDownScaledSizeFixedDirection(originalSize, maxSize, scaleMode)
    }
}

internal fun getDownScaledSizeAnyDirection(originalSize: Size, maxSize: Size, scaleMode: ScaleMode): Size {
    val originalWidth = originalSize.width!!.toDouble()
    val originalHeight = originalSize.height!!.toDouble()

    val originalLongerSideLength = max(originalWidth, originalHeight)
    val originalShorterSideLength = min(originalWidth, originalHeight)

    val minLongerSideLength = max(maxSize.width!!, maxSize.height!!).toDouble()
    val minShorterSideLength = min(maxSize.width, maxSize.height).toDouble()
    if (originalLongerSideLength > minLongerSideLength &&
            originalShorterSideLength > minShorterSideLength) {
        // Max size in samples is 1920x1080
        // scale factor for the longer side
        // e.g. 1920 / 3264 = 0,58823529
        val longerSideScaleFactor: Double =
                minLongerSideLength / originalLongerSideLength

        // scale factor for the shorter side
        // e.g. 1080 / 2448 = 0,44117647
        val shorterSideScaleFactor: Double =
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
        val scaleFactor: Double =
                when (scaleMode) {
                    ScaleMode.FillAnyDirectionKeepAspectRatio -> max(longerSideScaleFactor, shorterSideScaleFactor)
                    ScaleMode.FitAnyDirectionKeepAspectRatio -> min(longerSideScaleFactor, shorterSideScaleFactor)
                    else -> throw NotImplementedError()
                }

        // calculate target size
        val targetWidth = scaleFactor * originalWidth
        val targetHeight = scaleFactor * originalHeight

        return Size(targetWidth.roundToInt(), targetHeight.roundToInt())
    } else {
        return originalSize
    }
}

/**
 * Scale down [originalSize] to [maxSize] using [scaleMode]. If [originalSize] is
 * already smaller than [maxSize], return [originalSize].
 */
internal fun getDownScaledSizeFixedDirection(originalSize: Size, maxSize: Size, scaleMode: ScaleMode): Size {
    val originalWidth = originalSize.width!!.toDouble()
    val originalHeight = originalSize.height!!.toDouble()
    if (originalWidth > maxSize.width!! || originalHeight > maxSize.height!!) {
        // Max size in samples is 1920x1080
        // scale factor for the width
        // e.g. 1920 / 3264 = 0,58823529
        val scaleFactorX: Double = maxSize.width / originalWidth

        // scale factor for the height
        // e.g. 1080 / 2448 = 0,44117647
        val scaleFactorY: Double = maxSize.height!! / originalHeight

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
        val scaleFactor: Double =
                when (scaleMode) {
                    ScaleMode.FillKeepAspectRatio -> max(scaleFactorX, scaleFactorY)
                    ScaleMode.FitKeepAspectRatio -> min(scaleFactorX, scaleFactorY)
                    else -> throw NotImplementedError()
                }

        // calculate target size
        val targetWidth = scaleFactor * originalWidth
        val targetHeight = scaleFactor * originalHeight

        return Size(targetWidth.roundToInt(), targetHeight.roundToInt())
    } else {
        return originalSize
    }
}
