import ActivityKit
import Foundation

struct FocusLiveActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var title: String
    var phase: String
    var expectedEnd: Date?
    var isPaused: Bool
    var countsUp: Bool
    var remainingSeconds: Int
    var progress: Double
    var layoutVersion: Int?
  }
}
