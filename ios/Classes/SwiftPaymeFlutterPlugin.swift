import Flutter
import UIKit
import PayMESDK
import CryptoSwift

public class SwiftPaymeFlutterPlugin: NSObject, FlutterPlugin {
    
    var payMe: PayME?
    var flutterVC: UIViewController?
    var payMeVC: UIViewController?
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "payme_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftPaymeFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? Dictionary<String, Any?>
        switch call.method {
        case "init":
            if let appId = arguments?["app_id"] as? String, let publicKey = arguments?["public_key"] as? String, let connectToken = arguments?["connect_token"] as? String, let privateKey = arguments?["app_private_key"] as? String, let env = arguments?["env"] as? String, let colors = arguments?["colors"] as? [String] {
                payMe = PayME(appID: appId, publicKey: publicKey, connectToken: connectToken, appPrivateKey: privateKey, env: env, configColor: colors)
                print(arguments!)
                result(true)
                
            } else {
                result(FlutterMethodNotImplemented)
            }
            
            break
        case "generate_token":
            
            if let userId = arguments?["user_id"] as? String, let key = arguments?["key"] as? String, let phone = arguments?["phone"] as? String {
                //                let string = CryptoAES.encryptAES(text: text, password: key)
                do {
                    let data = "{ \"timestamp\": \"\(Date().timeIntervalSince1970)\", \"userId\" : \"\(userId)\", \"phone\" : \"\(phone)\"}"
                    print(data)
                    let aes = try AES(key: Array(key.utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
                    let dataEncrypted = try aes.encrypt(Array(data.utf8))
                    result(dataEncrypted.toBase64())
                } catch {
                    result(FlutterMethodNotImplemented)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
            break
        case "is_connected":
            if let payMe = payMe {
                result(payMe.isConnected())
            } else {
                result(false)
            }
            break
        case "open_wallet":
            if let currentVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController, let payMe = payMe {
                let payMeVC = PayMeViewController()
                payMeVC.modalPresentationStyle = .fullScreen
                payMeVC.viewControllerDimissHandler = {
                    UIApplication.shared.keyWindow?.rootViewController = currentVC
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
                let navigationController = UINavigationController(rootViewController: payMeVC)
                navigationController.modalPresentationStyle = .fullScreen
                UIApplication.shared.keyWindow?.rootViewController = navigationController
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
                
                payMe.openWallet(currentVC: payMeVC, action: PayME.Action.OPEN, amount: nil, description: nil, extraData: nil, onSuccess: { (dict) in
                    print(dict)
                }, onError: { (error) in
                    print(error)
                })
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            return
        }
    }
}

class PayMeViewController: UIViewController {
    
    private var isVCLoaded = false
    var viewControllerDimissHandler: (() -> Void)?
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isVCLoaded = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isVCLoaded {
            self.dismiss(animated: false) {
                if let viewControllerDimissHandler = self.viewControllerDimissHandler {
                    viewControllerDimissHandler()
                }
            }
        }
    }
}
