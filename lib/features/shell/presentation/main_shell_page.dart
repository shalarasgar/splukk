import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../marketplace/presentation/marketplace_page.dart';
import '../../my_picks/presentation/my_picks_page.dart';
import '../../profile/presentation/profile_page.dart';

class ActiveTabProvider extends InheritedWidget {
  final int index;
  
  const ActiveTabProvider({
    super.key, 
    required this.index, 
    required super.child,
  });

  static int of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ActiveTabProvider>()?.index ?? 0;
  }

  @override
  bool updateShouldNotify(ActiveTabProvider oldWidget) => index != oldWidget.index;
}

@RoutePage()
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, this.initialTabIndex = 0});

  /// 0: Marketplace, 1: My Picks, 2: Profile
  final int initialTabIndex;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    const pages = [MarketplacePage(), MyPicksPage(), ProfilePage()];

    return Scaffold(
      body: ActiveTabProvider(
        index: _currentIndex,
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'My Picks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
