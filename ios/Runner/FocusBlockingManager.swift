import FamilyControls
import Flutter
import ManagedSettings
import SwiftUI
import UIKit

private let focusBlockingAppGroup = "group.com.patsspace.app"
private let focusBlockingSelectionKey = "focus_blocking.selection.v1"
private let focusBlockingActiveKey = "focus_blocking.active.v1"
private let focusBlockingExpectedEndKey = "focus_blocking.expected_end.v1"
private let focusBlockingLanguageKey = "focus_blocking.language.v1"

@available(iOS 16.0, *)
@MainActor
final class FocusBlockingManager: NSObject, UIAdaptivePresentationControllerDelegate {
  private let store = ManagedSettingsStore(
    named: ManagedSettingsStore.Name("patsspace.deep-focus")
  )
  private var pickerCompletion: ((FamilyActivitySelection?) -> Void)?

  private var defaults: UserDefaults {
    UserDefaults(suiteName: focusBlockingAppGroup) ?? .standard
  }

  func status() -> [String: Any] {
    let selection = loadSelection()
    return [
      "platform": "ios",
      "authorizationStatus": authorizationStatusName,
      "hasSelection": selection.map(hasSelection) ?? false,
      "isActive": defaults.bool(forKey: focusBlockingActiveKey),
      "selectionCount": selection.map(selectionCount) ?? 0,
    ]
  }

  func recover() -> [String: Any] {
    guard defaults.bool(forKey: focusBlockingActiveKey) else {
      clearShield()
      return status()
    }

    let expectedEnd = defaults.object(forKey: focusBlockingExpectedEndKey) as? Date
    if let expectedEnd, expectedEnd <= Date() {
      endSession()
      return status()
    }

    guard isAuthorizationApproved,
          let selection = loadSelection(),
          hasSelection(selection) else {
      endSession()
      return status()
    }

    applyShield(selection)
    return status()
  }

  func requestAuthorization() async throws -> [String: Any] {
    if !isAuthorizationApproved {
      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
    return status()
  }

  func configureSelection(from presentingViewController: UIViewController?) async throws -> [String: Any] {
    guard isAuthorizationApproved else {
      throw FocusBlockingError.authorizationRequired
    }
    guard let presentingViewController else {
      throw FocusBlockingError.presentationUnavailable
    }

    let initialSelection = loadSelection() ?? FamilyActivitySelection(
      includeEntireCategory: true
    )
    guard let selected = await presentPicker(
      from: presentingViewController,
      initialSelection: initialSelection
    ) else {
      return status()
    }

    let normalized = selectionWithEntireCategories(selected)
    saveSelection(normalized)
    if defaults.bool(forKey: focusBlockingActiveKey) {
      if hasSelection(normalized) {
        applyShield(normalized)
      } else {
        endSession()
      }
    }
    return status()
  }

  func startSession(expectedEndMilliseconds: Int64?) throws -> [String: Any] {
    guard isAuthorizationApproved else {
      throw FocusBlockingError.authorizationRequired
    }
    guard let selection = loadSelection(), hasSelection(selection) else {
      throw FocusBlockingError.selectionRequired
    }

    applyShield(selection)
    defaults.set(true, forKey: focusBlockingActiveKey)

    let expectedEnd: Date
    if let milliseconds = expectedEndMilliseconds {
      expectedEnd = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    } else {
      // Open-ended stopwatch sessions get a recovery ceiling so an abandoned
      // shield is cleared the next time the app starts.
      expectedEnd = Date().addingTimeInterval(12 * 60 * 60)
    }
    defaults.set(expectedEnd, forKey: focusBlockingExpectedEndKey)
    return status()
  }

  func endSession() {
    clearShield()
    defaults.set(false, forKey: focusBlockingActiveKey)
    defaults.removeObject(forKey: focusBlockingExpectedEndKey)
  }

  func setLanguage(_ languageCode: String) {
    defaults.set(languageCode == "en" ? "en" : "de", forKey: focusBlockingLanguageKey)
  }

  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    pickerCompletion?(nil)
  }

  private var authorizationStatusName: String {
    if #available(iOS 26.4, *),
       AuthorizationCenter.shared.authorizationStatus == .approvedWithDataAccess {
      return "approved"
    }
    switch AuthorizationCenter.shared.authorizationStatus {
    case .notDetermined:
      return "notDetermined"
    case .denied:
      return "denied"
    case .approved:
      return "approved"
    default:
      return "unknown"
    }
  }

  private var isAuthorizationApproved: Bool {
    if AuthorizationCenter.shared.authorizationStatus == .approved {
      return true
    }
    if #available(iOS 26.4, *) {
      return AuthorizationCenter.shared.authorizationStatus == .approvedWithDataAccess
    }
    return false
  }

  private func applyShield(_ selection: FamilyActivitySelection) {
    store.shield.applications = selection.applicationTokens.isEmpty
      ? nil
      : selection.applicationTokens
    store.shield.applicationCategories = selection.categoryTokens.isEmpty
      ? nil
      : .specific(selection.categoryTokens)
    store.shield.webDomains = selection.webDomainTokens.isEmpty
      ? nil
      : selection.webDomainTokens
  }

  private func clearShield() {
    store.clearAllSettings()
  }

  private func loadSelection() -> FamilyActivitySelection? {
    guard let data = defaults.data(forKey: focusBlockingSelectionKey),
          let selection = try? PropertyListDecoder().decode(
            FamilyActivitySelection.self,
            from: data
          ) else {
      return nil
    }
    return selectionWithEntireCategories(selection)
  }

  private func saveSelection(_ selection: FamilyActivitySelection) {
    guard let data = try? PropertyListEncoder().encode(selection) else {
      return
    }
    defaults.set(data, forKey: focusBlockingSelectionKey)
  }

  private func selectionWithEntireCategories(
    _ selection: FamilyActivitySelection
  ) -> FamilyActivitySelection {
    guard !selection.includeEntireCategory else {
      return selection
    }
    var normalized = FamilyActivitySelection(includeEntireCategory: true)
    normalized.applicationTokens = selection.applicationTokens
    normalized.categoryTokens = selection.categoryTokens
    normalized.webDomainTokens = selection.webDomainTokens
    return normalized
  }

  private func hasSelection(_ selection: FamilyActivitySelection) -> Bool {
    !selection.applicationTokens.isEmpty ||
      !selection.categoryTokens.isEmpty ||
      !selection.webDomainTokens.isEmpty
  }

  private func selectionCount(_ selection: FamilyActivitySelection) -> Int {
    selection.applicationTokens.count +
      selection.categoryTokens.count +
      selection.webDomainTokens.count
  }

  private func presentPicker(
    from presentingViewController: UIViewController,
    initialSelection: FamilyActivitySelection
  ) async -> FamilyActivitySelection? {
    await withCheckedContinuation { continuation in
      var didResume = false
      let finish: (FamilyActivitySelection?) -> Void = { [weak self] selection in
        guard !didResume else { return }
        didResume = true
        self?.pickerCompletion = nil
        continuation.resume(returning: selection)
      }
      pickerCompletion = finish

      let view = FocusBlockingPickerView(
        initialSelection: initialSelection,
        strings: FocusBlockingPickerStrings.current(defaults: defaults),
        onCancel: {
          presentingViewController.dismiss(animated: true) { finish(nil) }
        },
        onDone: { selection in
          presentingViewController.dismiss(animated: true) { finish(selection) }
        }
      )
      let controller = UIHostingController(rootView: view)
      presentingViewController.present(controller, animated: true) {
        controller.presentationController?.delegate = self
      }
    }
  }
}

@available(iOS 16.0, *)
private struct FocusBlockingPickerView: View {
  @State private var selection: FamilyActivitySelection
  let strings: FocusBlockingPickerStrings
  let onCancel: () -> Void
  let onDone: (FamilyActivitySelection) -> Void

  init(
    initialSelection: FamilyActivitySelection,
    strings: FocusBlockingPickerStrings,
    onCancel: @escaping () -> Void,
    onDone: @escaping (FamilyActivitySelection) -> Void
  ) {
    _selection = State(initialValue: initialSelection)
    self.strings = strings
    self.onCancel = onCancel
    self.onDone = onDone
  }

  var body: some View {
    NavigationView {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle(strings.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button(strings.cancel, action: onCancel)
          }
          ToolbarItem(placement: .confirmationAction) {
            Button(strings.done) { onDone(selection) }
          }
        }
    }
  }
}

private struct FocusBlockingPickerStrings {
  let title: String
  let cancel: String
  let done: String

  static func current(defaults: UserDefaults) -> FocusBlockingPickerStrings {
    if defaults.string(forKey: focusBlockingLanguageKey) == "en" {
      return FocusBlockingPickerStrings(
        title: "Distractions",
        cancel: "Cancel",
        done: "Done"
      )
    }
    return FocusBlockingPickerStrings(
      title: "Ablenkungen",
      cancel: "Abbrechen",
      done: "Fertig"
    )
  }
}

private enum FocusBlockingError: LocalizedError {
  case authorizationRequired
  case selectionRequired
  case presentationUnavailable

  var errorDescription: String? {
    switch self {
    case .authorizationRequired:
      return "Screen Time authorization is required."
    case .selectionRequired:
      return "At least one distraction must be selected."
    case .presentationUnavailable:
      return "The activity picker cannot be presented right now."
    }
  }
}
