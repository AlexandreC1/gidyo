import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class GuideNavigationShell extends StatefulWidget {
  final Widget child;

  const GuideNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<GuideNavigationShell> createState() => _GuideNavigationShellState();
}

class _GuideNavigationShellState extends State<GuideNavigationShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      path: '/guide/dashboard',
    ),
    _NavItem(
      label: 'Calendar',
      icon: Icons.event_outlined,
      activeIcon: Icons.event,
      path: '/guide/calendar',
    ),
    _NavItem(
      label: 'Bookings',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      path: '/guide/bookings',
    ),
    _NavItem(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      path: '/guide/messages',
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      path: '/guide/profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    final currentPath = GoRouterState.of(context).matchedLocation;
    final index = _navItems.indexWhere((item) => item.path == currentPath);
    if (index != -1 && _currentIndex != index) {
      _currentIndex = index;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: AppColors.gray,
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
