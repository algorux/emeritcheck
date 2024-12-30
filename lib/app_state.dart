import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emeritcheck/permitido.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'revisores.dart';
import 'firebase_options.dart';
import 'usuarios.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<Usuarios> _usuarios = [];
  List<Usuarios> get usuarios => _usuarios;

  List<Permitido> _permitidos = [];
  List<Permitido> get permitidos => _permitidos;

  StreamSubscription<QuerySnapshot>? _allowanceList;
  AllowedReview _revisor = AllowedReview(usuarioRevisor: '', rol: '');
  AllowedReview get revisor => _revisor;
  String? revisorId;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);


 Future<void> fetchRevisorId(String email) async {
    // Paso 1: Consultar la colección "revisores" para obtener el ID del revisor
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Revisores')
        .where('usuario_revisor', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Obtener el ID del documento (revisor)
      var snap = querySnapshot.docs.first;
      revisorId = snap.id;
      _revisor = AllowedReview(usuarioRevisor: snap.get('usuario_revisor'), rol: snap.get('rol'), revisorId: snap.id);
      

      
      
      if (revisorId == null) return;
    // Paso 2: Iniciar la suscripción a la subcolección correspondiente 
      _allowanceList = FirebaseFirestore.instance
      .collection("Revisores")
      .doc(revisorId)
      .collection('personasRevisadas')
      .snapshots()
      .listen((snapshot){
        if (snapshot.docs.isNotEmpty) {
          // Limpiar la lista antes de agregar nuevos elementos
          _permitidos = [];

          for (final document in snapshot.docs) {
            _permitidos.add(
              Permitido(
                correo: document.data()['correo'] as String,
                fecNac: document.data()['fecNac'] as Timestamp,
                //fecRegistro: document.data()['fecRegistro'] as Timestamp,
                //modificado: document.data()['modificado'] as Timestamp,
                apellidos: document.data()['apellidos'] as String,
                nombre: document.data()['nombre'] as String,
                //modificador: email,
                id: document.id,
                //agresor: document.data()['agresor'],
              ),
            );
        }
          } else {
            // Si no hay documentos, inicializa _revisors con valores por defecto
            _revisor = AllowedReview(usuarioRevisor: '', rol: '');
          }
        
        notifyListeners();
      });
    }
  }


    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        fetchRevisorId(user.email!);

        //suscripcion al "guestboot"
        _guestBookSubscription = FirebaseFirestore.instance
        .collection('Usuarios')
          .where('email', isEqualTo: user.email)
          //.where('gepos.latitude', isNotEqualTo: 0.0)
          .limit(50)
          .orderBy('fecha_reg', descending: true)
          .snapshots()
          .listen((snapshot) {
        _usuarios = [];
        for (final document in snapshot.docs) {
          int fc = (document.data()['frecuencia_cardiaca'] as num).toInt();
          
          _usuarios.add(
            Usuarios(
              email: document.data()['email'] as String,
              fechaReg: document.data()['fecha_reg'] as Timestamp,
              gepos: document.data()['gepos'] as GeoPoint?,
              frecuenciaCardiaca: fc
            ),
          );
        }
        notifyListeners();
        });
      } else {
        _loggedIn = false;
        _usuarios = [];
        _guestBookSubscription?.cancel();
        _permitidos = [];

        _revisor = AllowedReview(usuarioRevisor: '', rol: '');
        _allowanceList?.cancel();
      }
      notifyListeners();
    });
  }

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  
}

