import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  /// Tag of the view that hides the app from the app switcher snapshot.
  private static let privacyCoverTag = 0x5255_4E57

  private var lifecycleObservers: [NSObjectProtocol] = []

  override init() {
    super.init()
    // FlutterSceneDelegate implements sceneWillResignActive and
    // sceneDidBecomeActive privately to forward them to plugins. Overriding
    // them here would replace that forwarding, so observe the matching scene
    // notifications instead.
    let center = NotificationCenter.default
    lifecycleObservers = [
      center.addObserver(
        forName: UIScene.willDeactivateNotification, object: nil, queue: .main
      ) { [weak self] notification in
        self?.coverWindows(of: notification.object)
      },
      center.addObserver(
        forName: UIScene.didActivateNotification, object: nil, queue: .main
      ) { [weak self] notification in
        self?.uncoverWindows(of: notification.object)
      },
    ]
  }

  deinit {
    for observer in lifecycleObservers {
      NotificationCenter.default.removeObserver(observer)
    }
  }

  private func ownScene(_ object: Any?) -> UIWindowScene? {
    guard let scene = object as? UIWindowScene, scene.delegate === self else {
      return nil
    }
    return scene
  }

  /// Covers every window of the scene so no financial numbers appear in the
  /// app switcher.
  private func coverWindows(of object: Any?) {
    guard let scene = ownScene(object) else { return }
    for window in scene.windows where window.viewWithTag(Self.privacyCoverTag) == nil {
      let cover = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
      cover.frame = window.bounds
      cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      cover.tag = Self.privacyCoverTag

      // A blur alone can leave large figures legible, so tint it with the
      // app background colour (AppColors.background, #040D1A).
      let tint = UIView(frame: cover.bounds)
      tint.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      tint.backgroundColor = UIColor(red: 4 / 255, green: 13 / 255, blue: 26 / 255, alpha: 0.85)
      cover.contentView.addSubview(tint)

      window.addSubview(cover)
    }
  }

  private func uncoverWindows(of object: Any?) {
    guard let scene = ownScene(object) else { return }
    for window in scene.windows {
      window.viewWithTag(Self.privacyCoverTag)?.removeFromSuperview()
    }
  }
}
