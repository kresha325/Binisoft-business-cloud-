import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/catalog/catalog_screen.dart';
import 'features/auth/auth_screen.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const AuthGate(child: DashboardScreen())),
    GoRoute(path: '/catalog', builder: (_, __) => const AuthGate(child: CatalogScreen())),
  ],
));

class BinisoftApp extends ConsumerWidget {
  const BinisoftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Binisoft Business Cloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
