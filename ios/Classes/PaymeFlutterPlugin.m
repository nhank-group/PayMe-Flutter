#import "PaymeFlutterPlugin.h"
#if __has_include(<payme_flutter/payme_flutter-Swift.h>)
#import <payme_flutter/payme_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "payme_flutter-Swift.h"
#endif

@implementation PaymeFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaymeFlutterPlugin registerWithRegistrar:registrar];
}
@end
