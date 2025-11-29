import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/marcador_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final marcadores = authProvider.leaderboard;
    final isLoading = authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Posiciones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: marcadores.length,
                itemBuilder: (context, index) {
                  final marcador = marcadores[index];
                  final isTop3 = index < 3;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isTop3
                          ? BorderSide(
                              color: index == 0
                                  ? Colors.amber
                                  : (index == 1 ? Colors.grey : Colors.brown),
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Position
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isTop3 ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Name and Stats
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  marcador.user?.nombreCompleto ??
                                      'Desconocido',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildStatIcon(
                                      Icons.timer,
                                      '${marcador.horas}h',
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatIcon(
                                      Icons.directions_car,
                                      '${marcador.visitas}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Points
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${marcador.puntos} pts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
