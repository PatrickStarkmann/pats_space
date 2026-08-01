import ManagedSettings
import ManagedSettingsUI
import UIKit

private let focusBlockingAppGroup = "group.com.patsspace.app"
private let focusBlockingLanguageKey = "focus_blocking.language.v1"

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(
    shielding application: Application,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(
    shielding webDomain: WebDomain,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    configuration()
  }

  private func configuration() -> ShieldConfiguration {
    let strings = ShieldStrings.current
    return ShieldConfiguration(
      backgroundBlurStyle: .systemMaterialLight,
      backgroundColor: UIColor(red: 0.996, green: 1, blue: 1, alpha: 1),
      icon: UIImage(named: "mobile_lock_1") ?? UIImage(systemName: "shield.lefthalf.filled"),
      title: ShieldConfiguration.Label(
        text: strings.title,
        color: UIColor(red: 0.125, green: 0.129, blue: 0.141, alpha: 1)
      ),
      subtitle: ShieldConfiguration.Label(
        text: strings.subtitle,
        color: UIColor(red: 0.56, green: 0.54, blue: 0.51, alpha: 1)
      ),
      primaryButtonLabel: ShieldConfiguration.Label(
        text: strings.button,
        color: .white
      ),
      primaryButtonBackgroundColor: UIColor(red: 0.125, green: 0.129, blue: 0.141, alpha: 1),
      secondaryButtonLabel: nil
    )
  }
}

private struct ShieldStrings {
  let title: String
  let subtitle: String
  let button: String

  static var current: ShieldStrings {
    let defaults = UserDefaults(suiteName: focusBlockingAppGroup) ?? .standard
    if defaults.string(forKey: focusBlockingLanguageKey) == "en" {
      return ShieldStrings(
        title: "Focus protected",
        subtitle: "This distraction stays blocked until your session ends.",
        button: "Keep focusing"
      )
    }
    return ShieldStrings(
      title: "Fokus geschützt",
      subtitle: "Diese Ablenkung bleibt bis zum Ende deiner Session blockiert.",
      button: "Weiter fokussieren"
    )
  }
}
