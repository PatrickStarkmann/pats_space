enum FocusBlockingPlatform { ios, android, unsupported }

enum FocusBlockingAuthorization { unknown, notDetermined, denied, approved }

class FocusBlockingStatus {
  const FocusBlockingStatus({
    required this.platform,
    required this.authorization,
    required this.hasSelection,
    required this.isActive,
    required this.selectionCount,
  });

  const FocusBlockingStatus.initial()
    : platform = FocusBlockingPlatform.unsupported,
      authorization = FocusBlockingAuthorization.unknown,
      hasSelection = false,
      isActive = false,
      selectionCount = 0;

  final FocusBlockingPlatform platform;
  final FocusBlockingAuthorization authorization;
  final bool hasSelection;
  final bool isActive;
  final int selectionCount;

  bool get isSupported => platform != FocusBlockingPlatform.unsupported;
  bool get isReady =>
      authorization == FocusBlockingAuthorization.approved && hasSelection;

  factory FocusBlockingStatus.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const FocusBlockingStatus.initial();
    }

    final platform = switch (map['platform']) {
      'ios' => FocusBlockingPlatform.ios,
      'android' => FocusBlockingPlatform.android,
      _ => FocusBlockingPlatform.unsupported,
    };
    final authorization = switch (map['authorizationStatus']) {
      'notDetermined' => FocusBlockingAuthorization.notDetermined,
      'denied' => FocusBlockingAuthorization.denied,
      'approved' => FocusBlockingAuthorization.approved,
      _ => FocusBlockingAuthorization.unknown,
    };

    return FocusBlockingStatus(
      platform: platform,
      authorization: authorization,
      hasSelection: map['hasSelection'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? false,
      selectionCount: map['selectionCount'] as int? ?? 0,
    );
  }
}
