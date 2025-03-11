import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emeritcheck/agregar_usuario.dart';
import 'package:emeritcheck/alertas.dart';
import 'package:emeritcheck/detalle_usuario.dart';
import 'package:emeritcheck/map.dart';
import 'package:emeritcheck/permitido.dart';
import 'package:emeritcheck/point_map.dart';
import 'package:emeritcheck/revisores.dart';
import 'package:flutter/material.dart';
import 'package:emeritcheck/usuarios.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class AlertasNoAtendidas extends StatefulWidget {
  AlertasNoAtendidas({required super.key})
  @override
  _AlertasNoAtendidasState createState() => _AlertasNoAtendidasState();
}

class _AlertasNoAtendidasState extends State<AlertasNoAtendidas> {
  List<Alertas> alertas = [];
   @override
   Widget build (BuildContext context){
    return 
   }
}


/// This is the stateless widget that the main application instantiates.
class PeopleTable extends StatefulWidget {
  PeopleTable({required super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PeopleTableState createState() => _PeopleTableState();
}

class _PeopleTableState extends State<PeopleTable> {
  List<Permitido> users = [];
  List<Permitido> usersFiltered = [];
  TextEditingController controller = TextEditingController();
  String _searchResult = '';

  @override
  void initState() {
    super.initState();
    usersFiltered = users;
  }

  void eliminarUsuario(String idUsuario, String? idRevisor, BuildContext context) async {
    if (idRevisor == null || idRevisor == "") return;
  try {
    await FirebaseFirestore.instance
        .collection('Revisores')
        .doc(idRevisor)
        .collection('personasRevisadas')
        .doc(idUsuario)
        .delete();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario eliminado correctamente')),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al eliminar el usuario')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    AllowedReview? revisado = context.watch<ApplicationState>().revisor;
    List<dynamic>? disponibles = context.watch<ApplicationState>().permitidos;
    
    users = [];
    
    for (var disponible in disponibles) {
      
      users.add(Permitido(
        apellidos: disponible.apellidos, 
        correo: disponible.correo,
        modificado: disponible.modificado,
        modificador: disponible.modificador,
        nombre: disponible.nombre,
        fecNac: disponible.fecNac,
        id: disponible.id,
        agresor: disponible.agresor,
        ));
    }
    
    // Nos aseguramos de que usersFiltered esté sincronizado con users
    usersFiltered = _searchResult.isEmpty
      ? users
      : users.where((user) => user.nombre.contains(_searchResult) || user.apellidos.contains(_searchResult)|| user.correo.contains(_searchResult)).toList();
    final dateFormat = DateFormat('dd/MM/yyyy'); // Formato deseado para la fecha
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.search),
            title: TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: 'Buscar', border: InputBorder.none),
                onChanged: (value) {
                  setState(() { 
                    _searchResult = value;
                     usersFiltered = users.where((user) => user.nombre.contains(_searchResult) || user.apellidos.contains(_searchResult)|| user.correo.contains(_searchResult)).toList();
                  });
                }),
            trailing: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  controller.clear();
                  _searchResult = '';
                  usersFiltered = users;
                });
              },
            ),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Permite el desplazamiento horizontal
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width, // Ocupa al menos todo el ancho disponible
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Permite el desplazamiento vertical
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Nombre',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'F. Nacimiento',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Correo',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Acciones',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: List.generate(usersFiltered.length, (index) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text("${usersFiltered[index].nombre} ${usersFiltered[index].apellidos}")),
                        DataCell(Text(
                          dateFormat.format(
                            DateTime.fromMillisecondsSinceEpoch(usersFiltered[index].fecNac!.millisecondsSinceEpoch),
                          ),
                        )),
                        DataCell(Text(usersFiltered[index].correo)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue[600]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetalleUsuario(
                                        revisorId: revisado.revisorId,
                                        idUsuario: usersFiltered[index].id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () {
                                  eliminarUsuario(usersFiltered[index].id, revisado.revisorId, context);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.map, color: Colors.green[400]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ThisMap(email: usersFiltered[index].correo),
                                    ),
                                  );
                                },
                              ),
                              IconButton(icon: Icon(Icons.notification_important),onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ThisPointMap(email: usersFiltered[index].correo),
                                    ),
                                  );
                              })
                            ],
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ),
            ),
          ),

          Column(
          
            children: [FloatingActionButton(
            
            onPressed: () {
              
              if(revisado.revisorId != null && revisado.rol == 'admin'){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgregarUsuario(revisorId: revisado.revisorId!),
                ),
              );
              }
            },
            backgroundColor: Colors.blue[100],
            hoverColor: Colors.blueAccent,
            child: Icon(Icons.add),
            
          )],

          )
          
      ],
    );
  }
}