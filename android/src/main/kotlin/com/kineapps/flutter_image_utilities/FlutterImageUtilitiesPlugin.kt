// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

package com.kineapps.flutter_image_utilities

import android.content.Context
import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import java.io.File
import android.media.ExifInterface
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import java.io.IOException

class FlutterImageUtilitiesPlugin : FlutterPlugin, MethodCallHandler {
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var methodChannel: MethodChannel? = null
    private var applicationContext: Context? = null

    companion object {
        private const val LOG_TAG = "FlutterImageUtilPlugin"
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            Log.d(LOG_TAG, "registerWith")
            val plugin = FlutterImageUtilitiesPlugin()
            plugin.applicationContext = registrar.activeContext()
            plugin.doOnAttachedToEngine(registrar.messenger())
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(LOG_TAG, "onAttachedToEngine - IN")

        if (pluginBinding != null) {
            Log.w(LOG_TAG, "onAttachedToEngine - already attached")
        }

        pluginBinding = binding

        applicationContext = binding.applicationContext

        val messenger = pluginBinding?.binaryMessenger
        doOnAttachedToEngine(messenger!!)

        Log.d(LOG_TAG, "onAttachedToEngine - OUT")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(LOG_TAG, "onDetachedFromEngine")
        doOnDetachedFromEngine()
    }

    private fun doOnAttachedToEngine(messenger: BinaryMessenger) {
        Log.d(LOG_TAG, "doOnAttachedToEngine - IN")

        methodChannel = MethodChannel(messenger, "flutter_image_utilities")
        methodChannel?.setMethodCallHandler(this)

        Log.d(LOG_TAG, "doOnAttachedToEngine - OUT")
    }

    private fun doOnDetachedFromEngine() {
        Log.d(LOG_TAG, "doOnDetachedFromEngine - IN")

        if (pluginBinding == null) {
            Log.w(LOG_TAG, "doOnDetachedFromEngine - already detached")
        }
        pluginBinding = null

        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        Log.d(LOG_TAG, "doOnDetachedFromEngine - OUT")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val uiScope = CoroutineScope(Dispatchers.Main)
        when (call.method) {
            "saveAsJpeg" -> {
                uiScope.launch {
                    try {
                        val sourceFilePath = call.argument<String>("sourceFilePath")
                        val destinationFilePath = call.argument<String>("destinationFilePath")
                        val quality = call.argument<Int>("quality")
                        val maxWidth = call.argument<Int>("maxWidth")
                        val maxHeight = call.argument<Int>("maxHeight")
                        val canScaleUp = call.argument<Boolean>("canScaleUp") ?: false
                                

                        var outputFile: File? = null
                        withContext(Dispatchers.IO) {
                            outputFile = saveImageFileAsJpeg(
                                    sourceFilePath!!,
                                    destinationFilePath,
                                    quality,
                                    maxWidth,
                                    maxHeight,
                                    canScaleUp,
                                    applicationContext!!.cacheDir)
                        }
                        result.success(outputFile?.path)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("exception", e.localizedMessage, e.toString())
                    }
                }
            }
            "getImageProperties" -> {
                uiScope.launch {
                    try {
                        val imageFile = call.argument<String>("imageFile")!!

                        val properties = HashMap<String, Int>()
                        withContext(Dispatchers.IO) {
                            val options = BitmapFactory.Options()
                            options.inJustDecodeBounds = true
                            BitmapFactory.decodeFile(imageFile, options)
                            properties["width"] = options.outWidth
                            properties["height"] = options.outHeight
                            var orientation = ExifInterface.ORIENTATION_UNDEFINED
                            try {
                                val exif = ExifInterface(imageFile)
                                orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED)
                            } catch (ex: IOException) {
                                // ignore EXIF reading error
                            }
                            properties["orientation"] = orientation
                        }

                        result.success(properties)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("exception", e.localizedMessage, e.toString())
                    }
                }
            }
            else -> result.notImplemented()
        }
    }
}
