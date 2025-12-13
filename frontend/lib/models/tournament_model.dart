class Tournament {
  final int id;
  final String nombre;
  final String? descripcion;
  final DateTime fechaInicio;
  final int premio;
  final bool estado;

  Tournament({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.fechaInicio,
    required this.premio,
    required this.estado,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      premio: json['premio'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'premio': premio,
      'estado': estado,
    };
  }
}
