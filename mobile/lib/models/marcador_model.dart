import 'user_model.dart';

class Marcador {
  final int id;
  final int userId;
  final int visitas;
  final int horas;
  final int puntos;
  final User? user;

  Marcador({
    required this.id,
    required this.userId,
    required this.visitas,
    required this.horas,
    required this.puntos,
    this.user,
  });

  factory Marcador.fromJson(Map<String, dynamic> json) {
    return Marcador(
      id: json['id'],
      userId: json['userId'],
      visitas: json['visitas'] ?? 0,
      horas: json['horas'] ?? 0,
      puntos: json['puntos'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
