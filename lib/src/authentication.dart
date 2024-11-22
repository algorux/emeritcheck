// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    super.key,
    required this.loggedIn,
    required this.signOut,
  });

  final bool loggedIn;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PopupMenuItem<Text>(
          onTap: (){!loggedIn ? context.push('/sign-in') : signOut();},
          padding: const EdgeInsets.only(left: 30, bottom: 8),
          child: !loggedIn ? const StyledText(text: 'Iniciar sesion') : const StyledText(text: 'Salir'),
        ),
        Visibility(
          visible: loggedIn,
          child: PopupMenuItem<Text>(
            onTap:(){context.push('/profile');} ,
            padding: const EdgeInsets.only(left: 30, bottom: 8),
            child: const StyledText(text: 'Perfil')
          ),
        ),
        Visibility(
          visible: loggedIn,
          child: PopupMenuItem<Text>(
            onTap:(){context.push('/locations');} ,
            padding: const EdgeInsets.only(left: 30, bottom: 8),
            child: const StyledText(text: 'Mapa')
          ),
        ),
      ],
    );
  }
}
