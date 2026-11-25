import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../blocs/order_controller.dart';
import '../models/laundry_order.dart';
import '../services/distance.dart';
import '../services/location_service.dart';
import '../theme/freshflow_theme.dart';
import '../widgets/freshflow_shell.dart';

/// Halaman Manajemen Pesanan Laundry (adaptasi dari NotesPage Hands-On Hari 1).
/// Mendukung CRUD SQLite, pencarian, filter status & kategori, serta perhitungan
/// jarak Haversine & pengurutan terdekat dari lokasi GPS pengguna.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _controller = OrderController.shared;
  final _location = LocationService();
  final _searchController = TextEditingController();

  Position? _posisi;
  bool _memuatLokasi = false;
  bool _urutTerdekat = false;
  String _statusFilter = 'ALL';
  String _categoryFilter = 'Semua Layanan';

  static const _categories = [
    'Semua Layanan',
    'Kiloan Reguler',
    'Express 4 Jam',
    'Satuan & Bedcover',
    'Sepatu & Tas',
  ];

  @override
  void initState() {
    super.initState();
    _controller.loadIfNeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _perbaruiPosisi() async {
    setState(() => _memuatLokasi = true);
    try {
      final posisi = await _location.ambilPosisi();
      if (!mounted) return;
      setState(() => _posisi = posisi);
      _tampilkanPesan(
        'Lokasi diperbarui (${posisi.latitude.toStringAsFixed(4)}, ${posisi.longitude.toStringAsFixed(4)})',
      );
    } on LocationException catch (e) {
      _tampilkanPesan(e.pesan);
    } catch (e) {
      _tampilkanPesan('Gagal mengambil posisi: $e');
    } finally {
      if (mounted) setState(() => _memuatLokasi = false);
    }
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  double? _jarakOrder(LaundryOrder order) {
    final pos = _posisi;
    if (pos == null || !order.hasLocation) return null;
    return jarakMeter(
      pos.latitude,
      pos.longitude,
      order.latitude!,
      order.longitude!,
    );
  }

  List<LaundryOrder> _filteredOrders() {
    final query = _searchController.text.trim().toLowerCase();
    final list = _controller.orders.where((order) {
      if (_statusFilter != 'ALL' && order.status != _statusFilter) {
        return false;
      }
      if (_categoryFilter != 'Semua Layanan' &&
          order.serviceCategory != _categoryFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = order.customerName.toLowerCase().contains(query);
        final matchNo = order.invoiceNo.toLowerCase().contains(query);
        final matchPhone = order.customerPhone.toLowerCase().contains(query);
        if (!matchName && !matchNo && !matchPhone) return false;
      }
      return true;
    }).toList();

    if (_urutTerdekat && _posisi != null) {
      list.sort((a, b) {
        final da = _jarakOrder(a) ?? double.infinity;
        final db = _jarakOrder(b) ?? double.infinity;
        return da.compareTo(db);
      });
    }
    return list;
  }

  Future<void> _konfirmasiHapus(LaundryOrder order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan?'),
        content: Text(
          'Nota ${order.invoiceNo} atas nama ${order.customerName} akan dihapus permanen dari SQLite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FreshFlowColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && order.id != null) {
      await _controller.hapus(order.id!);
      _tampilkanPesan('Pesanan ${order.invoiceNo} dihapus.');
    }
  }

  void _bukaDetail(LaundryOrder order) {
    final jarak = _jarakOrder(order);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: FreshFlowColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.customerName, style: textTheme.headlineMedium),
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
                      order.invoiceNo,
                      style: textTheme.labelMedium?.copyWith(
                        color: FreshFlowColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order.customerPhone} • ${order.serviceName} (${order.weightKg.toStringAsFixed(1)} Kg)',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'Kategori', value: order.serviceCategory),
              _DetailRow(label: 'Kecepatan', value: order.speedOption),
              _DetailRow(label: 'Parfum', value: order.fragrance),
              _DetailRow(label: 'Pembayaran', value: order.paymentStatus),
              _DetailRow(
                label: 'Total Tagihan',
                value: formatRupiah(order.totalPrice),
              ),
              if (order.address != null && order.address!.isNotEmpty)
                _DetailRow(label: 'Alamat', value: order.address!),
              if (order.hasLocation)
                _DetailRow(
                  label: 'Koordinat GPS',
                  value:
                      '${order.latitude!.toStringAsFixed(5)}, ${order.longitude!.toStringAsFixed(5)}'
                      '${jarak != null ? ' (${formatJarak(jarak)})' : ''}',
                ),
              if (order.notes.isNotEmpty)
                _DetailRow(label: 'Catatan', value: order.notes),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _konfirmasiHapus(order);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FreshFlowColors.error,
                        side: const BorderSide(color: FreshFlowColors.error),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Hapus'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: order.status == OrderStatus.selesai
                          ? null
                          : () async {
                              await _controller.majuStatus(order);
                              if (context.mounted) Navigator.pop(context);
                            },
                      icon: const Icon(Icons.update_rounded, size: 18),
                      label: Text(
                        order.status == OrderStatus.selesai
                            ? 'Sudah Selesai'
                            : 'Ke ${OrderStatus.label(OrderStatus.next(order.status))}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: FreshFlowTopBar(
        title: 'Pesanan',
        actions: [
          Tooltip(
            message: 'Perbarui posisi GPS untuk hitung jarak',
            child: InkWell(
              onTap: _memuatLokasi ? null : _perbaruiPosisi,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _posisi != null
                      ? FreshFlowColors.primaryFixed
                      : FreshFlowColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: _memuatLokasi
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.my_location_rounded,
                        size: 20,
                        color: _posisi != null
                            ? FreshFlowColors.primary
                            : FreshFlowColors.onSurfaceVariant,
                      ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final filtered = _filteredOrders();
          final urgentCount = _controller.orders
              .where((o) => o.isExpress && o.status != OrderStatus.selesai)
              .length;

          return RefreshIndicator(
            onRefresh: _controller.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                FreshFlowTheme.margin,
                12,
                FreshFlowTheme.margin,
                28,
              ),
              children: [
                // Search & Sort Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: FreshFlowColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: FreshFlowTheme.cardShadow,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Cari No. Nota, Nama, No. HP...',
                            prefixIcon: Icon(Icons.search_rounded, size: 20),
                            filled: false,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Urutkan dari jarak terdekat',
                      child: InkWell(
                        onTap: () async {
                          if (_posisi == null) {
                            await _perbaruiPosisi();
                          }
                          if (_posisi != null) {
                            setState(() => _urutTerdekat = !_urutTerdekat);
                          }
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _urutTerdekat
                                ? FreshFlowColors.primaryContainer
                                : FreshFlowColors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            boxShadow: FreshFlowTheme.cardShadow,
                          ),
                          child: Icon(
                            Icons.near_me_rounded,
                            size: 20,
                            color: _urutTerdekat
                                ? Colors.white
                                : FreshFlowColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Segmented Tabs
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatusTab(
                        label: 'Semua',
                        count: _controller.orders.length,
                        selected: _statusFilter == 'ALL',
                        onTap: () => setState(() => _statusFilter = 'ALL'),
                      ),
                      const SizedBox(width: 6),
                      for (final status in OrderStatus.all) ...[
                        _StatusTab(
                          label: OrderStatus.label(status),
                          count: _controller.countByStatus(status),
                          selected: _statusFilter == status,
                          onTap: () => setState(() => _statusFilter = status),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Category Sub-filter
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final active = _categoryFilter == cat;
                      return InkWell(
                        onTap: () => setState(() => _categoryFilter = cat),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? FreshFlowColors.surfaceContainerHighest
                                : FreshFlowColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            cat,
                            style: textTheme.labelSmall?.copyWith(
                              color: active
                                  ? FreshFlowColors.primary
                                  : FreshFlowColors.onSurfaceVariant,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Operational Flow Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: FreshFlowColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                            FreshFlowTheme.radiusDefault,
                          ),
                          boxShadow: FreshFlowTheme.cardShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BEBAN KERJA',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: FreshFlowColors.outline,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_controller.orders.length} Nota',
                                  style: textTheme.headlineMedium,
                                ),
                                Text(
                                  '${_controller.totalKg.toStringAsFixed(1)} Kg Total',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: FreshFlowColors.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const CircularProgressRing(
                              progress: 0.78,
                              size: 46,
                              strokeWidth: 4.5,
                              child: Icon(
                                Icons.local_laundry_service_rounded,
                                size: 18,
                                color: FreshFlowColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              FreshFlowColors.surfaceContainerLow,
                              FreshFlowColors.surfaceContainerHighest,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            FreshFlowTheme.radiusDefault,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PERHATIAN SLA',
                              style: textTheme.labelSmall?.copyWith(
                                color: FreshFlowColors.secondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$urgentCount Express',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: urgentCount > 0 ? 0.8 : 0.2,
                                minHeight: 5,
                                backgroundColor: FreshFlowColors.surfaceContainer,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  FreshFlowColors.secondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_controller.error != null)
                  Center(child: Text(_controller.error!))
                else if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: FreshFlowColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        FreshFlowTheme.radiusLg,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: FreshFlowColors.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada pesanan yang cocok.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => context.go('/pos-baru'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Buat Pesanan Baru'),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderQueueCard(
                        order: order,
                        distanceMeters: _jarakOrder(order),
                        onDetail: () => _bukaDetail(order),
                        onAdvance: () async {
                          await _controller.majuStatus(order);
                          _tampilkanPesan(
                            'Order ${order.invoiceNo} dialihkan ke ${OrderStatus.label(OrderStatus.next(order.status))}',
                          );
                        },
                        onDelete: () => _konfirmasiHapus(order),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? FreshFlowColors.secondaryContainer
              : FreshFlowColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: selected
                    ? Colors.white
                    : FreshFlowColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : FreshFlowColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: textTheme.labelSmall?.copyWith(
                  color: selected
                      ? Colors.white
                      : FreshFlowColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderQueueCard extends StatelessWidget {
  const _OrderQueueCard({
    required this.order,
    required this.distanceMeters,
    required this.onDetail,
    required this.onAdvance,
    required this.onDelete,
  });

  final LaundryOrder order;
  final double? distanceMeters;
  final VoidCallback onDetail;
  final VoidCallback onAdvance;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDone = order.status == OrderStatus.selesai;

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialAvatar(
                name: order.customerName,
                size: 42,
                backgroundColor: order.isExpress
                    ? FreshFlowColors.secondaryFixed
                    : FreshFlowColors.primaryFixed,
                foregroundColor: order.isExpress
                    ? FreshFlowColors.secondary
                    : FreshFlowColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            order.customerName,
                            style: textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FreshFlowColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            order.invoiceNo,
                            style: textTheme.labelSmall?.copyWith(
                              color: FreshFlowColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.customerPhone} • ${order.serviceName}',
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.isPaid
                      ? FreshFlowColors.tertiary.withValues(alpha: 0.12)
                      : FreshFlowColors.errorContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.paymentStatus,
                  style: textTheme.labelSmall?.copyWith(
                    color: order.isPaid
                        ? FreshFlowColors.tertiary
                        : FreshFlowColors.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Highlight Box (Status + Lokasi/Jarak)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: order.isExpress
                  ? FreshFlowColors.secondaryFixed.withValues(alpha: 0.45)
                  : FreshFlowColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: FreshFlowColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    order.isExpress
                        ? Icons.bolt_rounded
                        : Icons.local_laundry_service_rounded,
                    size: 18,
                    color: order.isExpress
                        ? FreshFlowColors.secondary
                        : FreshFlowColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${OrderStatus.label(order.status)}',
                        style: textTheme.labelMedium?.copyWith(
                          color: FreshFlowColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (order.notes.isNotEmpty)
                        Text(
                          order.notes,
                          style: textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (order.hasLocation)
                        Text(
                          'GPS: ${order.latitude!.toStringAsFixed(4)}, ${order.longitude!.toStringAsFixed(4)}'
                          '${distanceMeters != null ? ' • Jarak ${formatJarak(distanceMeters!)}' : ''}',
                          style: textTheme.labelSmall?.copyWith(
                            color: FreshFlowColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: FreshFlowColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${order.weightKg.toStringAsFixed(1)} Kg',
                      style: textTheme.labelSmall?.copyWith(
                        color: FreshFlowColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${order.fragrance}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              Text(
                formatRupiah(order.totalPrice),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: FreshFlowColors.surfaceContainerLow,
                    foregroundColor: FreshFlowColors.onSurface,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Detail'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isDone ? null : onAdvance,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.update_rounded, size: 16),
                  label: Text(isDone ? 'Selesai' : 'Update'),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: FreshFlowColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: FreshFlowColors.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.labelMedium?.copyWith(
                color: FreshFlowColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
