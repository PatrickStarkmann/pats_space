import ActivityKit
import SwiftUI
import WidgetKit

@main
struct FocusLiveActivityBundle: WidgetBundle {
  var body: some Widget {
    FocusTimerLiveActivity()
  }
}

@available(iOS 16.1, *)
struct FocusTimerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: FocusLiveActivityAttributes.self) { context in
      FocusLiveActivityView(state: context.state)
        .activityBackgroundTint(PatsspaceLiveActivityColor.glass)
        .activitySystemActionForegroundColor(PatsspaceLiveActivityColor.primary)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          PatsspaceMark(compact: true)
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(alignment: .leading, spacing: 2) {
            Text(context.state.isPaused ? "Pausiert" : context.state.phase)
              .font(.headline)
            Text(context.state.title)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          FocusLiveActivityCountdown(state: context.state)
            .font(.headline.monospacedDigit())
        }
      } compactLeading: {
        PatsspaceMark(compact: true)
      } compactTrailing: {
        FocusLiveActivityCountdown(state: context.state)
          .font(.caption2.monospacedDigit())
          .foregroundStyle(.primary)
      } minimal: {
        PatsspaceMark(compact: true)
      }
    }
  }
}

@available(iOS 16.1, *)
private struct FocusLiveActivityView: View {
  let state: FocusLiveActivityAttributes.ContentState

  var body: some View {
    HStack(spacing: 18) {
      PatsspaceMark(compact: false)

      VStack(alignment: .leading, spacing: 8) {
        FocusLiveActivityCountdown(state: state)
          .font(.system(size: 36, weight: .medium, design: .rounded).monospacedDigit())
          .foregroundStyle(PatsspaceLiveActivityColor.primary)
          .minimumScaleFactor(0.72)
          .lineLimit(1)

        HStack(spacing: 6) {
          Text(state.isPaused ? "Pausiert" : state.phase)
            .fontWeight(.semibold)
          Text("•")
          Text(state.title)
        }
        .font(.system(size: 15, design: .rounded))
        .foregroundStyle(PatsspaceLiveActivityColor.secondary)
          .lineLimit(1)

        PatsspaceProgressBar(value: state.progress)
          .frame(height: 7)
      }

      Spacer(minLength: 0)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 18)
  }
}

@available(iOS 16.1, *)
private struct FocusLiveActivityCountdown: View {
  let state: FocusLiveActivityAttributes.ContentState

  var body: some View {
    if state.isPaused {
      Text(formattedDuration(state.remainingSeconds))
    } else if state.countsUp, let startedAt = state.expectedEnd {
      Text(timerInterval: startedAt...Date.distantFuture, countsDown: false)
    } else if let expectedEnd = state.expectedEnd {
      Text(timerInterval: Date()...expectedEnd, countsDown: true)
    } else {
      Text(formattedDuration(state.remainingSeconds))
    }
  }

  private func formattedDuration(_ seconds: Int) -> String {
    String(format: "%d:%02d", max(0, seconds) / 60, max(0, seconds) % 60)
  }
}

@available(iOS 16.1, *)
private struct PatsspaceMark: View {
  let compact: Bool

  var body: some View {
    Image("PatsspaceLiveActivityIcon", bundle: .main)
      .resizable()
      .renderingMode(.original)
      .aspectRatio(contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: compact ? 8 : 14, style: .continuous))
    .frame(width: compact ? 28 : 78, height: compact ? 28 : 78)
  }
}

@available(iOS 16.1, *)
private struct PatsspaceProgressBar: View {
  let value: Double

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.white.opacity(0.18))
        Capsule()
          .fill(PatsspaceLiveActivityColor.sage)
          .frame(width: max(7, geometry.size.width * min(1, max(0, value))))
      }
    }
  }
}

private enum PatsspaceLiveActivityColor {
  static let glass = Color(red: 0.11, green: 0.12, blue: 0.10).opacity(0.80)
  static let primary = Color(red: 0.98, green: 0.98, blue: 0.97)
  static let secondary = Color(red: 0.78, green: 0.77, blue: 0.72)
  static let sage = Color(red: 0.612, green: 0.686, blue: 0.533)
  static let sagePressed = Color(red: 0.537, green: 0.616, blue: 0.459)
  static let sageSoft = Color(red: 0.914, green: 0.933, blue: 0.882)
}
