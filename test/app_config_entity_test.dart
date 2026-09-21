import 'package:flutter_test/flutter_test.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';

void main() {
  group('AppConfigEntity isEnabledForVersion tests', () {
    test('when master switch is false, always returns false', () {
      const config = AppConfigEntity(
        subscriptionsEnabledIos: false,
        subscriptionsEnabledAndroid: true,
      );

      expect(config.isEnabledForVersion('1.0.5', isIOS: true), isFalse);
      expect(config.isEnabledForVersion('1.0.5', isIOS: false), isTrue);
    });

    test('when version is in blocked list, returns false', () {
      const config = AppConfigEntity(
        subscriptionsEnabledIos: true,
        subscriptionsBlockedVersionsIos: '1.0.6, 1.0.7',
      );

      expect(config.isEnabledForVersion('1.0.6', isIOS: true), isFalse);
      expect(config.isEnabledForVersion('1.0.6+10', isIOS: true), isFalse);
      expect(config.isEnabledForVersion('1.0.7', isIOS: true), isFalse);
      expect(config.isEnabledForVersion('1.0.5', isIOS: true), isTrue);
      expect(config.isEnabledForVersion('1.0.8', isIOS: true), isTrue);
    });

    test('when min version is configured, blocks older versions', () {
      const config = AppConfigEntity(
        subscriptionsEnabledIos: true,
        subscriptionsMinVersionIos: '1.0.5',
      );

      expect(config.isEnabledForVersion('1.0.4', isIOS: true), isFalse);
      expect(config.isEnabledForVersion('1.0.5', isIOS: true), isTrue);
      expect(config.isEnabledForVersion('1.0.5+12', isIOS: true), isTrue);
      expect(config.isEnabledForVersion('1.0.6', isIOS: true), isTrue);
    });

    test('when isSubscriptionsEnabled is explicitly set, respects it', () {
      const config = AppConfigEntity(
        subscriptionsEnabledIos: true,
        isSubscriptionsEnabled: false,
      );

      expect(config.isEnabledForVersion('1.0.5', isIOS: true), isFalse);
    });
  });
}
