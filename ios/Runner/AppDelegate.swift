import Flutter
import UIKit

enum ChannelName: String {
    case batttery = "samples.flutter.dev/battery"
    case charging = "samples.flutter.dev/charging"
}

enum BatteryState: String {
    case charging = "charging"
    case discharging = "discharging"
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
    
      guard let controller = window?.rootViewController as? FlutterViewController else {
          fatalError("rootViewController is not type FlutterViewController")
      }
      
      let batteryChannel = FlutterMethodChannel(name: ChannelName.batttery.rawValue, binaryMessenger: controller.binaryMessenger)
      batteryChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          guard call.method == "getBatteryLevel" else {
              result(FlutterMethodNotImplemented)
              return
          }
          self?.receiveBatteryLevel(result: result)
      }
      print("bbbb")
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
