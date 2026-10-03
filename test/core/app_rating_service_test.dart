import 'package:flutter_test/flutter_test.dart';
import 'package:pats_space/core/services/app_rating_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _FakeReviewRequester requester;
  late DateTime now;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    requester = _FakeReviewRequester();
    now = DateTime(2026, 10, 3);
  });

  AppRatingService createService() => AppRatingService(
    preferences: SharedPreferences.getInstance(),
    requester: requester,
    now: () => now,
  );

  test('shows the custom prompt after two successful focus sessions', () async {
    final service = createService();

    expect(await service.shouldShowCustomPromptAfterFocusSession(), isFalse);
    expect(await service.shouldShowCustomPromptAfterFocusSession(), isTrue);
  });

  test('shows the custom prompt after the second completed bloom', () async {
    final service = createService();

    expect(await service.shouldShowCustomPromptAfterBloom(1), isFalse);
    expect(await service.shouldShowCustomPromptAfterBloom(2), isTrue);
  });

  test(
    'uses the native prompt after three sessions when custom is suppressed',
    () async {
      final service = createService();

      for (var index = 0; index < 2; index += 1) {
        final showCustom = await service
            .shouldShowCustomPromptAfterFocusSession();
        await service.maybeRequestNativeReviewAfterFocusSession(
          suppressPrompt: showCustom,
        );
      }
      final showCustom = await service
          .shouldShowCustomPromptAfterFocusSession();
      await service.maybeRequestNativeReviewAfterFocusSession(
        suppressPrompt: showCustom,
      );

      expect(showCustom, isFalse);
      expect(requester.requestCount, 1);
    },
  );

  test('opens the Patsspace App Store listing', () async {
    final service = createService();

    expect(await service.openStoreReviewPage(), isTrue);
    expect(requester.lastAppStoreId, '6806823049');
  });
}

class _FakeReviewRequester implements AppReviewRequester {
  var requestCount = 0;
  String? lastAppStoreId;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> openStoreListing({required String appStoreId}) async {
    lastAppStoreId = appStoreId;
  }

  @override
  Future<void> requestReview() async {
    requestCount += 1;
  }
}
