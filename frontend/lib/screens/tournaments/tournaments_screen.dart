import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/main_layout.dart';
import '../../services/tournament_service.dart';
import '../../models/tournament_model.dart';
import '../../providers/auth_provider.dart';
import 'create_tournament_screen.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  List<Tournament> _tournaments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    setState(() {
      _isLoading = true;
    });

    final tournaments = await TournamentService().getTournaments();

    setState(() {
      _tournaments = tournaments;
      _isLoading = false;
    });
  }

  void _navigateToCreateTournament() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTournamentScreen()),
    );

    if (result == true) {
      _loadTournaments();
    }
  }

  void _showRegisterUserDialog(Tournament tournament) async {
    final userService = UserService();
    User? selectedUser;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Inscribir Usuario en ${tournament.nombre}'),
              content: FutureBuilder<List<User>>(
                future: userService.getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay usuarios disponibles');
                  }

                  final userList = snapshot.data!;

                  return DropdownButtonFormField<User>(
                    isExpanded: true, // Fix overflow
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Usuario',
                    ),
                    initialValue: selectedUser,
                    items: userList.map((user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(
                          user.nombreCompleto,
                          overflow: TextOverflow.ellipsis, // Fix overflow
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUser = value;
                      });
                    },
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: selectedUser == null
                      ? null
                      : () async {
                          final success = await TournamentService()
                              .registerUser(tournament.id, selectedUser!.id);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Usuario inscrito exitosamente'
                                      : 'Error al inscribir usuario',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Inscribir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.user?.rol == 'administrador';

    return MainLayout(
      title: 'Torneos',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tournaments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay torneos disponibles',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToCreateTournament,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Torneo'),
                    ),
                  ],
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTournaments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = _tournaments[index];
                  return Card(
                    clipBehavior:
                        Clip.antiAlias, // Ensure InkWell ripple is clipped
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentDetailScreen(
                              tournamentId: tournament.id,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              // Radius is handled by Card shape + clipBehavior
                            ),
                            child: Center(
                              child: Icon(
                                Icons.emoji_events,
                                size: 64,
                                color: Colors.amber[700],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tournament.nombre,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tournament.estado
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tournament.estado
                                            ? 'ACTIVO'
                                            : 'FINALIZADO',
                                        style: TextStyle(
                                          color: tournament.estado
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (tournament.descripcion != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    tournament.descripcion!,
                                    style: TextStyle(color: Colors.grey[400]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premio: ${tournament.premio} pts',
                                      style: TextStyle(
                                        color: Colors.amber[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Inicio: ${tournament.fechaInicio.day}/${tournament.fechaInicio.month}/${tournament.fechaInicio.year}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showRegisterUserDialog(tournament),
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Inscribir Usuario'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: isAdmin && _tournaments.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToCreateTournament,
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }
}
