import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/ulak_logo.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.location,
    required this.title,
    required this.body,
    this.actions,
  });

  final String location;
  final String title;
  final Widget body;
  final List<Widget>? actions;

  static const _items = <_NavItem>[
    _NavItem(label: 'Anasayfa', icon: Icons.home, route: '/home'),
    _NavItem(label: 'Dosya Ver', icon: Icons.upload_file, route: '/send'),
    _NavItem(label: 'Dosya Al', icon: Icons.download, route: '/receive'),
    _NavItem(label: 'Ayarlar', icon: Icons.settings, route: '/settings'),
  ];

  int _selectedIndex() {
    final idx = _items.indexWhere((e) => location.startsWith(e.route));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex();
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isExtendedRail = width >= 1100;

    Widget content = body;
    if (isWide) {
      content = Row(
        children: [
          NavigationRail(
            extended: isExtendedRail,
            selectedIndex: selected,
            onDestinationSelected: (i) => context.go(_items[i].route),
            labelType: NavigationRailLabelType.none,
            useIndicator: true,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const UlakLogo(size: 28),
                  if (isExtendedRail) ...[
                    const SizedBox(width: 10),
                    Text(
                      'Ulak',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            destinations: [
              for (final item in _items)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (!isWide) ...[
              const UlakLogo(size: 22),
              const SizedBox(width: 10),
            ],
            Text(title),
          ],
        ),
        actions: actions,
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Row(
                      children: [
                        const UlakLogo(size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ulak',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Güvenli & hızlı aktarım',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final item in _items)
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      selected: location.startsWith(item.route),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    ),
                ],
              ),
            ),
      body: content,
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
  final String label;
  final IconData icon;
  final String route;
}
