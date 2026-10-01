import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeDocumentsFromBackup()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Keeps the encrypted database out of iCloud and iTunes backups.
  ///
  /// The database lives in Documents, which iOS backs up, while its key is
  /// stored this-device-only and is not. A restored device therefore carried a
  /// database it could never open, and the app minted a new key over it, which
  /// bricked it permanently. Excluding the data means a restore starts clean
  /// instead.
  ///
  /// Set on the directory rather than the file: the database does not exist on
  /// first launch, and the attribute covers files created later. `Info.plist`
  /// used to carry `NSURLIsExcludedFromBackupKey`, which does nothing — it is
  /// an NSURL resource attribute, not a plist key.
  private func excludeDocumentsFromBackup() {
    guard var documents = FileManager.default.urls(
      for: .documentDirectory, in: .userDomainMask
    ).first else { return }
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    do {
      try documents.setResourceValues(values)
    } catch {
      NSLog("Could not exclude Documents from backup: \(error)")
    }
  }

  // The app-switcher privacy cover lives in SceneDelegate. With the UIScene
  // lifecycle, UIApplication activity callbacks here do not reach a window.
}
