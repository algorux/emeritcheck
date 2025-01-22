
import 'package:cloud_firestore/cloud_firestore.dart';

class Alertas {
  final bool atendida;
  final String email;
  final Map<String,dynamic>? ubicaciones;
  final Timestamp? fechaHora;
  bool mostrada;

  Alertas({
    required this.atendida,
    required this.email,
    required this.ubicaciones,
    required this.fechaHora,
    this.mostrada = false,
  });

  // Constructor para mapear datos desde Firestore
  factory Alertas.fromFirestore(Map<String, dynamic> data) {
    return Alertas(
      atendida: data['atendida'] as bool? ?? false, // Valor predeterminado si es nulo
      email: data['email'] as String? ?? '', // Por defecto ''
      ubicaciones: data['ubicaciones'] as Map<String,dynamic>?, // Puede ser nulo
      fechaHora: data['fecha_hora'] as Timestamp,
    );
  }
}