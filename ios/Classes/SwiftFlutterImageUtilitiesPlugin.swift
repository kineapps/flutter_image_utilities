// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import Flutter
import UIKit

public class SwiftFlutterImageUtilitiesPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_image_utilities", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterImageUtilitiesPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        log("call:" + call.method)

        switch call.method {
            case "saveAsJpeg":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Invalid arguments",
                                        details: nil))
                    return
                }
                guard let sourceFilePath = args["sourceFilePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Argument 'sourceFilePath' is missing",
                                        details: nil))
                    return
                }
                let destinationFilePath = args["destinationFilePath"] as? String
                let quality = args["quality"] as? Int
                let maxWidth = args["maxWidth"] as? Int
                let maxHeight = args["maxHeight"] as? Int
                let canScaleUp = args["canScaleUp"] as? Bool ?? false

                log("sourceFilePath: " + sourceFilePath)
                log("destinationFilePath: " + (destinationFilePath ?? "null"))
                log("quality: " + (quality?.description ?? "null"))
                log("maxWidth: " + (maxWidth?.description ?? "null"))
                log("maxHeight: " + (maxHeight?.description ?? "null"))
                log("canScaleUp: " + canScaleUp.description)

                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let outputFile = try saveImageFileAsJpeg(sourceImagePath: sourceFilePath,
                                                                 destinationImagePath: destinationFilePath,
                                                                 imageQuality: quality,
                                                                 maxWidth: maxWidth,
                                                                 maxHeight: maxHeight,
                                                                 canScaleUp: canScaleUp)
                        DispatchQueue.main.async {
                            result(outputFile?.path)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            log("saveAsJpeg failed to error:\(error)")
                            result(FlutterError(code: "exception",
                                                message: error.localizedDescription,
                                                details: nil))
                        }
                    }
                }

            case "getImageProperties":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Invalid arguments",
                                        details: nil))
                    return
                }
                guard let imageFile = args["imageFile"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "Argument 'imageFile' is missing",
                                        details: nil))
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        // get source image
                        let imageData = try Data(contentsOf: URL(fileURLWithPath: imageFile))
                        let image = UIImage(data: imageData)

                        // TODO: get orientation
                        let orientation = 0 // undefined orientation
                        let dict: [String: Any] =
                            [
                                "width": Int(image!.size.width),
                                "height": Int(image!.size.height),
                                "orientation": orientation
                            ]

                        DispatchQueue.main.async {
                            result(dict)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            log("getImageProperties failed to error:\(error)")
                            result(FlutterError(code: "exception",
                                                message: error.localizedDescription,
                                                details: nil))
                        }
                    }
                }

            default:
                log("not implemented")
                result(FlutterMethodNotImplemented)
        }
    }
}
