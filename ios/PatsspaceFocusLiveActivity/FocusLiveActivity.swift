import ActivityKit
import SwiftUI
import WidgetKit

@main
struct FocusLiveActivityBundle: WidgetBundle {
  var body: some Widget {
    FocusTimerLiveActivity()
    PatsspaceFocusWidget()
  }
}

private struct PatsspaceFocusWidget: Widget {
  let kind = "PatsspaceFocusWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FocusWidgetProvider()) { entry in
      FocusWidgetView(entry: entry)
    }
    .configurationDisplayName("Patsspace Fokus")
    .description("Dein aktueller Fokus auf einen Blick.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

private struct FocusWidgetEntry: TimelineEntry {
  let date: Date
  let active: Bool
  let paused: Bool
  let phase: String
  let title: String
  let countsUp: Bool
  let remainingSeconds: Int
  let totalSeconds: Int
  let completedSessions: Int
  let sessionsPerRound: Int
  let expectedEnd: Date?
}

private struct FocusWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> FocusWidgetEntry { entry() }
  func getSnapshot(in context: Context, completion: @escaping (FocusWidgetEntry) -> Void) { completion(entry()) }
  func getTimeline(in context: Context, completion: @escaping (Timeline<FocusWidgetEntry>) -> Void) {
    let value = entry()
    var entries = [value]

    if value.active,
       !value.paused,
       !value.countsUp,
       let expectedEnd = value.expectedEnd {
      var refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: value.date)!
      while refreshDate < expectedEnd && entries.count < 31 {
        entries.append(entry(at: refreshDate))
        refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: refreshDate)!
      }
    }

    let refresh = value.expectedEnd?.addingTimeInterval(1) ?? Date().addingTimeInterval(15 * 60)
    completion(Timeline(entries: entries, policy: .after(refresh)))
  }

  private func entry(at date: Date = Date()) -> FocusWidgetEntry {
    let defaults = UserDefaults(suiteName: "group.com.patsspace.app")
    let endMillis = (defaults?.object(forKey: "widget.focus.expected_end") as? NSNumber)?.int64Value
    return FocusWidgetEntry(
      date: date, active: defaults?.bool(forKey: "widget.focus.active") ?? false,
      paused: defaults?.bool(forKey: "widget.focus.paused") ?? false,
      phase: defaults?.string(forKey: "widget.focus.phase") ?? "Fokus",
      title: defaults?.string(forKey: "widget.focus.title") ?? "",
      countsUp: defaults?.bool(forKey: "widget.focus.counts_up") ?? false,
      remainingSeconds: defaults?.integer(forKey: "widget.focus.remaining") ?? 0,
      totalSeconds: defaults?.integer(forKey: "widget.focus.total") ?? 0,
      completedSessions: defaults?.integer(forKey: "widget.focus.completed_sessions") ?? 0,
      sessionsPerRound: defaults?.integer(forKey: "widget.focus.sessions_per_round") ?? 4,
      expectedEnd: endMillis.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) }
    )
  }
}

private struct FocusWidgetView: View {
  let entry: FocusWidgetEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    Link(destination: URL(string: "pats-space://focus")!) {
      Group {
        if entry.active {
          activeContent
        } else if family == .systemSmall {
          idleSmallContent
        } else {
          idleMediumContent
        }
      }
    }
    .patsspaceWidgetBackground()
  }

  private var activeContent: some View {
    ZStack(alignment: .topTrailing) {
      VStack(alignment: .leading, spacing: 0) {
        Spacer(minLength: 4)

        Group {
          if entry.paused {
            Text(format(entry.remainingSeconds))
          } else {
            timerText()
          }
        }
        .font(.system(size: 38, weight: .medium, design: .rounded).monospacedDigit())
        .foregroundStyle(PatsspaceLiveActivityColor.ink)
        .minimumScaleFactor(0.78)
        .lineLimit(1)

        HStack(spacing: 6) {
          Image(systemName: entry.paused ? "pause.fill" : "leaf.fill")
            .font(.system(size: 11, weight: .semibold))
          Text(statusLabel)
        }
        .font(.system(size: 13, weight: .medium, design: .rounded))
        .foregroundStyle(PatsspaceLiveActivityColor.muted)
        .padding(.top, 5)

        if !entry.countsUp {
          PatsspaceWidgetProgress(value: progress)
            .frame(height: 5)
            .padding(.top, family == .systemMedium ? 10 : 14)
        }
      }
      .padding(16)

      if family == .systemMedium && !entry.countsUp {
        PatsspaceWidgetSessionDots(
          completedSessions: entry.completedSessions,
          sessionsPerRound: entry.sessionsPerRound
        )
        .padding(.top, 42)
        .padding(.trailing, 16)
      }
    }
  }

  private var idleSmallContent: some View {
    VStack(alignment: .center, spacing: 0) {
      Spacer(minLength: 2)

      Text(format(entry.remainingSeconds))
        .font(.system(size: 37, weight: .medium, design: .rounded).monospacedDigit())
        .foregroundStyle(PatsspaceLiveActivityColor.ink)
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .center)

      Spacer(minLength: 12)

      startButton(label: "Start")
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding(16)
  }

  private var idleMediumContent: some View {
    ZStack(alignment: .bottomTrailing) {
      VStack(alignment: .leading, spacing: 0) {
        Spacer(minLength: 10)

        Text(format(entry.remainingSeconds))
          .font(.system(size: 42, weight: .medium, design: .rounded).monospacedDigit())
          .foregroundStyle(PatsspaceLiveActivityColor.ink)

        Spacer(minLength: 18)

        startButton(label: "Fokus starten")
      }
      .padding(16)
      .padding(.trailing, 82)

      Image("PatsspaceWidgetPeek", bundle: .main)
        .resizable()
        .renderingMode(.original)
        .aspectRatio(contentMode: .fit)
        .frame(width: 158, height: 158)
        .offset(x: 68, y: 4)
        .accessibilityHidden(true)
    }
  }

  private func startButton(label: String) -> some View {
    Label(label, systemImage: "play.fill")
      .font(.system(size: 14, weight: .bold, design: .rounded))
      .foregroundStyle(Color.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(PatsspaceLiveActivityColor.ink, in: Capsule())
  }

  private func timerText() -> Text {
    guard let expectedEnd = entry.expectedEnd else { return Text(format(entry.remainingSeconds)) }
    return Text(timerInterval: entry.countsUp ? expectedEnd...Date.distantFuture : Date()...expectedEnd, countsDown: !entry.countsUp)
  }

  private var statusLabel: String {
    entry.paused ? "Pause" : entry.phase
  }

  private var progress: Double {
    guard entry.totalSeconds > 0 else { return 0 }
    if entry.paused {
      return 1 - min(1, max(0, Double(entry.remainingSeconds) / Double(entry.totalSeconds)))
    }
    guard let expectedEnd = entry.expectedEnd else { return 0 }
    return 1 - min(1, max(0, expectedEnd.timeIntervalSince(entry.date) / Double(entry.totalSeconds)))
  }

  private func format(_ seconds: Int) -> String { String(format: "%d:%02d", seconds / 60, seconds % 60) }
}

private struct PatsspaceWidgetProgress: View {
  let value: Double

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Capsule().fill(PatsspaceLiveActivityColor.sage.opacity(0.22))
        Capsule()
          .fill(PatsspaceLiveActivityColor.sage)
          .frame(width: max(5, geometry.size.width * value))
      }
    }
  }
}

private struct PatsspaceWidgetSessionDots: View {
  let completedSessions: Int
  let sessionsPerRound: Int

  var body: some View {
    HStack(spacing: 7) {
      ForEach(0..<min(max(1, sessionsPerRound), 6), id: \.self) { index in
        Circle()
          .fill(Color.clear)
          .overlay {
            Circle().stroke(
              index <= completedSessions
                ? PatsspaceLiveActivityColor.ink
                : PatsspaceLiveActivityColor.sage.opacity(0.48),
              lineWidth: index <= completedSessions ? 1.8 : 1.4
            )
          }
          .overlay {
            if index < completedSessions {
              Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(PatsspaceLiveActivityColor.ink)
            } else if index == completedSessions {
              Circle()
                .fill(PatsspaceLiveActivityColor.ink)
                .frame(width: 5, height: 5)
            }
          }
          .frame(width: 16, height: 16)
      }
    }
  }
}

private extension View {
  @ViewBuilder
  func patsspaceWidgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(PatsspaceLiveActivityColor.widgetCanvas, for: .widget)
    } else {
      background(PatsspaceLiveActivityColor.widgetCanvas)
    }
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
  static let widgetCanvas = Color(red: 0.97, green: 0.975, blue: 0.95)
  static let ink = Color(red: 0.12, green: 0.14, blue: 0.11)
  static let muted = Color(red: 0.42, green: 0.45, blue: 0.39)
}
