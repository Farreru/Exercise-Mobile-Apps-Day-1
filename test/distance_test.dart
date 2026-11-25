import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_apps/services/distance.dart';

void main() {
  group('jarakMeter', () {
    test('titik yang sama menghasilkan nol', () {
      expect(
        jarakMeter(-6.9175, 107.6191, -6.9175, 107.6191),
        closeTo(0, 0.001),
      );
    });

    test('jarak Jakarta ke Bandung sekitar 120 km', () {
      final km = jarakMeter(-6.2088, 106.8456, -6.9175, 107.6191) / 1000;
      expect(km, closeTo(120, 10));
    });

    test('jarak tidak bergantung pada urutan titik', () {
      final a = jarakMeter(-6.2, 106.8, -6.9, 107.6);
      final b = jarakMeter(-6.9, 107.6, -6.2, 106.8);
      expect(a, closeTo(b, 0.001));
    });
  });

  group('formatJarak', () {
    test('menampilkan meter untuk jarak di bawah 1 km', () {
      expect(formatJarak(450.4), '450 m');
    });

    test('menampilkan kilometer untuk jarak 1 km ke atas', () {
      expect(formatJarak(2450), '2.45 km');
    });
  });
}
