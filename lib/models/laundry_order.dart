/// Status tahapan pengerjaan pesanan laundry.
class OrderStatus {
  const OrderStatus._();

  static const String antrean = 'ANTREAN';
  static const String proses = 'PROSES';
  static const String siapAmbil = 'SIAP_AMBIL';
  static const String selesai = 'SELESAI';

  static const List<String> all = [antrean, proses, siapAmbil, selesai];

  static String label(String status) {
    switch (status) {
      case antrean:
        return 'Antrean';
      case proses:
        return 'Proses';
      case siapAmbil:
        return 'Siap Ambil';
      case selesai:
        return 'Selesai';
      default:
        return status;
    }
  }

  static String next(String status) {
    switch (status) {
      case antrean:
        return proses;
      case proses:
        return siapAmbil;
      case siapAmbil:
        return selesai;
      default:
        return selesai;
    }
  }

  static double progress(String status) {
    switch (status) {
      case antrean:
        return 0.2;
      case proses:
        return 0.6;
      case siapAmbil:
        return 0.9;
      case selesai:
        return 1.0;
      default:
        return 0.0;
    }
  }
}

/// Model data pesanan laundry (adaptasi domain dari model Note Hari 1).
class LaundryOrder {
  const LaundryOrder({
    this.id,
    required this.invoiceNo,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.serviceCategory,
    required this.speedOption,
    required this.fragrance,
    required this.weightKg,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.notes,
    this.address,
    this.latitude,
    this.longitude,
    required this.updatedAt,
    this.syncStatus = 'PENDING',
  });

  /// Membuat pesanan baru dengan timestamp saat ini dan nomor nota otomatis.
  factory LaundryOrder.baru({
    String? invoiceNo,
    required String customerName,
    required String customerPhone,
    required String serviceName,
    required String serviceCategory,
    required String speedOption,
    required String fragrance,
    required double weightKg,
    required int totalPrice,
    String status = OrderStatus.antrean,
    String paymentStatus = 'LUNAS • QRIS',
    String notes = '',
    String? address,
    double? latitude,
    double? longitude,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final generatedNo = invoiceNo ?? '#FW-${(now % 9000) + 1000}';
    return LaundryOrder(
      invoiceNo: generatedNo,
      customerName: customerName,
      customerPhone: customerPhone,
      serviceName: serviceName,
      serviceCategory: serviceCategory,
      speedOption: speedOption,
      fragrance: fragrance,
      weightKg: weightKg,
      totalPrice: totalPrice,
      status: status,
      paymentStatus: paymentStatus,
      notes: notes,
      address: address,
      latitude: latitude,
      longitude: longitude,
      updatedAt: now,
    );
  }

  final int? id;
  final String invoiceNo;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String serviceCategory;
  final String speedOption;
  final String fragrance;
  final double weightKg;
  final int totalPrice;
  final String status;
  final String paymentStatus;
  final String notes;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int updatedAt;
  final String syncStatus;

  bool get isExpress => speedOption.toLowerCase().contains('express');
  bool get isPaid => paymentStatus.toUpperCase().contains('LUNAS');
  bool get hasLocation => latitude != null && longitude != null;

  LaundryOrder copyWith({
    int? id,
    String? invoiceNo,
    String? customerName,
    String? customerPhone,
    String? serviceName,
    String? serviceCategory,
    String? speedOption,
    String? fragrance,
    double? weightKg,
    int? totalPrice,
    String? status,
    String? paymentStatus,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    int? updatedAt,
    String? syncStatus,
  }) {
    return LaundryOrder(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      speedOption: speedOption ?? this.speedOption,
      fragrance: fragrance ?? this.fragrance,
      weightKg: weightKg ?? this.weightKg,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'service_category': serviceCategory,
      'speed_option': speedOption,
      'fragrance': fragrance,
      'weight_kg': weightKg,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'notes': notes,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory LaundryOrder.fromMap(Map<String, Object?> map) {
    return LaundryOrder(
      id: map['id'] as int?,
      invoiceNo: map['invoice_no'] as String,
      customerName: map['customer_name'] as String,
      customerPhone: map['customer_phone'] as String,
      serviceName: map['service_name'] as String,
      serviceCategory: map['service_category'] as String,
      speedOption: map['speed_option'] as String,
      fragrance: map['fragrance'] as String,
      weightKg: (map['weight_kg'] as num).toDouble(),
      totalPrice: map['total_price'] as int,
      status: map['status'] as String,
      paymentStatus: map['payment_status'] as String,
      notes: map['notes'] as String,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      updatedAt: map['updated_at'] as int,
      syncStatus: map['sync_status'] as String? ?? 'PENDING',
    );
  }
}

/// Menghitung total biaya POS berdasarkan tarif satuan, jumlah/berat,
/// biaya tambahan kecepatan, dan diskon member.
int hitungTotalPos({
  required int pricePerUnit,
  required double quantity,
  required int speedFee,
  double discountPercent = 0.0,
}) {
  final subtotal = (pricePerUnit * quantity).round() + speedFee;
  final discount = (subtotal * discountPercent).round();
  return subtotal - discount;
}

/// Format angka integer menjadi string Rupiah, contoh: Rp 52.000.
String formatRupiah(int amount) {
  final isNegative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final posFromRight = digits.length - i;
    buffer.write(digits[i]);
    if (posFromRight > 1 && posFromRight % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${isNegative ? '-' : ''}Rp $buffer';
}
