import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/'),
      ),
      title: const Text('Katalogu'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _CatalogTile(
          icon: Icons.inventory_2_outlined,
          title: 'Produktet',
          subtitle: 'Mallra, ushqime, veshje dhe pajisje',
        ),
        _CatalogTile(
          icon: Icons.design_services_outlined,
          title: 'Shërbimet',
          subtitle: 'Termine, kohëzgjatje dhe çmime',
        ),
        _CatalogTile(
          icon: Icons.category_outlined,
          title: 'Kategoritë',
          subtitle: 'Kategori dhe nënkategori',
        ),
        SizedBox(height: 24),
        Center(child: Text('Menaxhimi i katalogut vjen në fazën tjetër.')),
      ],
    ),
  );
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.icon, required this.title, required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
