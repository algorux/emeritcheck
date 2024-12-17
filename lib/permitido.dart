
import 'package:cloud_firestore/cloud_firestore.dart';

class Permitido {
  final String nombre;
  final Timestamp? fecNac;
  final Timestamp? fecRegistro;
  final Timestamp modificado;
  final String modificador;
  final String apellidos;
  final String correo;
  final String id;
 
  

  Permitido({
    required this.nombre,
    this.fecNac,
    this.fecRegistro,
    required this.modificador,
    required this.modificado,
    required this.apellidos,
    required this.correo,
    required this.id
    
    
  });

  // Constructor para mapear datos desde Firestore
  factory Permitido.fromFirestore(Map<String, dynamic> data) {
    return Permitido(
      nombre: data['nombre'] as String,
      correo: data['correo'] as String,
      apellidos: data['apellidos'] as String,
      fecNac: data['fecNac'] as Timestamp,
      modificado: data['modificado'] as Timestamp? ?? Timestamp.now(),
      fecRegistro: data['fecRegistro'] as Timestamp?,
      modificador: data['modificador'],
      id: data['id']
    );
  }
}