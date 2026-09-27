import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "encaisse/device_region") {
      let channel = FlutterMethodChannel(
        name: "encaisse/device_region",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "getTimeZoneId" {
          result(TimeZone.current.identifier)
          return
        }
        guard call.method == "getCountryCode" else {
          result(FlutterMethodNotImplemented)
          return
        }
        if #available(iOS 16, *) {
          result(Locale.current.region?.identifier)
        } else {
          result(Locale.current.regionCode)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
