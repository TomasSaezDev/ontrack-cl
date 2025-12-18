import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../widgets/main_layout.dart';
import '../../../providers/marcador_provider.dart';

class MarcadorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const MarcadorDetailScreen({super.key, required this.user});

  @override
  State<MarcadorDetailScreen> createState() => _MarcadorDetailScreenState();
}

class _MarcadorDetailScreenState extends State<MarcadorDetailScreen> {
  late Map<String, dynamic> _marcador;
  Timer? _timer;
  final TextEditingController _timeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _marcador = Map<String, dynamic>.from(widget.user);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final marcadorProvider = Provider.of<MarcadorProvider>(
        context,
        listen: false,
      );
      final userId = _marcador['userId'];
      final timeInMinutes =
          (_marcador['totalTime'] ?? 3600) ~/
          60; // Convertir segundos a minutos

      final success = await marcadorProvider.startSession(
        userId,
        timeInMinutes,
      );

      if (success) {
        await _refreshMarcador();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión iniciada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Error al iniciar sesión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final marcadorProvider = Provider.of<MarcadorProvider>(
        context,
        listen: false,
      );
      final userId = _marcador['userId'];
      final currentTime = marcadorProvider.getLocalTime(userId);
      final isActiveNow = _marcador['isActive'] == true;
      final isActive = !isActiveNow; // Invertir el estado
      final totalTime = _marcador['totalTime'] ?? 0;

      print('🔵 [FRONTEND] _toggleSession iniciado');
      print('🔵 [FRONTEND] userId: $userId');
      print('🔵 [FRONTEND] Estado actual isActive: $isActiveNow');
      print('🔵 [FRONTEND] Nuevo estado isActive: $isActive');
      print('🔵 [FRONTEND] currentTime: $currentTime');
      print('🔵 [FRONTEND] totalTime: $totalTime');

      final success = await marcadorProvider.toggleSession(
        userId,
        currentTime,
        isActive,
        totalTime,
      );

      print('🔵 [FRONTEND] toggleSession resultado: $success');

      if (success) {
        await _refreshMarcador();
        print('🔵 [FRONTEND] Marcador actualizado después de toggle');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isActive ? 'Sesión iniciada' : 'Sesión pausada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ [FRONTEND] Error en toggleSession');
        setState(() {
          _errorMessage = 'Error al cambiar estado de sesión';
        });
      }
    } catch (e) {
      print('❌ [FRONTEND] Excepción en toggleSession: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTime(int additionalMinutes) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final marcadorProvider = Provider.of<MarcadorProvider>(
        context,
        listen: false,
      );
      final userId = _marcador['userId'];
      final currentTime = marcadorProvider.getLocalTime(userId);
      final isActive = _marcador['isActive'] == true;
      final totalTime = _marcador['totalTime'] ?? 0;

      final success = await marcadorProvider.addTime(
        userId,
        additionalMinutes,
        currentTime,
        isActive,
        totalTime,
      );

      if (success) {
        await _refreshMarcador();
        if (mounted) {
          final action = additionalMinutes > 0 ? 'agregaron' : 'quitaron';
          final absMinutes = additionalMinutes.abs();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se $action $absMinutes minutos'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Error al agregar tiempo';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setCustomTime() async {
    final timeText = _timeController.text;
    if (timeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un tiempo válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final totalMinutes = int.parse(timeText);
      if (totalMinutes <= 0) {
        throw FormatException('Tiempo debe ser mayor a 0');
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final marcadorProvider = Provider.of<MarcadorProvider>(
        context,
        listen: false,
      );
      final userId = _marcador['userId'];

      final success = await marcadorProvider.setTime(userId, totalMinutes);

      if (success) {
        await _refreshMarcador();
        _timeController.clear();
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar diálogo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tiempo establecido: $totalMinutes minutos'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Error al establecer tiempo';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: Ingrese un número válido';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMarcador() async {
    final marcadorProvider = Provider.of<MarcadorProvider>(
      context,
      listen: false,
    );
    final userId = _marcador['userId'];

    if (userId != null) {
      final updatedMarcador = await marcadorProvider.getMarcadorByUser(userId);
      if (updatedMarcador != null && mounted) {
        setState(() {
          _marcador = updatedMarcador;
        });
      }
    }
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showTimeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Establecer Tiempo Total',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingrese el tiempo total en minutos:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Minutos',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _timeController.clear();
                setState(() {
                  _errorMessage = null;
                });
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _setCustomTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Establecer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarcadorProvider>(
      builder: (context, marcadorProvider, child) {
        final userId = _marcador['userId'];
        final currentTime = userId != null
            ? marcadorProvider.getLocalTime(userId)
            : 0;
        final totalTime = _marcador['totalTime'] ?? 0;
        final progress = totalTime > 0
            ? (totalTime - currentTime) / totalTime
            : 0.0;
        final isActive = _marcador['isActive'] == true;
        final user = _marcador['user'] ?? _marcador;

        return MainLayout(
          title: 'Detalle del Marcador',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del usuario
                Card(
                  color: Colors.grey[900],
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isActive
                              ? Colors.green
                              : Colors.grey,
                          child: Icon(
                            isActive ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['nombreCompleto'] ?? 'Usuario desconocido',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                user['email'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green[800]
                                      : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  isActive
                                      ? 'SESIÓN ACTIVA'
                                      : 'SESIÓN INACTIVA',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // Tiempo actual
                Card(
                  color: Colors.grey[900],
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Tiempo Restante',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          _formatTime(currentTime),
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.grey,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isActive ? Colors.green : Colors.grey,
                          ),
                          minHeight: 8.0,
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Usado: ${_formatTime(totalTime - currentTime)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Total: ${_formatTime(totalTime)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // Mensaje de error
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Controles de sesión
                Card(
                  color: Colors.grey[900],
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Controles de Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Controles principales
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading || isActive
                                    ? null
                                    : _startSession,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? Colors.grey
                                      : Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                  disabledForegroundColor: Colors.white70,
                                ),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Iniciar'),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading || !isActive
                                    ? null
                                    : _toggleSession,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? Colors.red
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                  disabledForegroundColor: Colors.white70,
                                ),
                                icon: const Icon(Icons.pause),
                                label: const Text('Pausar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // Gestión de tiempo
                Card(
                  color: Colors.grey[900],
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestión de Tiempo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Botones de tiempo rápido
                        const Text(
                          'Agregar tiempo rápido:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildQuickTimeButton('+ 5 min', 5),
                            _buildQuickTimeButton('+ 10 min', 10),
                            _buildQuickTimeButton('+ 15 min', 15),
                            _buildQuickTimeButton('+ 30 min', 30),
                            _buildQuickTimeButton('+ 1 hora', 60),
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        // Botones para quitar tiempo
                        const Text(
                          'Quitar tiempo rápido:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildQuickTimeButton('- 5 min', -5),
                            _buildQuickTimeButton('- 10 min', -10),
                            _buildQuickTimeButton('- 15 min', -15),
                            _buildQuickTimeButton('- 30 min', -30),
                            _buildQuickTimeButton('- 1 hora', -60),
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        // Establecer tiempo personalizado
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _showTimeDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Establecer Tiempo Personalizado',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // Botón de actualizar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _refreshMarcador,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isLoading ? 'Actualizando...' : 'Actualizar Datos',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickTimeButton(String label, int minutes) {
    final isNegative = minutes < 0;
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _addTime(minutes),
      style: ElevatedButton.styleFrom(
        backgroundColor: isNegative ? Colors.orange[700] : Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      child: Text(label),
    );
  }
}
