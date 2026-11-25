import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_apps/models/laundry_order.dart';

void main() {
  group('LaundryOrder serialization', () {
    test('toMap dan fromMap menjaga semua field termasuk koordinat', () {
      final original = LaundryOrder(
        id: 7,
        invoiceNo: '#FW-9100',
        customerName: 'Bpk. Rizky Pratama',
        customerPhone: '0812-3456-7890',
        serviceName: 'Cuci Kering Setrika',
        serviceCategory: 'Kiloan Reguler',
        speedOption: 'Kilat (1 Hari)',
        fragrance: 'Ocean Fresh',
        weightKg: 4.8,
        totalPrice: 39060,
        status: OrderStatus.antrean,
        paymentStatus: 'LUNAS • QRIS',
        notes: 'Pisah baju putih',
        address: 'Jl. Cipete Raya No. 10',
        latitude: -6.2768,
        longitude: 106.8036,
        updatedAt: 1700000000000,
      );

      final restored = LaundryOrder.fromMap(original.toMap());
      expect(restored.id, 7);
      expect(restored.invoiceNo, '#FW-9100');
      expect(restored.customerName, 'Bpk. Rizky Pratama');
      expect(restored.serviceCategory, 'Kiloan Reguler');
      expect(restored.weightKg, 4.8);
      expect(restored.totalPrice, 39060);
      expect(restored.latitude, closeTo(-6.2768, 0.00001));
      expect(restored.longitude, closeTo(106.8036, 0.00001));
      expect(restored.syncStatus, 'PENDING');
    });
  });

  group('hitungTotalPos & formatRupiah', () {
    test('menghitung total dengan kecepatan kilat dan diskon 10%', () {
      final total = hitungTotalPos(
        pricePerUnit: 8000,
        quantity: 4.8,
        speedFee: 5000,
        discountPercent: 0.10,
      );
      expect(total, 39060);
      expect(formatRupiah(total), 'Rp 39.060');
    });
  });
}
