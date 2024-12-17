
class AllowedReview {
  final String usuarioRevisor;
  final String rol;
  final List<dynamic>? displonibles; // GeoPoint puede ser nulo
  

  AllowedReview({
    required this.usuarioRevisor,
    required this.rol,
    this.displonibles, // Puede ser opcional
    
  });

  // Constructor para mapear datos desde Firestore
  factory AllowedReview.fromFirestore(Map<String, dynamic> data) {
    return AllowedReview(
      usuarioRevisor: data['usuario_revisor'] as String? ?? '', // Valor predeterminado si es nulo
      rol: data['rol'] as String? ?? '', // Por defecto ''
      displonibles: data['displonibles'] as List<dynamic>?, // Puede ser nulo
    );
  }
}