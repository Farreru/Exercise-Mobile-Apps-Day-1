import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../blocs/order_controller.dart';
import '../models/laundry_order.dart';
import '../services/location_service.dart';
import '../theme/freshflow_theme.dart';
import '../widgets/freshflow_shell.dart';

class _ServiceOption {
  const _ServiceOption({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.price,
    required this.unit,
    required this.icon,
  });

  final String name;
  final String subtitle;
  final String category;
  final int price;
  final String unit;
  final IconData icon;
}

class _SpeedOption {
  const _SpeedOption({
    required this.name,
    required this.subtitle,
    required this.extraFee,
    this.isPopular = false,
  });

  final String name;
  final String subtitle;
  final int extraFee;
  final bool isPopular;
}

/// Halaman POS Baru / Input Pesanan (adaptasi dari NoteFormPage Hands-On Hari 1).
class PosFormPage extends StatefulWidget {
  const PosFormPage({super.key});

  @override
  State<PosFormPage> createState() => _PosFormPageState();
}

class _PosFormPageState extends State<PosFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _catatanController = TextEditingController();
  final _location = LocationService();
  final _orderController = OrderController.shared;

  static const _services = [
    _ServiceOption(
      name: 'Cuci Kering Setrika',
      subtitle: 'Kiloan Lengkap',
      category: 'Kiloan Reguler',
      price: 8000,
      unit: '/kg',
      icon: Icons.local_laundry_service_rounded,
    ),
    _ServiceOption(
      name: 'Cuci Kering Lipat',
      subtitle: 'Tanpa Setrika',
      category: 'Kiloan Reguler',
      price: 6000,
      unit: '/kg',
      icon: Icons.inventory_2_outlined,
    ),
    _ServiceOption(
      name: 'Setrika Steam',
      subtitle: 'Uap Anti Kusut',
      category: 'Kiloan Reguler',
      price: 5000,
      unit: '/kg',
      icon: Icons.iron_rounded,
    ),
    _ServiceOption(
      name: 'Jas & Premium',
      subtitle: 'Dry Clean Per Pc',
      category: 'Satuan & Bedcover',
      price: 25000,
      unit: '/pcs',
      icon: Icons.checkroom_rounded,
    ),
    _ServiceOption(
      name: 'Bed Cover Jumbo',
      subtitle: 'Selimut & Sprei',
      category: 'Satuan & Bedcover',
      price: 35000,
      unit: '/pcs',
      icon: Icons.bed_rounded,
    ),
    _ServiceOption(
      name: 'Sepatu & Tas',
      subtitle: 'Deep Cleaning',
      category: 'Sepatu & Tas',
      price: 45000,
      unit: '/psg',
      icon: Icons.hiking_rounded,
    ),
  ];

  static const _speeds = [
    _SpeedOption(
      name: 'Reguler (2 Hari)',
      subtitle: 'Standar operasional outlet',
      extraFee: 0,
    ),
    _SpeedOption(
      name: 'Kilat (1 Hari)',
      subtitle: 'Selesai besok siang 12:00 WIB',
      extraFee: 5000,
      isPopular: true,
    ),
    _SpeedOption(
      name: 'Express 3 Jam',
      subtitle: 'Prioritas Washer Mesin #02',
      extraFee: 15000,
    ),
  ];

  static const _fragrances = [
    'Ocean Fresh',
    'Lavender Blossom',
    'Baby Soft',
    'Sweet Vanilla',
  ];

  static const _quickNotes = [
    'Pisah Warna Putih',
    'Jangan Kena Air Panas',
    'Lipat Hanger',
  ];

  int _selectedServiceIdx = 0;
  int _selectedSpeedIdx = 1;
  String _selectedFragrance = 'Ocean Fresh';
  double _weightKg = 4.8;
  bool _applyMemberDiscount = true;

  double? _latitude;
  double? _longitude;
  bool _mengambilLokasi = false;
  bool _menyimpan = false;

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  _ServiceOption get _service => _services[_selectedServiceIdx];
  _SpeedOption get _speed => _speeds[_selectedSpeedIdx];

  int get _baseSubtotal => (_service.price * _weightKg).round();
  int get _beforeDiscount => _baseSubtotal + _speed.extraFee;
  int get _totalPrice => hitungTotalPos(
        pricePerUnit: _service.price,
        quantity: _weightKg,
        speedFee: _speed.extraFee,
        discountPercent: _applyMemberDiscount ? 0.10 : 0.0,
      );

  void _updateWeight(double next) {
    setState(() {
      _weightKg = (next.clamp(0.5, 25.0) * 10).round() / 10;
    });
  }

  Future<void> _ambilLokasi() async {
    setState(() => _mengambilLokasi = true);
    try {
      final posisi = await _location.ambilPosisi();
      String? alamat;
      try {
        alamat = await _location.alamatDari(posisi.latitude, posisi.longitude);
      } catch (_) {
        // Alamat opsional jika offline
      }
      if (!mounted) return;
      setState(() {
        _latitude = posisi.latitude;
        _longitude = posisi.longitude;
        if (alamat != null && alamat.isNotEmpty) {
          _alamatController.text = alamat;
        }
      });
    } on LocationException catch (e) {
      _tampilkanPesan(e.pesan);
    } catch (e) {
      _tampilkanPesan('Gagal mengambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _mengambilLokasi = false);
    }
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _simpan({required bool asDraft}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      final category = _speed.name.toLowerCase().contains('express')
          ? 'Express 4 Jam'
          : _service.category;

      final order = LaundryOrder.baru(
        customerName: _namaController.text.trim(),
        customerPhone: _hpController.text.trim().isEmpty
            ? '-'
            : _hpController.text.trim(),
        serviceName: _service.name,
        serviceCategory: category,
        speedOption: _speed.name,
        fragrance: _selectedFragrance,
        weightKg: _weightKg,
        totalPrice: _totalPrice,
        status: OrderStatus.antrean,
        paymentStatus: asDraft ? 'COD / Tagihan' : 'LUNAS • QRIS',
        notes: _catatanController.text.trim(),
        address: _alamatController.text.trim().isEmpty
            ? null
            : _alamatController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      await _orderController.tambah(order);
      if (!mounted) return;

      _namaController.clear();
      _hpController.clear();
      _alamatController.clear();
      _catatanController.clear();
      setState(() {
        _latitude = null;
        _longitude = null;
      });

      _tampilkanPesan(
        'Nota ${order.invoiceNo} berhasil disimpan ke SQLite!',
      );
      context.go('/pesanan');
    } catch (e) {
      _tampilkanPesan('Gagal menyimpan pesanan: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const FreshFlowTopBar(title: 'POS Baru'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            FreshFlowTheme.margin,
            12,
            FreshFlowTheme.margin,
            32,
          ),
          children: [
            // Step Progress Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: FreshFlowColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '1',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Input Kasir POS',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: FreshFlowColors.primaryFixed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Simpan ke SQLite',
                          style: textTheme.labelSmall?.copyWith(
                            color: FreshFlowColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Isi data pelanggan, pilih paket, timbang cucian, dan ambil lokasi GPS pengantaran.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Section 1: Data Pelanggan & Lokasi GPS
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: FreshFlowColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Data Pelanggan & Lokasi',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan *',
                      hintText: 'Contoh: Bpk. Rizky Pratama',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().length < 3)
                            ? 'Nama pelanggan minimal 3 karakter'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _hpController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No. HP / WhatsApp',
                      hintText: '0812-xxxx-xxxx',
                      prefixIcon: Icon(Icons.call_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Antar / Jemput (Opsional)',
                      hintText: 'Isi manual atau klik Ambil Lokasi GPS',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: FreshFlowColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 18,
                          color: _latitude != null
                              ? FreshFlowColors.tertiary
                              : FreshFlowColors.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _latitude == null || _longitude == null
                                ? 'Koordinat GPS belum diambil (opsional)'
                                : 'GPS: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: _latitude != null
                                  ? FreshFlowColors.tertiary
                                  : FreshFlowColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _mengambilLokasi ? null : _ambilLokasi,
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(
                        color: FreshFlowColors.primaryContainer,
                      ),
                    ),
                    icon: _mengambilLokasi
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      _mengambilLokasi
                          ? 'Mengambil lokasi...'
                          : 'Ambil Lokasi Saat Ini',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Section 2: Pilihan Layanan & Paket (2-Column Grid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.dry_cleaning_rounded,
                      size: 18,
                      color: FreshFlowColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pilihan Layanan & Paket',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text('Pilih 1 Paket', style: textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.18,
              ),
              itemBuilder: (context, index) {
                final item = _services[index];
                final selected = index == _selectedServiceIdx;
                return InkWell(
                  onTap: () => setState(() => _selectedServiceIdx = index),
                  borderRadius: BorderRadius.circular(
                    FreshFlowTheme.radiusDefault,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? FreshFlowColors.primaryFixed.withValues(alpha: 0.35)
                          : FreshFlowColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        FreshFlowTheme.radiusDefault,
                      ),
                      border: selected
                          ? Border.all(
                              color: FreshFlowColors.primary,
                              width: 2,
                            )
                          : null,
                      boxShadow: FreshFlowTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: selected
                                    ? FreshFlowColors.primary
                                    : FreshFlowColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                size: 18,
                                color: selected
                                    ? Colors.white
                                    : FreshFlowColors.primary,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: selected
                                    ? FreshFlowColors.primary
                                    : FreshFlowColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.subtitle,
                              style: textTheme.labelSmall?.copyWith(
                                color: selected
                                    ? FreshFlowColors.primary
                                    : FreshFlowColors.outline,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? FreshFlowColors.primary
                                        .withValues(alpha: 0.1)
                                    : FreshFlowColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatRupiah(item.price),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: selected
                                          ? FreshFlowColors.primary
                                          : FreshFlowColors.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    item.unit,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: FreshFlowColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // Section 3: Digital Weight Scale Widget
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: FreshFlowColors.tertiaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Timbangan Digital POS',
                            style: textTheme.labelMedium?.copyWith(
                              color: FreshFlowColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _updateWeight(1.0),
                        icon: const Icon(Icons.scale_rounded, size: 16),
                        label: const Text('Reset 1.0'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: FreshFlowColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _updateWeight(_weightKg - 0.2),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: FreshFlowColors.surfaceContainerLowest,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove_rounded),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _weightKg.toStringAsFixed(1),
                                  style: textTheme.headlineLarge,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _service.unit == '/kg' ? 'Kg' : 'Qty',
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: FreshFlowColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Kapasitas Maks Mesin: 7.0 Kg',
                              style: textTheme.labelSmall?.copyWith(
                                color: FreshFlowColors.outline,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _updateWeight(_weightKg + 0.2),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: FreshFlowColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final preset in [3.0, 4.8, 6.5, 8.0]) ...[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: InkWell(
                              onTap: () => _updateWeight(preset),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _weightKg == preset
                                      ? FreshFlowColors.primaryFixed
                                      : FreshFlowColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${preset.toStringAsFixed(1)} kg',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: _weightKg == preset
                                        ? FreshFlowColors.primary
                                        : FreshFlowColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kecepatan Pengerjaan
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: FreshFlowColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kecepatan Pengerjaan',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _speeds.length; i++) ...[
                    InkWell(
                      onTap: () => setState(() => _selectedSpeedIdx = i),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _selectedSpeedIdx == i
                              ? FreshFlowColors.primaryFixed
                                  .withValues(alpha: 0.4)
                              : FreshFlowColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: _selectedSpeedIdx == i
                              ? Border.all(color: FreshFlowColors.primary)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _speeds[i].name,
                                        style: textTheme.labelMedium?.copyWith(
                                          color: _selectedSpeedIdx == i
                                              ? FreshFlowColors.primary
                                              : FreshFlowColors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_speeds[i].isPopular) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: FreshFlowColors
                                                .secondaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Populer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    _speeds[i].subtitle,
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _speeds[i].extraFee == 0
                                  ? 'Gratis'
                                  : '+${formatRupiah(_speeds[i].extraFee)}',
                              style: textTheme.labelMedium?.copyWith(
                                color: _speeds[i].extraFee == 0
                                    ? FreshFlowColors.outline
                                    : FreshFlowColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Aroma Pewangi
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilihan Aroma Pewangi',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Gratis',
                        style: textTheme.labelSmall?.copyWith(
                          color: FreshFlowColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fragrances.map((aroma) {
                      final active = _selectedFragrance == aroma;
                      return ChoiceChip(
                        label: Text(aroma),
                        selected: active,
                        selectedColor: FreshFlowColors.primary,
                        backgroundColor: FreshFlowColors.surfaceContainerHigh,
                        labelStyle: textTheme.labelMedium?.copyWith(
                          color: active
                              ? Colors.white
                              : FreshFlowColors.onSurfaceVariant,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide.none,
                        onSelected: (_) =>
                            setState(() => _selectedFragrance = aroma),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Catatan Khusus
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan & Instruksi Khusus',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Tulis instruksi khusus operator cuci...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _quickNotes.map((tag) {
                      return ActionChip(
                        label: Text('+ $tag', style: textTheme.labelSmall),
                        backgroundColor: FreshFlowColors.surfaceContainer,
                        side: BorderSide.none,
                        onPressed: () {
                          final current = _catatanController.text.trim();
                          _catatanController.text =
                              current.isEmpty ? tag : '$current, $tag';
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan Tagihan POS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FreshFlowColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                boxShadow: FreshFlowTheme.cardShadow,
              ),
              child: Column(
                children: [
                  _SummaryLine(
                    label:
                        '${_service.name} (${_weightKg.toStringAsFixed(1)} × ${formatRupiah(_service.price)})',
                    value: formatRupiah(_baseSubtotal),
                  ),
                  _SummaryLine(
                    label: _speed.name,
                    value: formatRupiah(_speed.extraFee),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Diskon Member Gold (10%)',
                      style: textTheme.bodySmall,
                    ),
                    value: _applyMemberDiscount,
                    onChanged: (v) => setState(() => _applyMemberDiscount = v),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FreshFlowColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL TAGIHAN POS',
                              style: textTheme.labelSmall,
                            ),
                            Row(
                              children: [
                                Text(
                                  formatRupiah(_totalPrice),
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: FreshFlowColors.primary,
                                  ),
                                ),
                                if (_applyMemberDiscount) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    formatRupiah(_beforeDiscount),
                                    style: textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: FreshFlowColors.outline,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        if (_applyMemberDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: FreshFlowColors.tertiaryFixed
                                  .withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Hemat ${formatRupiah(_beforeDiscount - _totalPrice)}',
                              style: textTheme.labelSmall?.copyWith(
                                color: FreshFlowColors.tertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: _menyimpan
                              ? null
                              : () => _simpan(asDraft: true),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                FreshFlowColors.surfaceContainerHigh,
                            foregroundColor: FreshFlowColors.onSurface,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Simpan COD'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: FilledButton.icon(
                          onPressed: _menyimpan
                              ? null
                              : () => _simpan(asDraft: false),
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(
                            _menyimpan ? 'Menyimpan...' : 'Bayar & Simpan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              color: FreshFlowColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
