

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';



import 'app_state.dart';
import 'usuarios.dart';


class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  

  
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final usuarios = context.watch<ApplicationState>().usuarios;
    Widget pagina;
    switch (selectedIndex) {
      case 0:
        pagina = const Placeholder();
        
      case 1:
        pagina = const Placeholder();
        
      case 2:
        pagina = ThisMap(messages: usuarios);
        
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
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map), 
                      label: Text('Mapa')),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                    //print('selected: $value');
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
                  child: Icon(
                    Icons.location_pin,
                    color: color,
                    size: 40,
                  ),
                );
                } 
              )
              .toList(),
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
  const ThisMap({super.key, required this.messages});

  final List<Usuarios> messages;

  @override
  State<ThisMap> createState() => _ThisMapState();
}

class _ThisMapState extends State<ThisMap> {
  @override
  Widget build(BuildContext context) {
    return MyMap(usuarios: widget.messages);
  }
}