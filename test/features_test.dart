import 'package:flutter_test/flutter_test.dart';
import 'package:kollektivo/models/partner.dart';
import 'package:kollektivo/services/location_service.dart';
import 'package:kollektivo/services/voucher_token_service.dart';

void main() {
  group('VoucherTokenService (Anti-screenshot rotating tokens)', () {
    test('Generates server-simulated signed token with expiry', () async {
      final service = VoucherTokenService();
      final token = await service.fetchRedemptionToken(
        ttlSeconds: 20,
        employeeId: 'EMP-TEST-1',
      );

      expect(token.token, startsWith('prf.'));
      expect(token.ttlSeconds, 20);
      expect(token.isExpired, isFalse);
      expect(token.remainingSeconds, inInclusiveRange(18, 20));
      expect(token.remainingRatio, inInclusiveRange(0.8, 1.0));
    });

    test('Throws error when network simulation fails', () async {
      final service = VoucherTokenService();
      expect(
        () => service.fetchRedemptionToken(simulateFailure: true),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PartnerModel & Opening Hours Logic', () {
    test('Accurately detects open vs closed hours', () {
      final hours = {
        1: const DayHours(openHour: 9, openMinute: 0, closeHour: 17, closeMinute: 0),
      };

      final partner = PartnerModel(
        id: 'test_p',
        name: 'Test Cafe',
        category: 'Cafe',
        icon: PartnerModel.samplePartners.first.icon,
        categoryColor: PartnerModel.samplePartners.first.categoryColor,
        address: '123 Test St',
        latitude: 37.78,
        longitude: -122.40,
        weeklyOpeningHours: hours,
      );

      // Monday at 11:30 AM -> Open
      final mondayOpen = DateTime(2026, 9, 21, 11, 30); // 2026-09-21 is Monday
      expect(partner.isOpenNow(mondayOpen), isTrue);
      expect(partner.getOpenStatus(mondayOpen), contains('Open now'));

      // Monday at 8:00 AM -> Closed (Opens 9:00 AM)
      final mondayEarly = DateTime(2026, 9, 21, 8, 0);
      expect(partner.isOpenNow(mondayEarly), isFalse);
      expect(partner.getOpenStatus(mondayEarly), contains('Opens 9:00 AM'));

      // Monday at 7:00 PM -> Closed
      final mondayLate = DateTime(2026, 9, 21, 19, 0);
      expect(partner.isOpenNow(mondayLate), isFalse);
      expect(partner.getOpenStatus(mondayLate), contains('Closed for today'));
    });
  });

  group('LocationService & Distance Calculation', () {
    test('Calculates distance in kilometers correctly', () {
      final service = LocationService();

      // Market St to Howard St (roughly 0.3 - 0.5 km)
      final dist = service.calculateDistanceInKm(
        startLatitude: 37.789172,
        startLongitude: -122.401449,
        endLatitude: 37.786521,
        endLongitude: -122.398912,
      );

      expect(dist, greaterThan(0.2));
      expect(dist, lessThan(1.0));
    });
  });
}
