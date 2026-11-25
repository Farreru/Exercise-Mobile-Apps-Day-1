import 'package:material_ui/material_ui.dart';

import 'router/app_router.dart';
import 'theme/freshflow_theme.dart';

class FreshWashApp extends StatelessWidget {
  const FreshWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FreshWash Laundry Admin',
      debugShowCheckedModeBanner: false,
      theme: FreshFlowTheme.light(),
      routerConfig: appRouter,
    );
  }
}
