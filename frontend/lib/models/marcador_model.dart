import 'user_model.dart';

class Marcador {
  final int id;
  final int userId;
  final int visitas;
  final int horas;
  final int puntos;
  final User? user;

  // New fields for time tracking
  final int tiempoTotal;
  final int tiempoRestante;
  final bool estaActivo;

  Marcador({
    required this.id,
    required this.userId,
    required this.visitas,
    required this.horas,
    required this.puntos,
    this.user,
    this.tiempoTotal = 0,
    this.tiempoRestante = 0,
    this.estaActivo = false,
  });

  factory Marcador.fromJson(Map<String, dynamic> json) {
    return Marcador(
      id: json['id'],
      userId: json['userId'],
      visitas: json['visitas'] ?? 0,
      horas: json['horas'] ?? 0,
      puntos: json['puntos'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      tiempoTotal: json['totalTime'] ?? 0,
      tiempoRestante: json['timeRemaining'] ?? 0,
      estaActivo: json['isActive'] ?? false,
    );
  }
}
