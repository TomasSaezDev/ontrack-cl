
class Simulador {
  final int id;
  final String nombre;

  Simulador({
    required this.id,
    required this.nombre,
  });


  factory Simulador.fromJson(Map<String, dynamic> json) {
    return Simulador(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}