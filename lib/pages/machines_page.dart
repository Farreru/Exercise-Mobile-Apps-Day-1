import 'package:material_ui/material_ui.dart';

import '../theme/freshflow_theme.dart';
import '../widgets/freshflow_shell.dart';

class _MachineItem {
  _MachineItem({
    required this.name,
    required this.type,
    required this.capacity,
    required this.subtitle,
    required this.statusLabel,
    required this.cycleText,
    required this.remainingText,
    required this.progress,
    required this.state,
  });

  final String name;
  final String type; // washer | dryer
  final String capacity;
  final String subtitle;
  String statusLabel;
  final String cycleText;
  final String remainingText;
  final double progress;
  String state; // running | paused | standby | maintenance
}

/// Halaman Monitoring Mesin & Operasional sesuai monitoring_mesin_operasional/code.html.
class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  String _filter = 'ALL';

  final List<_MachineItem> _machines = [
    _MachineItem(
      name: 'Mesin Cuci 01',
      type: 'washer',
      capacity: 'FL 12 Kg',
      subtitle: 'Order #FW-9040 • Ibu Maya (Kiloan Reguler)',
      statusLabel: 'Sedang Berjalan',
      cycleText: 'Siklus: Bilas 2 dari 3',
      remainingText: 'Sisa 18 Menit',
      progress: 0.64,
      state: 'running',
    ),
    _MachineItem(
      name: 'Mesin Cuci 02',
      type: 'washer',
      capacity: 'FL 12 Kg',
      subtitle: 'Drum Steril • Siap muatan baru',
      statusLabel: 'Standby',
      cycleText: 'Kapasitas Kosong • 0 / 12 Kg',
      remainingText: 'Idle: 14 m',
      progress: 0.0,
      state: 'standby',
    ),
    _MachineItem(
      name: 'Mesin Cuci 03',
      type: 'washer',
      capacity: 'HD 20 Kg',
      subtitle: 'Order #FW-9035 • Hotel Citra (Linen)',
      statusLabel: 'Sedang Mencuci',
      cycleText: 'Cuci Utama • Termo 40°C Aktif',
      remainingText: 'Sisa 32 Menit',
      progress: 0.38,
      state: 'running',
    ),
    _MachineItem(
      name: 'Pengering D-01',
      type: 'dryer',
      capacity: 'Gas 16 Kg',
      subtitle: 'Order #FW-9031 • Bed Sheet & Selimut',
      statusLabel: 'Mengeringkan',
      cycleText: 'Konveksi Panas • 65°C',
      remainingText: 'Sisa 12 Menit',
      progress: 0.78,
      state: 'running',
    ),
    _MachineItem(
      name: 'Mesin Cuci 04',
      type: 'washer',
      capacity: 'FL 10 Kg',
      subtitle: 'Maintenance Terjadwal',
      statusLabel: 'Service Mode',
      cycleText: 'Desinfeksi Drum & Pengecekan Drain Valve',
      remainingText: 'Est. 14:30 WIB',
      progress: 0.0,
      state: 'maintenance',
    ),
  ];

  List<_MachineItem> get _filtered {
    if (_filter == 'ALL') return _machines;
    if (_filter == 'MAINTENANCE') {
      return _machines.where((m) => m.state == 'maintenance').toList();
    }
    return _machines.where((m) => m.type == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const FreshFlowTopBar(title: 'Mesin & Operasional'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FreshFlowTheme.margin,
          12,
          FreshFlowTheme.margin,
          28,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: FreshFlowColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Outlet Cipete Raya • Buka',
                    style: textTheme.labelMedium?.copyWith(
                      color: FreshFlowColors.onSurface,
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
                  color: FreshFlowColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'SHIFT 1 AKTIF',
                  style: textTheme.labelSmall?.copyWith(
                    color: FreshFlowColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Telemetry Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FreshFlowColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(FreshFlowTheme.radiusLg),
              boxShadow: FreshFlowTheme.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TELEMETRI TERKONEKSI', style: textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '16',
                          style: textTheme.headlineLarge?.copyWith(
                            color: FreshFlowColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('/ 16 Mesin On-Grid', style: textTheme.bodySmall),
                      ],
                    ),
                    Text(
                      '10 Cuci • 6 Pengering Digital',
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
                const CircularProgressRing(
                  progress: 0.82,
                  size: 58,
                  strokeWidth: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        size: 16,
                        color: FreshFlowColors.primary,
                      ),
                      Text(
                        '82%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: FreshFlowColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filter Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _MachineFilterChip(
                  label: 'Semua Mesin',
                  selected: _filter == 'ALL',
                  onTap: () => setState(() => _filter = 'ALL'),
                ),
                const SizedBox(width: 8),
                _MachineFilterChip(
                  label: 'Mesin Cuci',
                  selected: _filter == 'washer',
                  onTap: () => setState(() => _filter = 'washer'),
                ),
                const SizedBox(width: 8),
                _MachineFilterChip(
                  label: 'Pengering',
                  selected: _filter == 'dryer',
                  onTap: () => setState(() => _filter = 'dryer'),
                ),
                const SizedBox(width: 8),
                _MachineFilterChip(
                  label: 'Maintenance',
                  selected: _filter == 'MAINTENANCE',
                  onTap: () => setState(() => _filter = 'MAINTENANCE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Machine Cards
          ..._filtered.map(
            (machine) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MachineCard(
                machine: machine,
                onAction: () {
                  setState(() {
                    if (machine.state == 'running') {
                      machine.state = 'paused';
                      machine.statusLabel = 'Dijeda';
                    } else if (machine.state == 'paused') {
                      machine.state = 'running';
                      machine.statusLabel = 'Sedang Berjalan';
                    } else if (machine.state == 'standby') {
                      machine.state = 'running';
                      machine.statusLabel = 'Sedang Berjalan';
                    } else if (machine.state == 'maintenance') {
                      machine.state = 'standby';
                      machine.statusLabel = 'Standby';
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Stock Section
          Text(
            'Bahan Baku & Stok Outlet',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: const [
              _StockCard(
                icon: Icons.opacity_rounded,
                badge: 'Aman',
                value: '78%',
                title: 'Deterjen Cair',
                subtitle: 'Sisa ~39 Liter',
                progress: 0.78,
                color: FreshFlowColors.primaryContainer,
              ),
              _StockCard(
                icon: Icons.spa_rounded,
                badge: 'Cukup',
                value: '42%',
                title: 'Pelembut Softener',
                subtitle: 'Sisa ~18 Liter',
                progress: 0.42,
                color: FreshFlowColors.secondaryContainer,
              ),
              _StockCard(
                icon: Icons.propane_tank_rounded,
                badge: 'Optimal',
                value: '85%',
                title: 'Gas Pengering LPG',
                subtitle: 'Tabung 50 Kg',
                progress: 0.85,
                color: FreshFlowColors.secondaryContainer,
              ),
              _StockCard(
                icon: Icons.shopping_bag_outlined,
                badge: 'Re-order',
                value: '120',
                title: 'Plastik & Tagging',
                subtitle: 'Pcs di storage',
                progress: 0.32,
                color: FreshFlowColors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MachineFilterChip extends StatelessWidget {
  const _MachineFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? FreshFlowColors.primaryContainer
              : FreshFlowColors.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : FreshFlowColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({required this.machine, required this.onAction});

  final _MachineItem machine;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDryer = machine.type == 'dryer';
    final isRunning = machine.state == 'running';
    final isStandby = machine.state == 'standby';
    final isMaint = machine.state == 'maintenance';

    final accent = isMaint
        ? FreshFlowColors.error
        : isStandby
            ? FreshFlowColors.tertiary
            : isDryer
                ? FreshFlowColors.secondaryContainer
                : FreshFlowColors.primaryContainer;

    return Container(
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isMaint
                            ? Icons.build_circle_outlined
                            : isDryer
                                ? Icons.air_rounded
                                : Icons.local_laundry_service_rounded,
                        color: accent,
                      ),
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
                                  machine.name,
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
                                  machine.capacity,
                                  style: textTheme.labelSmall,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            machine.subtitle,
                            style: textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  machine.statusLabel,
                  style: textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FreshFlowColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        machine.cycleText,
                        style: textTheme.labelMedium?.copyWith(
                          color: FreshFlowColors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      machine.remainingText,
                      style: textTheme.labelSmall?.copyWith(
                        color: FreshFlowColors.onSurface,
                      ),
                    ),
                  ],
                ),
                if (machine.progress > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: machine.progress,
                      minHeight: 6,
                      backgroundColor: FreshFlowColors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: onAction,
              style: FilledButton.styleFrom(shape: const StadiumBorder()),
              icon: Icon(
                isRunning
                    ? Icons.pause_circle_outline_rounded
                    : isMaint
                        ? Icons.restart_alt_rounded
                        : Icons.play_circle_outline_rounded,
                size: 18,
              ),
              label: Text(
                isRunning
                    ? 'Jeda'
                    : isMaint
                        ? 'Reset Status'
                        : isStandby
                            ? 'Mulai Cuci'
                            : 'Lanjut',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.icon,
    required this.badge,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  final IconData icon;
  final String badge;
  final String value;
  final String title;
  final String subtitle;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FreshFlowColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(badge, style: textTheme.labelSmall),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: textTheme.headlineMedium),
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  color: FreshFlowColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(subtitle, style: textTheme.labelSmall),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: FreshFlowColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
