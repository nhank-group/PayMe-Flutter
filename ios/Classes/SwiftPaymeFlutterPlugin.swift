import Flutter
import UIKit
import PayMESDK

public class SwiftPaymeFlutterPlugin: NSObject, FlutterPlugin {
    
    var payMe: PayME?
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "payme_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftPaymeFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let arguments = call.arguments as? Dictionary<String, String> else { return }
        switch call.method {
        case "init":
            result(true)
            break
        case "is_connected":
            break
            
        default:
            result(FlutterMethodNotImplemented)
            return
        }
    }
}
