// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header(this.heading, {super.key});
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content, {super.key});
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail, {super.key});
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              detail,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

class StyledText extends StatelessWidget{
  final String text;
  const StyledText({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    
    return Text(
              text,
              style: const TextStyle(
                fontSize: 16, // Tamaño de la fuente
                fontWeight: FontWeight.w600, // Grosor de la fuente
                color: Colors.deepPurple, // Color del texto
              ),
              );
  }
}
class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed, super.key});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepPurple)),
        onPressed: onPressed,
        child: child,
      );
}

class StyledTextBt extends StatelessWidget {
  const StyledTextBt({required this.child, required this.onPressed, super.key});

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 16, // Tamaño de la fuente
            fontWeight: FontWeight.w600, // Grosor de la fuente
          ),
        ),
        foregroundColor: WidgetStateProperty.all(Colors.deepPurple), // Color del texto
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}