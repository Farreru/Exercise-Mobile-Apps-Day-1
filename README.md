# FreshWash Laundry Admin — Exercise Mobile Apps Day 1

Aplikasi manajemen admin laundry (**FreshWash / FreshFlow Modern Laundry OS**) berbasis **Flutter** sebagai implementasi **Hands-On Hari 1 — Associate Mobile Programmer**: dasar Flutter, navigasi `go_router`, database lokal SQLite (`sqflite`), layanan GPS (`geolocator`), peta interaktif OpenStreetMap (`flutter_map`), reverse geocoding Nominatim, perhitungan jarak Haversine, dan unit testing.

## Fitur Utama

- **Dashboard Admin (`/`)**: Ringkasan omset & kapasitas cucian (Kg) real-time dari SQLite, circular progress ring, aksi cepat kasir, highlight pesanan Express, filter alur kerja, dan banner telemetri air & detergen.
- **Manajemen Pesanan (`/pesanan`)**: CRUD penuh ke SQLite (`freshwash_laundry.db`), pencarian nota/pelanggan, filter status & kategori layanan, pembaruan tahap pengerjaan, serta perhitungan jarak Haversine dan pengurutan dari lokasi terdekat.
- **POS Baru (`/pos-baru`)**: Form input pesanan dengan validasi, pilihan 6 paket layanan, timbangan digital interaktif (`-`/`+` & preset berat), pilihan kecepatan pengerjaan & aroma parfum, kalkulasi total + diskon otomatis, serta tombol **Ambil Lokasi Saat Ini** (GPS + alamat Nominatim).
- **Rute Logistik & Kurir (`/logistik`)**: Peta OpenStreetMap interaktif (`FlutterMap`), marker Outlet Pusat, marker titik antar dari SQLite, posisi GPS kurir + mode **Live GPS** (`pantauPosisi`), alamat hasil reverse geocoding, dan daftar rute terurut berdasarkan jarak terdekat.
- **Mesin & Operasional (`/mesin`)**: Monitoring status mesin cuci & pengering (Jeda/Lanjut/Reset) serta stok bahan baku outlet.
- **Katalog & Pelanggan (`/katalog`)**: Daftar tarif layanan dengan toggle aktif/non-aktif dan ringkasan pelanggan dari transaksi lokal.

## Teknologi & Dependensi

- **Flutter** & **Material 3** (tema FreshFlow Modern Laundry OS + font *Plus Jakarta Sans* via `google_fonts`)
- **Navigasi**: `go_router` (`StatefulShellRoute.indexedStack`)
- **Database Lokal**: `sqflite` & `path`
- **Lokasi & Peta**: `geolocator`, `flutter_map`, `latlong2`, `http` (Nominatim OpenStreetMap)

## Struktur Proyek

```text
lib/
├── main.dart
├── app.dart
├── theme/freshflow_theme.dart
├── router/app_router.dart
├── models/laundry_order.dart
├── data/
│   ├── app_database.dart
│   └── order_repository.dart
├── blocs/order_controller.dart
├── services/
│   ├── distance.dart
│   └── location_service.dart
├── widgets/freshflow_shell.dart
└── pages/
    ├── dashboard_page.dart
    ├── orders_page.dart
    ├── pos_form_page.dart
    ├── logistics_page.dart
    ├── machines_page.dart
    └── catalog_page.dart
test/
├── distance_test.dart
└── order_model_test.dart
```

## Cara Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Untuk menjalankan dalam mode release:

```bash
flutter run --release
```

> **Catatan Emulator Android:** Lokasi GPS default emulator berada di Mountain View, California. Untuk simulasi di sekitar Outlet Pusat (Cipete, Jakarta Selatan), atur lokasi melalui *Extended Controls (`...`) -> Location* atau jalankan:
> ```bash
> adb emu geo fix 106.8050 -6.2740
> ```
