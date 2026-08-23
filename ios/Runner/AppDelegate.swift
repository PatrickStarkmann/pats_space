import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let focusBlockingChannelName = "pats_space/focus_blocking"
  private let focusLiveActivityChannelName = "pats_space/focus_live_activity"
  private lazy var focusBlockingManager = FocusBlockingManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerFocusBlockingChannel(
      messenger: engineBridge.applicationRegistrar.messenger()
    )
    registerFocusLiveActivityChannel(
      messenger: engineBridge.applicationRegistrar.messenger()
    )
  }

  private func registerFocusLiveActivityChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: focusLiveActivityChannelName,
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { call, result in
      Task { @MainActor in
        guard #available(iOS 16.1, *) else {
          result(nil)
          return
        }
        let manager = FocusLiveActivityManager()

        do {
          switch call.method {
          case "sync":
            try await manager.sync(arguments: call.arguments as? [String: Any])
            result(nil)
          case "end":
            await manager.end()
            result(nil)
          default:
            result(FlutterMethodNotImplemented)
          }
        } catch {
          result(
            FlutterError(
              code: "live_activity_error",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func registerFocusBlockingChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: focusBlockingChannelName,
      binaryMessenger: messenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: nil, details: nil))
        return
      }

      Task { @MainActor in
        do {
          switch call.method {
          case "status":
            result(self.focusBlockingManager.status())
          case "recover":
            result(self.focusBlockingManager.recover())
          case "requestAuthorization":
            result(try await self.focusBlockingManager.requestAuthorization())
          case "configureSelection":
            result(
              try await self.focusBlockingManager.configureSelection(
                from: self.topViewController()
              )
            )
          case "startSession":
            let arguments = call.arguments as? [String: Any]
            let expectedEnd = (
              arguments?["expectedEndMilliseconds"] as? NSNumber
            )?.int64Value
            result(
              try self.focusBlockingManager.startSession(
                expectedEndMilliseconds: expectedEnd
              )
            )
          case "endSession":
            self.focusBlockingManager.endSession()
            result(self.focusBlockingManager.status())
          case "setLanguage":
            let arguments = call.arguments as? [String: Any]
            let languageCode = arguments?["languageCode"] as? String ?? "de"
            self.focusBlockingManager.setLanguage(languageCode)
            result(nil)
          default:
            result(FlutterMethodNotImplemented)
          }
        } catch {
          result(
            FlutterError(
              code: "focus_blocking_error",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func topViewController() -> UIViewController? {
    let rootViewController = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController

    var top = rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
