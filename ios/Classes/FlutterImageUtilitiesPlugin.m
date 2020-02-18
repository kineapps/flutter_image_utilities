#import "FlutterImageUtilitiesPlugin.h"
#import <flutter_image_utilities/flutter_image_utilities-Swift.h>

@implementation FlutterImageUtilitiesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterImageUtilitiesPlugin registerWithRegistrar:registrar];
}
@end
