import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/laundry_order.dart';

/// Pengelola koneksi SQLite. Database dibuat sekali lalu digunakan ulang.
class AppDatabase {
  static const _namaDatabase = 'freshwash_laundry.db';
  static const _versi = 1;

  static Database? _database;

  static Future<Database> get instance async {
    final existing = _database;
    if (existing != null) return existing;

    final path = join(await getDatabasesPath(), _namaDatabase);
    final db = await openDatabase(
      path,
      version: _versi,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _buatTabel,
      onUpgrade: _upgradeTabel,
    );
    _database = db;
    return db;
  }

  static Future<void> _buatTabel(Database db, int version) async {
    await db.execute('''
      CREATE TABLE laundry_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_no TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        service_name TEXT NOT NULL,
        service_category TEXT NOT NULL,
        speed_option TEXT NOT NULL,
        fragrance TEXT NOT NULL,
        weight_kg REAL NOT NULL,
        total_price INTEGER NOT NULL,
        status TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        notes TEXT NOT NULL,
        address TEXT,
        latitude REAL,
        longitude REAL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'PENDING'
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_orders_updated_at ON laundry_orders(updated_at)',
    );
    await db.execute(
      'CREATE INDEX idx_orders_status ON laundry_orders(status)',
    );

    await _seedAwal(db);
  }

  static Future<void> _upgradeTabel(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Disiapkan untuk migrasi skema di masa depan (Latihan Mandiri Hari 1).
  }

  static Future<void> _seedAwal(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final seeds = [
      LaundryOrder(
        invoiceNo: '#FW-9042',
        customerName: 'Ibu Rina Melati',
        customerPhone: '0812-9844-3321',
        serviceName: 'Cuci Kering Setrika',
        serviceCategory: 'Kiloan Reguler',
        speedOption: 'Reguler (2 Hari)',
        fragrance: 'Lavender Blossom',
        weightKg: 6.5,
        totalPrice: 52000,
        status: OrderStatus.proses,
        paymentStatus: 'LUNAS • QRIS',
        notes: 'Sedang dikeringkan (Mesin D-02) • Pisahkan baju putih',
        address: 'Jl. Anggrek No. 14, Cipete Selatan, Jakarta Selatan',
        latitude: -6.2768,
        longitude: 106.8036,
        updatedAt: now - 600000,
      ),
      LaundryOrder(
        invoiceNo: '#FW-9041',
        customerName: 'Dimas Anggara',
        customerPhone: '0857-1923-4411',
        serviceName: 'Cuci Kering Setrika',
        serviceCategory: 'Express 4 Jam',
        speedOption: 'Express 3 Jam',
        fragrance: 'Ocean Fresh',
        weightKg: 3.2,
        totalPrice: 48000,
        status: OrderStatus.proses,
        paymentStatus: 'COD / Tagihan',
        notes: 'Tahap Setrika Uap (Meja 03) • 12 Pcs Kemeja + Hanger',
        address: 'Apartemen Cipete Tower B, Unit 12-A, Jakarta Selatan',
        latitude: -6.2695,
        longitude: 106.8072,
        updatedAt: now - 1200000,
      ),
      LaundryOrder(
        invoiceNo: '#FW-9039',
        customerName: 'dr. Sarah Lestari',
        customerPhone: '0818-0922-8172',
        serviceName: 'Bed Cover Jumbo',
        serviceCategory: 'Satuan & Bedcover',
        speedOption: 'Kilat (1 Hari)',
        fragrance: 'Baby Soft',
        weightKg: 8.0,
        totalPrice: 115000,
        status: OrderStatus.siapAmbil,
        paymentStatus: 'LUNAS • BCA',
        notes: 'Rak Pengambilan B-04 • Plastik Vacuum Tebal',
        address: 'Jl. Damai Raya No. 45, Samping Klinik Medika, Cipete',
        latitude: -6.2731,
        longitude: 106.8115,
        updatedAt: now - 2400000,
      ),
      LaundryOrder(
        invoiceNo: '#FW-9035',
        customerName: 'Hotel Citra Garden',
        customerPhone: '021-7590-8821',
        serviceName: 'Cuci Kering Lipat',
        serviceCategory: 'Kiloan Reguler',
        speedOption: 'Reguler (2 Hari)',
        fragrance: 'Ocean Fresh',
        weightKg: 24.5,
        totalPrice: 350000,
        status: OrderStatus.antrean,
        paymentStatus: 'Tempo 7 Hari',
        notes: '45 Pcs Linen / Duvet • Disinfeksi Standar RS',
        address: 'Jl. Pangeran Antasari No. 88, Cilandak, Jakarta Selatan',
        latitude: -6.2842,
        longitude: 106.8091,
        updatedAt: now - 3600000,
      ),
    ];

    for (final order in seeds) {
      final values = order.toMap()..remove('id');
      await db.insert('laundry_orders', values);
    }
  }
}
