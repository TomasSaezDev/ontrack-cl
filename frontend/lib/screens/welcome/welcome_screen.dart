import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinSlowController;
  late AnimationController _spinReverseSlowController;
  late AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _spinSlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _spinReverseSlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);

    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _spinSlowController.dispose();
    _spinReverseSlowController.dispose();
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE10600);
    const backgroundColor = Color(0xFF050505);
    const surfaceDark = Color(0xFF121212);
    const textSecondary = Color(0xFFA3A3A3);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Layers
          const _BackgroundLayers(primaryColor: primaryColor),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header Section
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      // Beta Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 8,
                              height: 8,
                              child: Stack(
                                children: [
                                  FadeTransition(
                                    opacity: Tween(
                                      begin: 1.0,
                                      end: 0.0,
                                    ).animate(_pingController),
                                    child: ScaleTransition(
                                      scale: Tween(
                                        begin: 1.0,
                                        end: 2.0,
                                      ).animate(_pingController),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BETA 2.0',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Welcome Text
                      Text(
                        'BIENVENIDO A',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 3,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ON-TRACK Logo Text
                      Transform(
                        transform: Matrix4.skewX(-0.17), // approx -10 deg
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.0,
                            ),
                            children: const [
                              TextSpan(text: 'ON'),
                              TextSpan(
                                text: '-',
                                style: TextStyle(color: primaryColor),
                              ),
                              TextSpan(text: 'TRACK'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'La experiencia definitiva de automovilismo\nen tu bolsillo.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Center Graphic (Spinner)
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer slow spin
                          RotationTransition(
                            turns: _spinSlowController,
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                          // Inner reverse spin
                          RotationTransition(
                            turns: _spinReverseSlowController,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width:
                                      1, // Dashed effect tricky in basic border, solid for now or CustomPainter
                                ),
                              ),
                            ),
                          ),
                          // Center Icon
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceDark,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(225, 6, 0, 0.15),
                                  blurRadius: 30,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.sports_score,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          // Pulse effect ring
                          FadeTransition(
                            opacity: Tween(
                              begin: 0.2,
                              end: 0.0,
                            ).animate(_pingController),
                            child: ScaleTransition(
                              scale: Tween(
                                begin: 1.0,
                                end: 1.2,
                              ).animate(_pingController),
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section
                  Column(
                    children: [
                      // Features
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _FeatureItem(
                              icon: Icons.emoji_events,
                              label: 'Recompensas',
                              hoverColor: primaryColor,
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            const _FeatureItem(
                              icon: Icons.speed,
                              label: 'Marcadores',
                              hoverColor: Colors.blue,
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            const _FeatureItem(
                              icon: Icons.flag,
                              label: 'Torneos',
                              hoverColor: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                      // CTA Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'COMENZAR',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Footer
                      Text(
                        '© 2023 ON-TRACK CL',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color
  hoverColor; // Note: Hover effects on mobile are limited to press states usually

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[500], size: 24),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class _BackgroundLayers extends StatelessWidget {
  final Color primaryColor;

  const _BackgroundLayers({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Left Red Blob
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(0.4),
                  primaryColor.withOpacity(0.0),
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        // Bottom Right Blue Blob
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.0),
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),

        // Speed Lines (Skewed)
        Positioned.fill(
          child: Transform(
            transform: Matrix4.skewX(-0.21), // approx -12 deg
            child: CustomPaint(painter: _SpeedLinesPainter()),
          ),
        ),

        // Grid Pattern
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: CustomPaint(painter: _GridPainter()),
          ),
        ),

        // Vignette
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0, // approximates transparent 40% -> black 100%
                colors: [Colors.transparent, Colors.black, Colors.black],
                stops: [0.4, 0.9, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    // Drawing vertical lines every 50px
    // CSS was: repeating-linear-gradient(90deg, transparent, transparent 50px, rgba... 50px, ... 51px)
    // This creates vertical lines spaced by 50px
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(0.03) // Matching SVG stroke
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double gridSize = 40.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
