class User {
  final int id;
  final String nombreCompleto;
  final String email;
  final String rol;

  User({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nombreCompleto: json['nombreCompleto'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
    );
  }
}
