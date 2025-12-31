import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Colors from the HTML design
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderGray = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAdmin = user?.rol == 'administrador';

    return Drawer(
      backgroundColor: backgroundDark,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundDark,
          border: Border(
            right: BorderSide(
              color: borderGray,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del drawer con avatar del usuario
            Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 1,
                    color: Color(0xFF1F1F1F),
                  ),
                ],
              ),
            ),

            // Opciones del menú
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home,
                    title: 'Inicio',
                    route: '/home',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Ranking Global',
                    route: '/leaderboard',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.emoji_events,
                    title: 'Torneos',
                    route: '/tournaments',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Perfil',
                    route: '/profile',
                  ),

                  // Sección de administrador
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Color(0xFF1F1F1F),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'ADMINISTRACIÓN',
                        style: GoogleFonts.inter(
                          color: primaryRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.people,
                      title: 'Usuarios',
                      route: '/admin/users',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.timer,
                      title: 'Marcadores',
                      route: '/admin/marcadores',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.analytics,
                      title: 'Estadísticas',
                      route: '/admin/stats',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Color(0xFF1F1F1F),
                    ),
                    const SizedBox(height: 8),
                  ],

                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Configuración',
                    route: '/settings',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Color(0xFF1F1F1F),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info,
                    title: 'Acerca de',
                    route: '/about',
                  ),
                ],
              ),
            ),

            // Botón de logout al final
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Transform.rotate(
                        angle: 3.14159, // 180 degrees
                        child: const Icon(
                          Icons.logout,
                          color: Color(0xFFFF4D4D),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cerrar Sesión',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF4D4D),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (!isSelected) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: Color(0xFF1F1F1F),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? Color(0xFF1F1F1F) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? primaryRed : textLight,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textLight,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: borderGray,
              width: 1,
            ),
          ),
          title: Text(
            '¿Cerrar Sesión?',
            style: GoogleFonts.inter(
              color: textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: GoogleFonts.inter(
              color: textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: textMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: Text(
                'Cerrar Sesión',
                style: GoogleFonts.inter(
                  color: primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
