import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../blocs/order_controller.dart';
import '../models/laundry_order.dart';
import '../theme/freshflow_theme.dart';
import '../widgets/freshflow_shell.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _controller = OrderController.shared;
  String _selectedStage = 'ALL';

  @override
  void initState() {
    super.initState();
    _controller.loadIfNeeded();
  }

  List<LaundryOrder> _filteredOrders() {
    if (_selectedStage == 'ALL') return _controller.orders;
    return _controller.orders
        .where((order) => order.status == _selectedStage)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const FreshFlowTopBar(title: 'Dashboard'),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final totalOmset = _controller.totalOmset;
          final totalKg = _controller.totalKg;
          const targetKg = 100.0;
          final pct = (totalKg / targetKg).clamp(0.0, 1.0);
          final urgent = _controller.urgentExpressOrder;
          final filtered = _filteredOrders();

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
                // Greeting & Shift Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Mas Adi!',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.store_rounded,
                                size: 16,
                                color: FreshFlowColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Outlet Sudirman Utama',
                                style: textTheme.labelMedium?.copyWith(
                                  color: FreshFlowColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: FreshFlowColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: FreshFlowColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Shift Pagi',
                            style: textTheme.labelSmall?.copyWith(
                              color: FreshFlowColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Revenue & Capacity Performance Card
                Container(
                  padding: const EdgeInsets.all(20),
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
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: FreshFlowColors.secondaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ringkasan Operasional',
                                style: textTheme.labelMedium,
                              ),
                            ],
                          ),
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
                              children: [
                                const Icon(
                                  Icons.trending_up_rounded,
                                  size: 14,
                                  color: FreshFlowColors.tertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Live SQLite',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: FreshFlowColors.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Omset Tercatat',
                                  style: textTheme.labelMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(totalOmset),
                                  style: textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_controller.orders.length} transaksi di database lokal',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: FreshFlowColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircularProgressRing(
                            progress: pct,
                            size: 76,
                            strokeWidth: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_laundry_service_rounded,
                                  color: FreshFlowColors.primary,
                                  size: 18,
                                ),
                                Text(
                                  '${(pct * 100).round()}%',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: FreshFlowColors.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Capacity pill
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FreshFlowColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            FreshFlowTheme.radiusDefault,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: FreshFlowColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.scale_rounded,
                                    size: 18,
                                    color: FreshFlowColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kapasitas Cucian',
                                      style: textTheme.labelSmall,
                                    ),
                                    Text(
                                      '${totalKg.toStringAsFixed(1)} Kg / ${targetKg.toInt()} Kg Target',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: FreshFlowColors.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: FreshFlowColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Sisa ${(targetKg - totalKg).clamp(0, targetKg).toStringAsFixed(1)} Kg',
                                style: textTheme.labelSmall?.copyWith(
                                  color: FreshFlowColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3 Mini Metric Cards
                      Row(
                        children: [
                          Expanded(
                            child: _MiniMetricTile(
                              icon: Icons.receipt_long_rounded,
                              iconColor: FreshFlowColors.secondaryContainer,
                              value: '${_controller.countByStatus(OrderStatus.antrean)}',
                              label: 'Antrean',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MiniMetricTile(
                              icon: Icons.water_rounded,
                              iconColor: FreshFlowColors.primary,
                              value: '${_controller.countByStatus(OrderStatus.proses)}',
                              label: 'Diproses',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MiniMetricTile(
                              icon: Icons.electric_moped_rounded,
                              iconColor: FreshFlowColors.tertiary,
                              value: '${_controller.countByStatus(OrderStatus.siapAmbil)}',
                              label: 'Siap Antar',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Actions Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aksi Cepat Kasir',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/katalog'),
                      child: const Text('Katalog & Pelanggan'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_circle_rounded,
                        title: 'POS Baru',
                        subtitle: 'Buat Nota',
                        isPrimary: true,
                        onTap: () => context.go('/pos-baru'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.map_rounded,
                        title: 'Rute Kurir',
                        subtitle: 'Peta & GPS',
                        accentColor: FreshFlowColors.secondaryContainer,
                        onTap: () => context.go('/logistik'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.tune_rounded,
                        title: 'Cek Mesin',
                        subtitle: '16 On-Grid',
                        accentColor: FreshFlowColors.tertiary,
                        onTap: () => context.go('/mesin'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Express Urgency Banner
                if (urgent != null) ...[
                  _ExpressHighlightCard(
                    order: urgent,
                    onMarkReady: () async {
                      await _controller.majuStatus(urgent);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${urgent.invoiceNo} diperbarui ke ${OrderStatus.label(OrderStatus.next(urgent.status))}',
                            ),
                          ),
                        );
                      }
                    },
                    onOpenOrders: () => context.go('/pesanan'),
                  ),
                  const SizedBox(height: 20),
                ],

                // Workflow Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Alur Kerja Cucian',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: FreshFlowColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_controller.orders.length} Nota',
                            style: textTheme.labelSmall?.copyWith(
                              color: FreshFlowColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.go('/pesanan'),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Horizontal filter pills
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StageChip(
                        label: 'Semua',
                        count: _controller.orders.length,
                        selected: _selectedStage == 'ALL',
                        onTap: () => setState(() => _selectedStage = 'ALL'),
                      ),
                      const SizedBox(width: 8),
                      for (final status in OrderStatus.all) ...[
                        _StageChip(
                          label: OrderStatus.label(status),
                          count: _controller.countByStatus(status),
                          selected: _selectedStage == status,
                          onTap: () => setState(() => _selectedStage = status),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (_controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FreshFlowColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                        FreshFlowTheme.radiusLg,
                      ),
                    ),
                    child: Text(
                      'Belum ada pesanan pada tahap ini. Tekan POS Baru untuk membuat nota.',
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...filtered.take(4).map(
                        (order) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DashboardOrderCard(
                            order: order,
                            onTap: () => context.go('/pesanan'),
                          ),
                        ),
                      ),

                const SizedBox(height: 12),

                // Detergent & Water Telemetry Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        FreshFlowColors.surfaceContainerLow,
                        FreshFlowColors.surfaceContainer,
                        FreshFlowColors.surfaceContainerHighest,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: FreshFlowColors.primary
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.opacity_rounded,
                                  size: 18,
                                  color: FreshFlowColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penggunaan Air & Detergen',
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Sensor Tangki Otomatis Outlet',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: FreshFlowColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            'Normal',
                            style: textTheme.labelMedium?.copyWith(
                              color: FreshFlowColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TelemetryMiniBox(
                              label: 'Detergen Wangi',
                              value: '18.4 L',
                              caption: 'Sisa ~4 hari cuci',
                              icon: Icons.bubble_chart_rounded,
                              iconColor: FreshFlowColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TelemetryMiniBox(
                              label: 'Softener Lavender',
                              value: '8.2 L',
                              caption: 'Perlu isi ulang besok',
                              captionColor: FreshFlowColors.secondary,
                              icon: Icons.spa_rounded,
                              iconColor: FreshFlowColors.secondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _MiniMetricTile extends StatelessWidget {
  const _MiniMetricTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: FreshFlowColors.surfaceContainer,
        borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: FreshFlowColors.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPrimary = false,
    this.accentColor = FreshFlowColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? FreshFlowColors.primaryContainer
              : FreshFlowColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
          boxShadow: isPrimary
              ? FreshFlowTheme.primaryShadow
              : FreshFlowTheme.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.18)
                    : accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : accentColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: textTheme.labelMedium?.copyWith(
                color: isPrimary ? Colors.white : FreshFlowColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.85)
                    : FreshFlowColors.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpressHighlightCard extends StatelessWidget {
  const _ExpressHighlightCard({
    required this.order,
    required this.onMarkReady,
    required this.onOpenOrders,
  });

  final LaundryOrder order;
  final VoidCallback onMarkReady;
  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: FreshFlowColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      order.speedOption.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: FreshFlowColors.secondaryFixed.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: FreshFlowColors.secondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Prioritas SLA',
                      style: textTheme.labelSmall?.copyWith(
                        color: FreshFlowColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InitialAvatar(
                name: order.customerName,
                size: 46,
                backgroundColor: FreshFlowColors.secondaryFixed,
                foregroundColor: FreshFlowColors.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            order.customerName,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FreshFlowColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.invoiceNo,
                            style: textTheme.labelSmall?.copyWith(
                              color: FreshFlowColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.serviceName} • ${order.weightKg.toStringAsFixed(1)} Kg',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: FreshFlowColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.notes.isEmpty
                                ? 'Status: ${OrderStatus.label(order.status)}'
                                : order.notes,
                            style: textTheme.labelSmall?.copyWith(
                              color: FreshFlowColors.tertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenOrders,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: FreshFlowColors.surfaceContainerHigh,
                    foregroundColor: FreshFlowColors.onSurface,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: const Text('Kelola Nota'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: order.status == OrderStatus.selesai
                      ? null
                      : onMarkReady,
                  style: FilledButton.styleFrom(
                    backgroundColor: FreshFlowColors.secondaryContainer,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                  label: Text(
                    order.status == OrderStatus.selesai
                        ? 'Selesai'
                        : 'Tahap Lanjut',
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

class _StageChip extends StatelessWidget {
  const _StageChip({
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
              : FreshFlowColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? FreshFlowTheme.secondaryShadow : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: selected
                    ? Colors.white
                    : FreshFlowColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.22)
                    : FreshFlowColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: textTheme.labelSmall?.copyWith(
                  color: selected ? Colors.white : FreshFlowColors.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardOrderCard extends StatelessWidget {
  const _DashboardOrderCard({required this.order, required this.onTap});

  final LaundryOrder order;
  final VoidCallback onTap;

  Color get _badgeBg {
    switch (order.status) {
      case OrderStatus.siapAmbil:
      case OrderStatus.selesai:
        return FreshFlowColors.tertiaryContainer.withValues(alpha: 0.14);
      case OrderStatus.proses:
        return FreshFlowColors.primaryFixed;
      default:
        return FreshFlowColors.secondaryFixed;
    }
  }

  Color get _badgeFg {
    switch (order.status) {
      case OrderStatus.siapAmbil:
      case OrderStatus.selesai:
        return FreshFlowColors.tertiary;
      case OrderStatus.proses:
        return FreshFlowColors.primary;
      default:
        return FreshFlowColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
      child: Container(
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: FreshFlowColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          order.invoiceNo,
                          style: textTheme.labelSmall?.copyWith(
                            color: FreshFlowColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.customerName,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    OrderStatus.label(order.status),
                    style: textTheme.labelSmall?.copyWith(
                      color: _badgeFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.serviceName} • ${order.weightKg.toStringAsFixed(1)} Kg',
                  style: textTheme.bodySmall,
                ),
                Text(
                  formatRupiah(order.totalPrice),
                  style: textTheme.labelMedium?.copyWith(
                    color: FreshFlowColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: OrderStatus.progress(order.status),
                minHeight: 6,
                backgroundColor: FreshFlowColors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(_badgeFg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryMiniBox extends StatelessWidget {
  const _TelemetryMiniBox({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.iconColor,
    this.captionColor,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconColor;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(FreshFlowTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            caption,
            style: textTheme.labelSmall?.copyWith(
              color: captionColor ?? FreshFlowColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
