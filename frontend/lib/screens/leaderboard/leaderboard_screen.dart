import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/main_layout.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Colors from the HTML design
  static const Color primaryNeon = Color(0xFF00F2FF);
  static const Color backgroundDark = Color(0xFF050505);
  static const Color cardDark = Color(0xFF121212);

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

    return MainLayout(
      title: 'Tabla de Posiciones',
      body: Container(
        color: backgroundDark,
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: primaryNeon))
              : Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      itemCount: marcadores.length,
                      itemBuilder: (context, index) {
                        final marcador = marcadores[index];
                        final isFirst = index == 0;
                        final isTop3 = index < 3;

                        // Animate entry
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: isFirst
                              ? _buildFirstPlaceCard(marcador, index)
                              : _buildRegularCard(marcador, index, isTop3),
                        );
                      },
                    ),
                    // Gradient fade at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              backgroundDark,
                              backgroundDark.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFirstPlaceCard(dynamic marcador, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Neon glow effect
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryNeon.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          // Card content
          Container(
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryNeon.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryNeon.withOpacity(0.15),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: primaryNeon.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Position badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryNeon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '#1',
                        style: GoogleFonts.exo2(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: primaryNeon,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            marcador.user?.nombreCompleto ?? 'Desconocido',
                            style: GoogleFonts.exo2(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.timer, size: 14, color: primaryNeon),
                              const SizedBox(width: 4),
                              Text(
                                '${marcador.horas}h',
                                style: GoogleFonts.exo2(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryNeon,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.sports_motorsports, size: 14, color: primaryNeon),
                              const SizedBox(width: 4),
                              Text(
                                '${marcador.visitas}',
                                style: GoogleFonts.exo2(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryNeon,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Points section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LÍDER',
                        style: GoogleFonts.exo2(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryNeon,
                          letterSpacing: 2,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${marcador.puntos} ',
                              style: GoogleFonts.exo2(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: primaryNeon,
                              ),
                            ),
                            TextSpan(
                              text: 'pts',
                              style: GoogleFonts.exo2(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryNeon,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularCard(dynamic marcador, int index, bool isTop3) {
    final positionNumber = index + 1;
    final opacity = isTop3 ? 1.0 : 0.9;
    final positionColor = isTop3 
        ? Colors.grey[500]
        : Colors.grey[600];
    final nameColor = isTop3 
        ? Colors.grey[100]
        : Colors.grey[300];
    final statColor = isTop3 
        ? Colors.grey[400]
        : Colors.grey[500];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Position
              SizedBox(
                width: 32,
                child: Text(
                  '#$positionNumber',
                  style: GoogleFonts.exo2(
                    fontSize: isTop3 ? 24 : 20,
                    fontWeight: FontWeight.w800,
                    color: positionColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              // Name and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marcador.user?.nombreCompleto ?? 'Desconocido',
                      style: GoogleFonts.exo2(
                        fontSize: 16,
                        fontWeight: isTop3 ? FontWeight.bold : FontWeight.w600,
                        color: nameColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 12, color: statColor),
                        const SizedBox(width: 4),
                        Text(
                          '${marcador.horas}h',
                          style: GoogleFonts.exo2(
                            fontSize: 12,
                            color: statColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.sports_motorsports, size: 12, color: statColor),
                        const SizedBox(width: 4),
                        Text(
                          '${marcador.visitas}',
                          style: GoogleFonts.exo2(
                            fontSize: 12,
                            color: statColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isTop3 
                      ? Colors.grey[800]
                      : Colors.grey[800]!.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${marcador.puntos} pts',
                  style: GoogleFonts.exo2(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isTop3 ? Colors.grey[300] : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
