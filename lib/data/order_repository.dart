import '../models/laundry_order.dart';
import 'app_database.dart';

/// Operasi CRUD untuk tabel laundry_orders.
class OrderRepository {
  Future<List<LaundryOrder>> ambilSemua() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('laundry_orders', orderBy: 'updated_at DESC');
    return rows.map(LaundryOrder.fromMap).toList();
  }

  Future<int> simpan(LaundryOrder order) async {
    final db = await AppDatabase.instance;
    final values = order.toMap()..remove('id');
    return db.insert('laundry_orders', values);
  }

  Future<int> ubah(LaundryOrder order) async {
    final db = await AppDatabase.instance;
    return db.update(
      'laundry_orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> ubahStatus(int id, String statusBaru) async {
    final db = await AppDatabase.instance;
    return db.update(
      'laundry_orders',
      {
        'status': statusBaru,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapus(int id) async {
    final db = await AppDatabase.instance;
    return db.delete('laundry_orders', where: 'id = ?', whereArgs: [id]);
  }
}
