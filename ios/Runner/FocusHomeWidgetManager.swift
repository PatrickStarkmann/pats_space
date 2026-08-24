import Foundation
import WidgetKit

final class FocusHomeWidgetManager {
  private let defaults = UserDefaults(suiteName: "group.com.patsspace.app")

  func sync(arguments: [String: Any]?) {
    let values = arguments ?? [:]
    defaults?.set(values["active"] as? Bool ?? false, forKey: "widget.focus.active")
    defaults?.set(values["paused"] as? Bool ?? false, forKey: "widget.focus.paused")
    defaults?.set(values["phase"] as? String ?? "Fokus", forKey: "widget.focus.phase")
    defaults?.set(values["title"] as? String ?? "", forKey: "widget.focus.title")
    defaults?.set(values["countsUp"] as? Bool ?? false, forKey: "widget.focus.counts_up")
    defaults?.set((values["remainingSeconds"] as? NSNumber)?.intValue ?? 0, forKey: "widget.focus.remaining")
    defaults?.set((values["totalSeconds"] as? NSNumber)?.intValue ?? 0, forKey: "widget.focus.total")
    defaults?.set((values["completedSessions"] as? NSNumber)?.intValue ?? 0, forKey: "widget.focus.completed_sessions")
    defaults?.set((values["sessionsPerRound"] as? NSNumber)?.intValue ?? 4, forKey: "widget.focus.sessions_per_round")
    if let expectedEnd = (values["expectedEndMilliseconds"] as? NSNumber)?.int64Value {
      defaults?.set(expectedEnd, forKey: "widget.focus.expected_end")
    } else {
      defaults?.removeObject(forKey: "widget.focus.expected_end")
    }
    WidgetCenter.shared.reloadTimelines(ofKind: "PatsspaceFocusWidget")
  }
}
