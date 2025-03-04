import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/theme/app_theme.dart';

enum NavigationTab {
  alerts,
  emergency,
  map,
  settings,
}

class NavigationCubit extends Cubit<NavigationTab> {
  NavigationCubit() : super(NavigationTab.alerts);

  void setTab(NavigationTab tab) => emit(tab);
}

class AppNavigation extends StatelessWidget {
  final Widget child;

  const AppNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: _NavigationView(child: child),
    );
  }
}

class _NavigationView extends StatelessWidget {
  final Widget child;

  const _NavigationView({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<NavigationCubit>().state;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureBlack,
        border: Border(
          top: BorderSide(
            color: Colors.grey[900]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Alerts',
                isSelected: currentTab == NavigationTab.alerts,
                onTap: () => _onTabSelected(context, NavigationTab.alerts),
              ),
              _NavItem(
                icon: Icons.emergency_rounded,
                label: 'Emergency',
                isSelected: currentTab == NavigationTab.emergency,
                onTap: () => _onTabSelected(context, NavigationTab.emergency),
              ),
              _NavItem(
                icon: Icons.map_rounded,
                label: 'Map',
                isSelected: currentTab == NavigationTab.map,
                onTap: () => _onTabSelected(context, NavigationTab.map),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: currentTab == NavigationTab.settings,
                onTap: () => _onTabSelected(context, NavigationTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabSelected(BuildContext context, NavigationTab tab) {
    context.read<NavigationCubit>().setTab(tab);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primaryOrange : Colors.grey;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 