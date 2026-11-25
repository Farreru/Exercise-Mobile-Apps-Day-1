import 'package:flutter/foundation.dart';

import '../data/order_repository.dart';
import '../models/laundry_order.dart';

/// State pesanan laundry menggunakan ChangeNotifier (pola Hari 1).
class OrderController extends ChangeNotifier {
  OrderController({OrderRepository? repository})
      : _repository = repository ?? OrderRepository();

  /// Instance bersama agar Dashboard, Pesanan, POS, dan Logistik selalu sinkron.
  static final OrderController shared = OrderController();

  final OrderRepository _repository;
  List<LaundryOrder> _orders = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<LaundryOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  int get totalOmset =>
      _orders.fold<int>(0, (sum, item) => sum + item.totalPrice);

  double get totalKg =>
      _orders.fold<double>(0, (sum, item) => sum + item.weightKg);

  int countByStatus(String status) =>
      _orders.where((item) => item.status == status).length;

  LaundryOrder? get urgentExpressOrder {
    for (final order in _orders) {
      if (order.isExpress && order.status != OrderStatus.selesai) {
        return order;
      }
    }
    return _orders.isNotEmpty ? _orders.first : null;
  }

  Future<void> loadIfNeeded() async {
    if (_hasLoaded || _isLoading) return;
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.ambilSemua();
      _hasLoaded = true;
    } catch (e) {
      _error = 'Gagal memuat pesanan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambah(LaundryOrder order) async {
    await _repository.simpan(order);
    await load();
  }

  Future<void> ubahStatus(int id, String statusBaru) async {
    await _repository.ubahStatus(id, statusBaru);
    await load();
  }

  Future<void> majuStatus(LaundryOrder order) async {
    final id = order.id;
    if (id == null) return;
    final next = OrderStatus.next(order.status);
    await ubahStatus(id, next);
  }

  Future<void> hapus(int id) async {
    await _repository.hapus(id);
    await load();
  }
}
