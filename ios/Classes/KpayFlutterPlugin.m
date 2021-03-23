#import "KpayFlutterPlugin.h"
#if __has_include(<kpay_flutter/kpay_flutter-Swift.h>)
#import <kpay_flutter/kpay_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "kpay_flutter-Swift.h"
#endif

@implementation KpayFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKpayFlutterPlugin registerWithRegistrar:registrar];
}
@end
