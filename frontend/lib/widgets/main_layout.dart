import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showDrawer;
  final Widget? floatingActionButton;
  final bool showBottomNav;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.showDrawer = true,
    this.floatingActionButton,
    this.showBottomNav = false,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildCustomAppBar(context),
      drawer: showDrawer ? const AppDrawer() : null,
      body: body,
      bottomNavigationBar: showBottomNav ? _buildBottomNavBar(context) : null,
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      leading: showDrawer
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      actions: actions ?? [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E1E),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFFFFFFF),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Inicio',
                isSelected: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.timer,
                label: 'Tiempos',
                isSelected: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) {
                    Navigator.pushNamed(context, '/leaderboard');
                  }
                },
              ),
              _buildCenterActionButton(context),
              _buildNavItem(
                context,
                icon: Icons.emoji_events,
                label: 'Torneos',
                isSelected: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) {
                    Navigator.pushNamed(context, '/tournaments');
                  }
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.settings,
                label: 'Ajustes',
                isSelected: currentIndex == 3,
                onTap: () {
                  if (currentIndex != 3) {
                    Navigator.pushNamed(context, '/settings');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF00BFFF) : const Color(0xFFA0A0A0),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00BFFF) : const Color(0xFFA0A0A0),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterActionButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: GestureDetector(
        onTap: () {
          // Navigate to a special action or create tournament
          Navigator.pushNamed(context, '/tournaments');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00BFFF),
            border: Border.all(
              color: Colors.black,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFFF).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.flag,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
