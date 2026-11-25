import 'package:material_ui/material_ui.dart';

import '../blocs/order_controller.dart';
import '../models/laundry_order.dart';
import '../theme/freshflow_theme.dart';
import '../widgets/freshflow_shell.dart';

class _CatalogItem {
  _CatalogItem({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.price,
    required this.unit,
    required this.eta,
    required this.icon,
    this.isPriority = false,
  });

  final String name;
  final String subtitle;
  final String category;
  final int price;
  final String unit;
  final String eta;
  final IconData icon;
  final bool isPriority;
  bool active = true;
}

/// Halaman Katalog Layanan & Database Pelanggan sesuai katalog_layanan_pelanggan/code.html.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _orderController = OrderController.shared;
  bool _showCustomers = false;

  final List<_CatalogItem> _items = [
    _CatalogItem(
      name: 'Cuci Kering Setrika Reguler',
      subtitle: 'Layanan Kiloan Harian • Higienis 3x Bilas',
      category: 'Kiloan',
      price: 8000,
      unit: '/Kg',
      eta: '2 Hari',
      icon: Icons.local_laundry_service_rounded,
    ),
    _CatalogItem(
      name: 'Cuci Kering Setrika Express',
      subtitle: 'Layanan Cepat Kilat • Slot Mesin Khusus',
      category: 'Kiloan',
      price: 14000,
      unit: '/Kg',
      eta: '4 Jam Siap',
      icon: Icons.bolt_rounded,
      isPriority: true,
    ),
    _CatalogItem(
      name: 'Jas / Blazer (2 Pcs)',
      subtitle: 'Dry Clean Uap • Gantungan Khusus',
      category: 'Satuan',
      price: 35000,
      unit: '/Set',
      eta: 'Garansi Bahan',
      icon: Icons.checkroom_rounded,
    ),
    _CatalogItem(
      name: 'Paket Kost Hemat 30 Kg',
      subtitle: 'Berlaku 30 Hari • Free Antar Jemput Kost',
      category: 'Langganan',
      price: 210000,
      unit: '/Bulan',
      eta: 'Promo Aktif',
      icon: Icons.loyalty_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orderController.loadIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const FreshFlowTopBar(
        title: 'Pelanggan & Katalog',
        showBack: true,
      ),
      body: ListenableBuilder(
        listenable: _orderController,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FreshFlowTheme.margin,
              12,
              FreshFlowTheme.margin,
              28,
            ),
            children: [
              // Segmented Switcher
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: FreshFlowColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        icon: Icons.inventory_2_outlined,
                        label: 'Katalog & Tarif',
                        selected: !_showCustomers,
                        onTap: () => setState(() => _showCustomers = false),
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        icon: Icons.group_outlined,
                        label: 'Database Pelanggan',
                        selected: _showCustomers,
                        onTap: () => setState(() => _showCustomers = true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (!_showCustomers) ...[
                ..._items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: FreshFlowColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(
                          FreshFlowTheme.radiusLg,
                        ),
                        boxShadow: FreshFlowTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: item.isPriority
                                      ? FreshFlowColors.secondaryFixed
                                      : FreshFlowColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.isPriority
                                      ? FreshFlowColors.secondary
                                      : FreshFlowColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      item.subtitle,
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: item.active,
                                activeTrackColor:
                                    FreshFlowColors.tertiaryContainer,
                                onChanged: (v) =>
                                    setState(() => item.active = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: FreshFlowColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tarif Resmi',
                                        style: textTheme.labelSmall,
                                      ),
                                      Text(
                                        '${formatRupiah(item.price)} ${item.unit}',
                                        style: textTheme.headlineSmall?.copyWith(
                                          color: item.isPriority
                                              ? FreshFlowColors.secondary
                                              : FreshFlowColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: FreshFlowColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estimasi',
                                        style: textTheme.labelSmall,
                                      ),
                                      Text(
                                        item.eta,
                                        style: textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Customer list aggregated from SQLite orders
                ..._orderController.orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: FreshFlowColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(
                          FreshFlowTheme.radiusLg,
                        ),
                        boxShadow: FreshFlowTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          InitialAvatar(name: order.customerName, size: 46),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${order.customerPhone} • ${order.address ?? "Outlet Pickup"}',
                                  style: textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.serviceName} • ${formatRupiah(order.totalPrice)}',
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
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Insight Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      FreshFlowColors.surfaceContainerHigh,
                      FreshFlowColors.surfaceContainerLow,
                      FreshFlowColors.surfaceContainerHighest,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL PELANGGAN TERCATAT',
                          style: textTheme.labelSmall?.copyWith(
                            color: FreshFlowColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_orderController.orders.length} Nota Aktif',
                          style: textTheme.headlineMedium,
                        ),
                        Text(
                          'Tersinkron dengan SQLite lokal',
                          style: textTheme.labelSmall?.copyWith(
                            color: FreshFlowColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const CircularProgressRing(
                      progress: 0.73,
                      size: 64,
                      strokeWidth: 6,
                      child: Text(
                        '73%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: FreshFlowColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? FreshFlowColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : FreshFlowColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: selected
                      ? Colors.white
                      : FreshFlowColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
