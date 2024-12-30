import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleUsuario extends StatefulWidget {
  final String? idUsuario;
  final String? revisorId;

  const DetalleUsuario({super.key, required this.idUsuario, required this.revisorId});

  @override
  // ignore: library_private_types_in_public_api
  _DetalleUsuarioState createState() => _DetalleUsuarioState();
}

class _DetalleUsuarioState extends State<DetalleUsuario> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _correoController;
  late TextEditingController _modificadorController;

  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Revisores')
          .doc(widget.revisorId)
          .collection('personasRevisadas')
          .doc(widget.idUsuario)
          .get();

      if (snapshot.exists) {
        _data = snapshot.data();
        _nombreController = TextEditingController(text: _data?['nombre']);
        _apellidosController = TextEditingController(text: _data?['apellidos']);
        _correoController = TextEditingController(text: _data?['correo']);
        _modificadorController = TextEditingController(text: _data?['modificador']);
      }
    } catch (e) {
      // Manejar errores si es necesario
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('Revisores')
            .doc(widget.revisorId)
            .collection('personasRevisadas')
            .doc(widget.idUsuario)
            .update({
          'nombre': _nombreController.text,
          'apellidos': _apellidosController.text,
          'correo': _correoController.text,
          'modificador': _modificadorController.text,
          'modificado': FieldValue.serverTimestamp(),
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos actualizados correctamente')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar los datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle del Usuario'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle del Usuario'),
        ),
        body: Center(child: Text('Usuario no encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'El nombre no puede estar vacío' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _apellidosController,
                decoration: InputDecoration(labelText: 'Apellidos'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Los apellidos no pueden estar vacíos' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo'),
                validator: (value) {
                    if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _modificadorController,
                decoration: InputDecoration(labelText: 'Modificador'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateData,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
