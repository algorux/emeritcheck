

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';





import 'usuarios.dart';
import 'lista.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    //final usuarios = context.watch<ApplicationState>().usuarios;
    Widget pagina;
    switch (selectedIndex) {
      case 0:
        pagina = PeopleTable(key: null,);
        
      case 1:
        pagina = Lista();
        
      //case 2:
        //pagina = ThisMap(user.email);
        
      default:
        throw UnimplementedError('No hay widget para $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  //extended: false,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list),
                      label: Text('Lista'),
                    ),
                    //NavigationRailDestination(
                    //  icon: Icon(Icons.map), 
                    //  label: Text('Mapa')),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                    
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: pagina,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}



class MyMap extends StatelessWidget {
  final List<Usuarios> usuarios;

  const MyMap({super.key, required this.usuarios});

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
        MarkerLayer(
          markers: usuarios
              .asMap()
              .entries
              .where((entry) => entry.value.gepos != null && entry.value.gepos?.latitude != 0.0) // Ignorar geopos nulos
              .map(
                
                (entry) {
                  final index = entry.key;
                  final usuario = entry.value;
                  final color = Color.lerp(Colors.red, Colors.blue, index / usuarios.length) ?? Colors.red;

                  return Marker(
                  point: LatLng(usuario.gepos!.latitude, usuario.gepos!.longitude),
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: (){
                      final fechaHora = DateTime.fromMillisecondsSinceEpoch(
                        usuario.fechaReg.millisecondsSinceEpoch,
                      );
                      var fc = usuario.frecuenciaCardiaca.toString();
                      if(usuario.frecuenciaCardiaca == 0){
                        fc = "No se pudo tomar la frecuencia";
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('FC: $fc  Hora: ${fechaHora.day}/${fechaHora.month}/${fechaHora.year} ${fechaHora.hour}:${fechaHora.minute.toString().padLeft(2, '0')}'
                          ),
                          duration: const Duration(seconds: 3),)
                      );
                    },
                    child: Icon(
                    Icons.location_pin,
                    color: color,
                    size: 40,
                  ),
                  )
                );
                } 
              )
              .toList().reversed.toList(),
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

class ThisMap extends StatefulWidget {
  final String email; // Correo para filtrar los usuarios.
  const ThisMap({super.key, required this.email});

  @override
  State<ThisMap> createState() => _ThisMapState();
  
}

class _ThisMapState extends State<ThisMap> {
  late StreamSubscription<QuerySnapshot> _userSubscription;
  List<Usuarios> _usuarios = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emerit Monitor'),
      ),
      body: MyMap(usuarios: _usuarios),
    ); 
    
  }

   @override
  void initState() {
    super.initState();
    _subscribeToUsers(widget.email); // Inicia la suscripción al mapa.
  }
  @override
  void didUpdateWidget(ThisMap oldWidget) {
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