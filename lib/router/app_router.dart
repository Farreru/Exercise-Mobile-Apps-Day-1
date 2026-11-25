import 'package:go_router/go_router.dart';

import '../pages/catalog_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/logistics_page.dart';
import '../pages/machines_page.dart';
import '../pages/orders_page.dart';
import '../pages/pos_form_page.dart';
import '../widgets/freshflow_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return FreshFlowShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pesanan',
              builder: (context, state) => const OrdersPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pos-baru',
              builder: (context, state) => const PosFormPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/logistik',
              builder: (context, state) => const LogisticsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mesin',
              builder: (context, state) => const MachinesPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/katalog',
      builder: (context, state) => const CatalogPage(),
    ),
  ],
);
