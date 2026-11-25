import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../blocs/order_controller.dart';
import '../models/laundry_order.dart';
import '../services/distance.dart';
import '../services/location_service.dart';
import '../theme/freshflow_theme.dart';
import '../widgets/freshflow_shell.dart';

/// Halaman Rute Logistik & Kurir (adaptasi dari LocationPage Hands-On Hari 1).
/// Menampilkan peta OpenStreetMap interaktif, GPS kurir, reverse geocoding
/// Nominatim, live tracking (pantauPosisi), dan urutan rute berdasarkan jarak Haversine.
class LogisticsPage extends StatefulWidget {
  const LogisticsPage({super.key});

  @override
  State<LogisticsPage> createState() => _LogisticsPageState();
}

class _LogisticsPageState extends State<LogisticsPage> {
  // Koordinat default Outlet Pusat (Cipete, Jakarta Selatan)
  static const _outletPusat = LatLng(-6.2740, 106.8050);

  final _service = LocationService();
  final _mapController = MapController();
  final _orderController = OrderController.shared;

  Position? _posisi;
  String? _alamat;
  String? _error;
  bool _memuat = false;
  bool _liveTracking = false;
  StreamSubscription<Position>? _posisiSub;

  @override
  void initState() {
    super.initState();
    _orderController.loadIfNeeded();
  }

  @override
  void dispose() {
    _posisiSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _perbaruiPosisi() async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final posisi = await _service.ambilPosisi();
      String? alamat;
      try {
        alamat = await _service.alamatDari(posisi.latitude, posisi.longitude);
      } catch (_) {
        // Tetap tampilkan koordinat jika reverse geocoding gagal/offline.
      }
      if (!mounted) return;

      setState(() {
        _posisi = posisi;
        _alamat = alamat;
      });
      _mapController.move(LatLng(posisi.latitude, posisi.longitude), 15.5);
    } on LocationException catch (e) {
      if (mounted) setState(() => _error = e.pesan);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat posisi: $e');
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _toggleLiveTracking(bool enabled) async {
    if (!enabled) {
      await _posisiSub?.cancel();
      _posisiSub = null;
      setState(() => _liveTracking = false);
      return;
    }

    final ok = await _service.pastikanIzin();
    if (!ok) {
      setState(() {
        _error = 'Izin lokasi belum diberikan atau layanan lokasi nonaktif.';
        _liveTracking = false;
      });
      return;
    }

    setState(() {
      _liveTracking = true;
      _error = null;
    });

    await _posisiSub?.cancel();
    _posisiSub = _service.pantauPosisi(jarakMinimalMeter: 5).listen(
      (pos) {
        if (!mounted) return;
        setState(() => _posisi = pos);
        _mapController.move(LatLng(pos.latitude, pos.longitude), 15.5);
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _error = 'Stream lokasi terhenti: $e';
          _liveTracking = false;
        });
      },
    );
  }

  LatLng get _refPoint => _posisi != null
      ? LatLng(_posisi!.latitude, _posisi!.longitude)
      : _outletPusat;

  List<LaundryOrder> _activeDeliveries() {
    final active = _orderController.orders
        .where((o) => o.status != OrderStatus.selesai)
        .toList();

    active.sort((a, b) {
      final da = a.hasLocation
          ? jarakMeter(
              _refPoint.latitude,
              _refPoint.longitude,
              a.latitude!,
              a.longitude!,
            )
          : double.infinity;
      final db = b.hasLocation
          ? jarakMeter(
              _refPoint.latitude,
              _refPoint.longitude,
              b.latitude!,
              b.longitude!,
            )
          : double.infinity;
      return da.compareTo(db);
    });
    return active;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final posisi = _posisi;

    return Scaffold(
      appBar: const FreshFlowTopBar(title: 'Rute Logistik & Kurir'),
      body: ListenableBuilder(
        listenable: _orderController,
        builder: (context, _) {
          final deliveries = _activeDeliveries();
          final siapAntar = _orderController.countByStatus(OrderStatus.siapAmbil);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FreshFlowTheme.margin,
              12,
              FreshFlowTheme.margin,
              28,
            ),
            children: [
              // Sub-header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: FreshFlowColors.tertiaryContainer
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: FreshFlowColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'DISPATCHER LIVE ACTIVE',
                              style: textTheme.labelSmall?.copyWith(
                                color: FreshFlowColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Logistik & Pengantaran',
                        style: textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _memuat ? null : _perbaruiPosisi,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: FreshFlowColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: _memuat
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              color: FreshFlowColors.primary,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2x2 Quick Metric Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.9,
                children: [
                  _LogisticsMetricCard(
                    title: 'Paket Antar',
                    value: '$siapAntar',
                    caption: 'Siap Antar',
                    icon: Icons.inventory_2_rounded,
                    color: FreshFlowColors.primary,
                  ),
                  _LogisticsMetricCard(
                    title: 'Titik Rute',
                    value: '${deliveries.length}',
                    caption: 'Aktif SQLite',
                    icon: Icons.two_wheeler_rounded,
                    color: FreshFlowColors.secondaryContainer,
                  ),
                  const _LogisticsMetricCard(
                    title: 'Tepat Waktu',
                    value: '94%',
                    caption: 'SLA Goal',
                    icon: Icons.verified_rounded,
                    color: FreshFlowColors.tertiary,
                  ),
                  const _LogisticsMetricCard(
                    title: 'Rata Transit',
                    value: '24',
                    caption: 'Menit / Trip',
                    icon: Icons.timer_rounded,
                    color: FreshFlowColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Interactive OpenStreetMap Card
              Container(
                decoration: BoxDecoration(
                  color: FreshFlowColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                  boxShadow: FreshFlowTheme.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 270,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: const MapOptions(
                              initialCenter: _outletPusat,
                              initialZoom: 14.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'id.ac.associate.freshwash',
                              ),
                              MarkerLayer(
                                markers: [
                                  // Outlet Pusat marker
                                  Marker(
                                    point: _outletPusat,
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FreshFlowColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.local_laundry_service_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  // Order stop markers
                                  for (var i = 0; i < deliveries.length; i++)
                                    if (deliveries[i].hasLocation)
                                      Marker(
                                        point: LatLng(
                                          deliveries[i].latitude!,
                                          deliveries[i].longitude!,
                                        ),
                                        width: 36,
                                        height: 36,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: deliveries[i].isExpress
                                                ? FreshFlowColors
                                                    .secondaryContainer
                                                : FreshFlowColors.tertiary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  // Live Courier / User GPS Marker
                                  if (posisi != null)
                                    Marker(
                                      point: LatLng(
                                        posisi.latitude,
                                        posisi.longitude,
                                      ),
                                      width: 44,
                                      height: 44,
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: FreshFlowColors.error,
                                        size: 42,
                                      ),
                                    ),
                                ],
                              ),
                              const RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Column(
                              children: [
                                _MapIconButton(
                                  icon: Icons.my_location_rounded,
                                  tooltip: 'Perbarui posisi GPS',
                                  onTap: _perbaruiPosisi,
                                ),
                                const SizedBox(height: 8),
                                _MapIconButton(
                                  icon: Icons.store_rounded,
                                  tooltip: 'Pusatkan ke Outlet',
                                  onTap: () =>
                                      _mapController.move(_outletPusat, 14.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Location Info & Controls Panel
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: FreshFlowColors.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _error!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: FreshFlowColors.onErrorContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (posisi != null) ...[
                            Text(
                              'Lat: ${posisi.latitude.toStringAsFixed(6)}, '
                              'Lon: ${posisi.longitude.toStringAsFixed(6)} '
                              '(±${posisi.accuracy.toStringAsFixed(1)} m)',
                              style: textTheme.labelMedium?.copyWith(
                                color: FreshFlowColors.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_alamat != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _alamat!,
                                style: textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 10),
                          ] else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Tekan "Perbarui Posisi" untuk menampilkan lokasi GPS Anda, alamat Nominatim, dan jarak terdekat ke setiap titik antar.',
                                style: textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _memuat ? null : _perbaruiPosisi,
                                  icon: const Icon(
                                    Icons.my_location_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _memuat ? 'Memuat...' : 'Perbarui Posisi',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilterChip(
                                label: const Text('Live GPS'),
                                selected: _liveTracking,
                                onSelected: _toggleLiveTracking,
                                selectedColor: FreshFlowColors.tertiaryFixed,
                                shape: const StadiumBorder(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Route Sequence & Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Urutan Rute Terjadwal',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_graph_rounded,
                        size: 15,
                        color: FreshFlowColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Urut Jarak Terdekat',
                        style: textTheme.labelSmall?.copyWith(
                          color: FreshFlowColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (deliveries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: FreshFlowColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                  ),
                  child: Text(
                    'Semua pengantaran sudah selesai.',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...List.generate(deliveries.length, (index) {
                  final order = deliveries[index];
                  final dist = order.hasLocation
                      ? jarakMeter(
                          _refPoint.latitude,
                          _refPoint.longitude,
                          order.latitude!,
                          order.longitude!,
                        )
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RouteStopCard(
                      stopNumber: index + 1,
                      order: order,
                      distanceMeters: dist,
                      onFocusMap: order.hasLocation
                          ? () => _mapController.move(
                                LatLng(order.latitude!, order.longitude!),
                                16,
                              )
                          : null,
                      onComplete: () async {
                        if (order.id == null) return;
                        await _orderController.ubahStatus(
                          order.id!,
                          OrderStatus.selesai,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pengantaran ${order.invoiceNo} ditandai Selesai.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _LogisticsMetricCard extends StatelessWidget {
  const _LogisticsMetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FreshFlowColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
        boxShadow: FreshFlowTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textTheme.labelMedium),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: color),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: textTheme.headlineMedium),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  caption,
                  style: textTheme.labelSmall?.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: FreshFlowTheme.cardShadow,
          ),
          child: Icon(icon, size: 18, color: FreshFlowColors.onSurface),
        ),
      ),
    );
  }
}

class _RouteStopCard extends StatelessWidget {
  const _RouteStopCard({
    required this.stopNumber,
    required this.order,
    required this.distanceMeters,
    required this.onFocusMap,
    required this.onComplete,
  });

  final int stopNumber;
  final LaundryOrder order;
  final double? distanceMeters;
  final VoidCallback? onFocusMap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = order.isExpress
        ? FreshFlowColors.secondaryContainer
        : FreshFlowColors.primaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: FreshFlowColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
        boxShadow: FreshFlowTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$stopNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.isExpress
                                          ? 'PRIORITAS EXPRESS'
                                          : OrderStatus.label(order.status)
                                              .toUpperCase(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: accent,
                                      ),
                                    ),
                                    Text(
                                      order.customerName,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (distanceMeters != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              formatJarak(distanceMeters!),
                              style: textTheme.labelSmall?.copyWith(
                                color: accent,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, size: 17, color: accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.address ?? 'Alamat belum diisi',
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: FreshFlowColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${order.serviceName} (${order.weightKg.toStringAsFixed(1)} Kg)',
                              style: textTheme.bodySmall?.copyWith(
                                color: FreshFlowColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            order.invoiceNo,
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onFocusMap,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: FreshFlowColors.surfaceContainer,
                              foregroundColor: FreshFlowColors.onSurface,
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: const Icon(Icons.navigation_rounded, size: 16),
                            label: const Text('Lihat Peta'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onComplete,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16,
                            ),
                            label: const Text('Sampai'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
