import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emeritcheck/permitido.dart';
import 'package:flutter/material.dart';
import 'package:emeritcheck/usuarios.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class Lista extends StatelessWidget{
  final List<Usuarios> items = List<Usuarios>.generate(
    50, (i) => Usuarios(email: '$i@hotmail.com', frecuenciaCardiaca: i+70, fechaReg: Timestamp(i, i*2)));
  @override
  Widget build(Object context) {
    
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) { 
        final item = items[index];
        return ListTile(
          title: Text(item.email),
          subtitle: Text('${item.frecuenciaCardiaca}'),
          onTap: (){

          },
        );
       },

    );
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

  @override
  Widget build(BuildContext context) {
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
        ));
    }
      
    
    // Nos aseguramos de que usersFiltered esté sincronizado con users
    usersFiltered = _searchResult.isEmpty
      ? users
      : users.where((user) => user.nombre.contains(_searchResult) || user.apellidos.contains(_searchResult)|| user.correo.contains(_searchResult)).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.search),
            title: TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: 'Search', border: InputBorder.none),
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
            scrollDirection: Axis.vertical,
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
                
                rows: List.generate(usersFiltered.length, (index) =>
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text("${usersFiltered[index].nombre} ${usersFiltered[index].apellidos}")),
                        DataCell(Text(DateTime.fromMicrosecondsSinceEpoch(usersFiltered[index].fecNac!.millisecondsSinceEpoch).toString())),
                        DataCell(Text(usersFiltered[index].correo)),
                        DataCell(
                          Row(children: [
                              IconButton(icon: Icon(Icons.edit, color: Colors.blue[600],),onPressed: (){
                                usersFiltered[index].id;
                                
                              }),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red[400],), onPressed: (){
                                
                              }),
                              IconButton( icon: Icon(Icons.map, color: Colors.green[400],), onPressed: (){

                              })
                            ])
                          ),
                      ],
                    ),
                ),
              ),
            )
          ),
      ],
    );
  }
}