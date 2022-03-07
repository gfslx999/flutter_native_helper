#import "FlutterNativeHelperPlugin.h"
#if __has_include(<flutter_native_helper/flutter_native_helper-Swift.h>)
#import <flutter_native_helper/flutter_native_helper-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_native_helper-Swift.h"
#endif

@implementation FlutterNativeHelperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativeHelperPlugin registerWithRegistrar:registrar];
}
@end
