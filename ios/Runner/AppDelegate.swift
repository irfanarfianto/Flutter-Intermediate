import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Untuk ketersediaan Google Maps di iOS, pastikan Anda memiliki API key yang benar
        GMSServices.provideAPIKey("AIzaSyCrGshm9NdiN8D8WtoFif-hSF3kmf7mEns")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
