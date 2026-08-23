import ActivityKit
import Foundation

@available(iOS 16.1, *)
final class FocusLiveActivityManager {
  private let layoutVersion = 4

  func sync(arguments: [String: Any]?) async throws {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    guard
      let arguments,
      let title = arguments["title"] as? String,
      let phase = arguments["phase"] as? String
    else {
      return
    }

    let expectedEndMilliseconds =
      (arguments["expectedEndMilliseconds"] as? NSNumber)?.int64Value
    let expectedEnd = expectedEndMilliseconds.map {
      Date(timeIntervalSince1970: TimeInterval($0) / 1000)
    }
    let remainingSeconds = (arguments["remainingSeconds"] as? NSNumber)?.intValue ?? 0
    let totalSeconds = (arguments["totalSeconds"] as? NSNumber)?.intValue ?? 0
    let progress = totalSeconds > 0
      ? min(1, max(0, 1 - Double(remainingSeconds) / Double(totalSeconds)))
      : 0
    let contentState = FocusLiveActivityAttributes.ContentState(
      title: title,
      phase: phase,
      expectedEnd: expectedEnd,
      isPaused: arguments["paused"] as? Bool ?? false,
      countsUp: arguments["countUp"] as? Bool ?? false,
      remainingSeconds: remainingSeconds,
      progress: progress,
      layoutVersion: layoutVersion
    )

    let activities = Activity<FocusLiveActivityAttributes>.activities
    if #available(iOS 16.2, *) {
      if let activity = activities.first,
         activity.content.state.layoutVersion == layoutVersion {
        await activity.update(
          ActivityContent(state: contentState, staleDate: contentState.expectedEnd)
        )
        return
      }
    } else if let activity = activities.first {
        await activity.update(using: contentState)
      return
    }

    for activity in activities {
      if #available(iOS 16.2, *) {
        await activity.end(nil, dismissalPolicy: .immediate)
      } else {
        await activity.end(dismissalPolicy: .immediate)
      }
    }

    if #available(iOS 16.2, *) {
      _ = try Activity.request(
        attributes: FocusLiveActivityAttributes(),
        content: ActivityContent(state: contentState, staleDate: contentState.expectedEnd),
        pushType: nil
      )
    } else {
      _ = try Activity.request(
        attributes: FocusLiveActivityAttributes(),
        contentState: contentState,
        pushType: nil
      )
    }
  }

  func end() async {
    for activity in Activity<FocusLiveActivityAttributes>.activities {
      if #available(iOS 16.2, *) {
        await activity.end(nil, dismissalPolicy: .immediate)
      } else {
        await activity.end(dismissalPolicy: .immediate)
      }
    }
  }
}
