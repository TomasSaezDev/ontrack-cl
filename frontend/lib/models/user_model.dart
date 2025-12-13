class User {
  final int id;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String? rut;
  final int puntos;
  final int horas;
  final int visitas;

  User({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.rut,
    this.puntos = 0,
    this.horas = 0,
    this.visitas = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nombreCompleto: json['nombreCompleto'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
      rut: json['rut'],
      puntos: json['puntos'] ?? 0,
      horas: json['horas'] ?? 0,
      visitas: json['visitas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'rol': rol,
      'rut': rut,
      'puntos': puntos,
      'horas': horas,
      'visitas': visitas,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.nombreCompleto == nombreCompleto &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ nombreCompleto.hashCode ^ email.hashCode;
}
