import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'usuarios.dart';
class PointMap extends StatelessWidget {
  final List<Usuarios> usuarios;

  const PointMap({super.key, required this.usuarios});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(23.649793, -102.559588), // Centra el mapa en México
        initialZoom: 5.5, // Zoom inicial
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: usuarios
                  .asMap()
                  .entries
                  .where((entry) =>
                      entry.value.gepos != null &&
                      entry.value.gepos?.latitude != 0.0) // Ignorar geopos nulos
                  .map((entry) {
                    return LatLng(entry.value.gepos!.latitude, entry.value.gepos!.longitude);
                  })
                  .toList(), // Convertir el Iterable en una lista
              color: Colors.red,
              strokeWidth: 15  ,
            ),
          ],
    ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

class ThisPointMap extends StatefulWidget {
  final String email; // Correo para filtrar los usuarios.
  const ThisPointMap({super.key, required this.email});

  @override
  State<ThisPointMap> createState() => _ThisPointMapState();
  
}

class _ThisPointMapState extends State<ThisPointMap> {
  late StreamSubscription<QuerySnapshot> _userSubscription;
  List<Usuarios> _usuarios = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emerit Monitor'),
      ),
      body: PointMap(usuarios: _usuarios),
    ); 
    
  }

   @override
  void initState() {
    super.initState();
    _subscribeToUsers(widget.email); // Inicia la suscripción al mapa.
  }
  @override
  void didUpdateWidget(ThisPointMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.email != widget.email) {
      // Si cambia el correo, actualiza la suscripción.
      _userSubscription.cancel();
      _subscribeToUsers(widget.email);
    }
  }
  @override
  void dispose() {
    _userSubscription.cancel(); // Cancela la suscripción cuando se destruye el widget.
    super.dispose();
  }

  void _subscribeToUsers(String email) {
    _userSubscription = FirebaseFirestore.instance
        .collection('Usuarios')
        .where('email', isEqualTo: email)
        .limit(50)
        .orderBy('fecha_reg', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _usuarios = snapshot.docs.map((doc) {
          final data = doc.data();
          return Usuarios(
            email: data['email'] as String,
            fechaReg: data['fecha_reg'] as Timestamp,
            gepos: data['gepos'] as GeoPoint?,
            frecuenciaCardiaca: (data['frecuencia_cardiaca'] as num).toInt(),
          );
        }).toList();
      });
    });
  }
}