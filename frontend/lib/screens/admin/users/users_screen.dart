import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/main_layout.dart';
import '../../../widgets/search/search_widget.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  List<dynamic> _filteredUsers = [];
  List<dynamic> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      // Aquí iría la llamada para obtener todos los usuarios
      // Por ahora simulamos con datos de ejemplo
      await Future.delayed(const Duration(seconds: 1));
      
      // Datos de ejemplo - reemplazar con llamada real al API
      _allUsers = [
        {
          'id': 1,
          'nombreCompleto': 'Tomás Sáez Aguayo',
          'email': 'tomass2942@gmail.com',
          'rol': 'administrador',
          'rut': '12.345.678-9',
          'puntos': 1250,
          'horas': 45,
          'visitas': 23,
        },
        {
          'id': 2,
          'nombreCompleto': 'Diego Sebastián Ampuero Belmar',
          'email': 'usuario1.2024@gmail.cl',
          'rol': 'usuario',
          'rut': '98.765.432-1',
          'puntos': 890,
          'horas': 32,
          'visitas': 18,
        },
        {
          'id': 3,
          'nombreCompleto': 'Alexander Benjamín Marcelo Carrasco Fuentes',
          'email': 'usuario2.2024@gmail.cl',
          'rol': 'usuario',
          'rut': '11.222.333-4',
          'puntos': 675,
          'horas': 28,
          'visitas': 15,
        },
      ];
      
      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = user['nombreCompleto'].toLowerCase();
          final email = user['email'].toLowerCase();
          final id = user['id'].toString();
          final rut = user['rut']?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return name.contains(searchLower) || 
                 email.contains(searchLower) || 
                 id.contains(searchLower) ||
                 rut.contains(searchLower);
        }).toList();
      }
    });
  }

  void _navigateToUserDetail(Map<String, dynamic> user) {
    Navigator.pushNamed(
      context, 
      '/admin/user-detail',
      arguments: user,
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Agregar Usuario',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Funcionalidad de agregar usuario próximamente.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Gestión de Usuarios',
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchWidget(
              hintText: 'Buscar por nombre, email, ID o RUT...',
              onSearch: _filterUsers,
              searchIcon: Icons.person_search,
            ),
          ),

          // Resultados de búsqueda
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Resultados para "${_searchQuery}": ${_filteredUsers.length}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _filterUsers('');
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),

          // Lista de usuarios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No hay usuarios registrados'
                                  : 'No se encontraron usuarios',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddUserDialog,
          tooltip: 'Agregar Usuario',
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isAdmin = user['rol'] == 'administrador';
    
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAdmin 
            ? const BorderSide(color: Colors.amber, width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isAdmin ? Colors.amber : Colors.grey,
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: isAdmin ? Colors.black : Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['nombreCompleto'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'],
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              'ID: ${user['id']} • RUT: ${user['rut']}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip(Icons.emoji_events, '${user['puntos']} pts', Colors.amber),
                const SizedBox(width: 8),
                _buildStatChip(Icons.timer, '${user['horas']}h', Colors.blue),
                const SizedBox(width: 8),
                _buildStatChip(Icons.directions_car, '${user['visitas']}', Colors.green),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: () => _navigateToUserDetail(user),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}