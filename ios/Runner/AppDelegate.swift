import Flutter
import UIKit

enum ChannelName: String {
    case battery = "samples.flutter.dev/battery"
    case addition = "samples.flutter.dev/addition"
}

enum BatteryMethod: String {
    case getBatteryLevel
}

enum AdditionMethod: String {
    case add
}

enum MyFlutterErrorCode: String {
    case unavailable = "UNAVAILABLE"
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
      setupFlutterMethodChannels()
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func setupFlutterMethodChannels() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        let batteryChannel = FlutterMethodChannel(
          name: ChannelName.battery.rawValue,
          binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case BatteryMethod.getBatteryLevel.rawValue:
                self?.receiveBatteryLevel(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        let additionChannel = FlutterMethodChannel(
          name: ChannelName.addition.rawValue,
          binaryMessenger: controller.binaryMessenger)
        additionChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case AdditionMethod.add.rawValue:
                self?.callFlutterAdd(channel: additionChannel)
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func callFlutterAdd(channel: FlutterMethodChannel) {
        let num1 = 35
        let num2 = 8
        channel.invokeMethod("add", arguments: [num1, num2]) { [weak self] result in
            var resultStr = "no result"
            if let result {
                resultStr = "result: \(num1) + \(num2) = \(result)"
            }
            self?.showAlert(text: resultStr)
        }
    }
    
    private func showAlert(text: String) {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            
        }
        let alert = UIAlertController(title: "add result", message: text, preferredStyle: .alert)
        alert.addAction(action)
        controller.present(alert, animated: true)
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        guard device.batteryState != .unknown else {
            result(FlutterError(code: MyFlutterErrorCode.unavailable.rawValue,
                                message: "Battery info unavailable",
                                details: nil))
            return
        }
        result(Int(device.batteryLevel * 100))
    }
}
