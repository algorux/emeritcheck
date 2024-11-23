

class Suscripciones {
  final String correo;
  final bool estatus;
  final String grupo;
  final String tipo;

  Suscripciones({
    required this.correo,
    required this.estatus,
    required this.tipo,
    required this.grupo,
  });

  // Constructor para mapear datos desde Firestore
  factory Suscripciones.fromFirestore(Map<String, dynamic> data) {
    return Suscripciones(
      correo: data['correo'] as String? ?? '', // Valor predeterminado si es nulo
      estatus: data['estatus'] as bool? ?? false, // Por defecto false
      grupo: data['grupo'] as String? ?? 'ninguno', 
      tipo: data['tipo'] as String, 
    );
  }
}