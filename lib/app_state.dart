import 'dart:async';
//import 'dart:ffi';   
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
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
          _usuarios.add(
            Usuarios(
              email: document.data()['email'] as String,
              fechaReg: document.data()['fecha_reg'] as Timestamp,
              gepos: document.data()['gepos'] as GeoPoint?,
              frecuenciaCardiaca: document.data()['frecuencia_cardiaca'] as int
            ),
          );
        }
        notifyListeners();
        });
      } else {
        _loggedIn = false;
        _usuarios = [];
        _guestBookSubscription?.cancel();
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

