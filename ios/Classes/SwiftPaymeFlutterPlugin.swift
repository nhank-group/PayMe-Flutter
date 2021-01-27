import Flutter
import UIKit
import PayMESDK
import CryptoSwift

@available(iOS 11.0, *)
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
            if let appToken = arguments?["app_token"] as? String, let publicKey = arguments?["public_key"] as? String, let connectToken = arguments?["connect_token"] as? String, let privateKey = arguments?["app_private_key"] as? String, let env = arguments?["env"] as? String, let colors = arguments?["colors"] as? [String] {
                
                var environment: PayME.Env = PayME.Env.SANDBOX
                switch env {
                case "production":
                    environment = PayME.Env.PRODUCTION
                case "sanbox":
                    environment = PayME.Env.SANDBOX
                case "dev":
                    environment = PayME.Env.DEV
                default:
                    environment = PayME.Env.SANDBOX
                }
                payMe = PayME(appToken: appToken, publicKey: publicKey, connectToken: connectToken, appPrivateKey: privateKey, env: environment, configColor: colors, showLog: 0)
                print(arguments!)
                result(true)
                
            } else {
                result(false)
            }
            
            break
        case "generate_token":
            
            if let userId = arguments?["user_id"] as? String, let key = arguments?["key"] as? String, let phone = arguments?["phone"] as? String {
                let data : [String: Any] = ["timestamp": (Date().timeIntervalSince1970), "userId" : "\(userId)", "phone" : "\(phone)"]
                print(data)
                let params = try? JSONSerialization.data(withJSONObject: data)
                let aes = try? AES(key: Array(key.utf8), blockMode: CBC(iv: [UInt8](repeating: 0, count: 16)), padding: .pkcs5)
                let dataEncrypted = try? aes!.encrypt(Array(String(data: params!, encoding: .utf8)!.utf8))
                 result(dataEncrypted!.toBase64()!)
            } else {
                result(FlutterMethodNotImplemented)
            }
            break
        case "login":
            payMe?.login(onSuccess: { (success) in
                print(success)
                result(true)
            }, onError: { (error) in
                print(error)
                result(false)
            })
            break
        case "get_wallet_info":
            if let payMe = payMe {
                payMe.getWalletInfo { (dict) in
                    result(dict)
                } onError: { (error) in
                    print(error)
                }
                
            }
            break
        case "open_wallet":
            if let currentVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController, let payMe = payMe {
                payMe.openWallet(currentVC: currentVC, action: PayME.Action.OPEN, amount: nil, description: nil, extraData: nil, onSuccess: { (dict) in
//                    print(dict)
                }, onError: { (error) in
//                    print(error)
                })
               
            }
            break
        case "deposit":
            if let currentVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController, let payMe = payMe, let amount = arguments?["amount"] as? Int {
                let payMeVC = PayMeViewController()
                payMeVC.modalPresentationStyle = .fullScreen
                
                let navigationController = UINavigationController(rootViewController: payMeVC)
                navigationController.modalPresentationStyle = .fullScreen
                UIApplication.shared.keyWindow?.rootViewController = navigationController
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
                
                payMe.deposit(currentVC: payMeVC, amount: amount, description: nil, extraData: nil, onSuccess: { (dict) in
                    print(dict)
                }, onError: { (error) in
                    print(error)
                })
            }
            break
        case "withdraw":
            if let currentVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController, let payMe = payMe, let amount = arguments?["amount"] as? Int {
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
    var viewControllerDidLoad: (() -> Void)?
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.yellow
        let label = UILabel()
        label.text = "PayMe"
        label.textColor = UIColor.black
        self.view.addSubview(label)
        label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        if let viewControllerDidLoad = self.viewControllerDidLoad {
            viewControllerDidLoad()
        }
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

extension Formatter {
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
