// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarUsuario extends StatefulWidget {
  final String revisorId; // ID del revisor para asociar el usuario

  const AgregarUsuario({super.key, required this.revisorId});

  @override
  // ignore: library_private_types_in_public_api
  _AgregarUsuarioState createState() => _AgregarUsuarioState();
}

class _AgregarUsuarioState extends State<AgregarUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  DateTime? _fechaNacimiento;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _guardarUsuario() async {
    if (_formKey.currentState?.validate() == true && _fechaNacimiento != null) {
      try {
        // Agregar el nuevo usuario a Firestore
        await FirebaseFirestore.instance
            .collection('Revisores')
            .doc(widget.revisorId)
            .collection('personasRevisadas')
            .add({
          'nombre': _nombreController.text.trim(),
          'apellidos': _apellidosController.text.trim(),
          'correo': _correoController.text.trim(),
          'fecNac': Timestamp.fromDate(_fechaNacimiento!),
          'modificado': Timestamp.now(),
          'fecRegistro': Timestamp.now(),
          'modificador': widget.revisorId,
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario agregado exitosamente')),
        );

        // Volver a la vista anterior
        Navigator.pop(context);
      } catch (e) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el usuario: $e')),
        );
      }
    } else {
      // Validar campos vacíos o sin fecha de nacimiento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Usuario Revisado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese un nombre válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _apellidosController,
                  decoration: InputDecoration(labelText: 'Apellidos'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese apellidos válidos';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _correoController,
                  decoration: InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Fecha de Nacimiento'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _fechaNacimiento != null
                          ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                          : 'Seleccionar fecha',
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _fechaNacimiento = selectedDate;
                          });
                        }
                      },
                      child: Text('Seleccionar'),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _guardarUsuario,
                    child: Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
