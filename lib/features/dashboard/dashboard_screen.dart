import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binisoft Cloud', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark,
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          IconButton(
            tooltip: 'Dil nga llogaria',
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 12),
                Text('Mirë se erdhe 👋', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Menaxho biznesin me lehtësi.', style:
                    theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xFF6557F5), Color(0xFF3B36A6)
                    ]),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BUSINESS CLOUD', style: TextStyle(color: Colors.white70,
                        fontWeight: FontWeight.w700, letterSpacing: 2)),
                      SizedBox(height: 14),
                      Text('Një panel. Çdo biznes.', style: TextStyle(
                        color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)),
                      SizedBox(height: 8),
                      Text('Produkte, shërbime, kategori dhe website — në një vend.',
                        style: TextStyle(color: Colors.white70, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Përmbledhje', style:
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: columns == 4 ? 1.65 : 1.25,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      _Metric(icon: Icons.storefront_outlined, value: '0', label: 'Biznese'),
                      _Metric(icon: Icons.inventory_2_outlined, value: '0', label: 'Produkte'),
                      _Metric(icon: Icons.design_services_outlined, value: '0', label: 'Shërbime'),
                      _Metric(icon: Icons.visibility_outlined, value: '0', label: 'Vizita'),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                Text('Veprime të shpejta', style:
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
                    title: const Text('Katalogu universal', style:
                        TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Produkte dhe shërbime'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/catalog'),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Version demonstrues — pa Firebase dhe pa të dhëna reale.',
                  style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
