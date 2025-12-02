import 'package:flutter/material.dart';
import '../../widgets/main_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Configuración',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Notificaciones',
                  subtitle: 'Gestionar notificaciones push',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración de notificaciones próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.grey, height: 1),
                _buildSettingTile(
                  icon: Icons.dark_mode,
                  title: 'Tema',
                  subtitle: 'Modo oscuro/claro',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración de tema próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.grey, height: 1),
                _buildSettingTile(
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Cambiar idioma de la aplicación',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración de idioma próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.grey, height: 1),
                _buildSettingTile(
                  icon: Icons.security,
                  title: 'Privacidad y Seguridad',
                  subtitle: 'Gestionar datos y seguridad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración de privacidad próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}