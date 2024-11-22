
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuarios {
  final String email;
  final int frecuenciaCardiaca;
  final GeoPoint? gepos; // GeoPoint puede ser nulo
  final Timestamp fechaReg;

  Usuarios({
    required this.email,
    required this.frecuenciaCardiaca,
    this.gepos, // Puede ser opcional
    required this.fechaReg,
  });

  // Constructor para mapear datos desde Firestore
  factory Usuarios.fromFirestore(Map<String, dynamic> data) {
    return Usuarios(
      email: data['email'] as String? ?? '', // Valor predeterminado si es nulo
      frecuenciaCardiaca: data['frecuencia_cardiaca'] as int? ?? 0, // Por defecto 0
      gepos: data['geopos'] as GeoPoint?, // Puede ser nulo
      fechaReg: data['fecha_reg'] as Timestamp, // Convierte Timestamp a DateTime
    );
  }
}