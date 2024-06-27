import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MenuApp());
}

class Exportacion {
  final int id;
  final String producto;
  final String kilos;
  final double preciodolar;
  final DateTime fecha;

  Exportacion({
    required this.id,
    required this.producto,
    required this.kilos,
    required this.preciodolar,
    required this.fecha,
  });

  factory Exportacion.fromJson(Map<String, dynamic> json) {
    return Exportacion(
      id: json['id'],
      producto: json['producto'],
      kilos: json['kilos'],
      preciodolar: json['preciodolar'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto': producto,
      'kilos': kilos,
      'preciodolar': preciodolar,
      'fecha': fecha.toIso8601String(),
    };
  }
}

class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 198, 190, 231),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 29, 27, 154),
        title: Text('Exportaciones',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MenuButton(
                text: 'Ir a Exportaciones',
                color: const Color.fromARGB(255, 45, 36, 170),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListarExportacionesScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  MenuButton(
      {required this.text, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ListarExportacionesScreen extends StatefulWidget {
  @override
  _ListarExportacionesScreenState createState() =>
      _ListarExportacionesScreenState();
}

class _ListarExportacionesScreenState extends State<ListarExportacionesScreen> {
  List<Exportacion> exportaciones = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    cargarExportaciones();
  }

  Future<void> cargarExportaciones() async {
    setState(() {
      isLoading = true;
    });
    final url =
        Uri.parse('http://jpnet08-001-site1.htempurl.com/SENA/exportacion');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'your-user-agent',
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List) {
          setState(() {
            exportaciones =
                jsonData.map((item) => Exportacion.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'La respuesta de la API no es una lista.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Error al cargar las exportaciones: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Excepción al cargar las exportaciones: $e';
      });
    }
  }

  Future<void> agregarExportacion(Exportacion exportacion) async {
    final url =
        Uri.parse('http://jpnet08-001-site1.htempurl.com/SENA/exportacion');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'your-user-agent',
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
        },
        body: json.encode(exportacion.toJson()),
      );

      if (response.statusCode == 201) {
        setState(() {
          exportaciones.add(Exportacion.fromJson(json.decode(response.body)));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al agregar la exportación: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción al agregar la exportación: $e')),
      );
    }
  }

  Future<void> editarExportacion(Exportacion exportacion) async {
    final url = Uri.parse(
        'http://jpnet08-001-site1.htempurl.com/SENA/exportacion/${exportacion.id}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'your-user-agent',
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
        },
        body: json.encode(exportacion.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          int index = exportaciones.indexWhere((e) => e.id == exportacion.id);
          if (index != -1) {
            exportaciones[index] = exportacion;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al editar la exportación: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción al editar la exportación: $e')),
      );
    }
  }

  Future<void> eliminarExportacion(int id) async {
    final url =
        Uri.parse('http://jpnet08-001-site1.htempurl.com/SENA/exportacion/$id');
    try {
      final response = await http.delete(url, headers: {
        'User-Agent': 'your-user-agent',
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
      });

      if (response.statusCode == 204) {
        setState(() {
          exportaciones.removeWhere((exportacion) => exportacion.id == id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al eliminar la exportación: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción al eliminar la exportación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 29, 27, 154),
        title: const Text('Exportaciones'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarExportaciones,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: exportaciones.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: const Color.fromARGB(255, 171, 147, 216),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(exportaciones[index].producto),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kilos: ${exportaciones[index].kilos}'),
                              Text(
                                  'Precio en Dólar: ${exportaciones[index].preciodolar}'),
                              Text(
                                  'Fecha: ${exportaciones[index].fecha.toLocal()}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue[900]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditarExportacionScreen(
                                        exportacion: exportaciones[index],
                                        onEdit: (updatedExportacion) {
                                          editarExportacion(updatedExportacion);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  eliminarExportacion(exportaciones[index].id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarExportacionScreen(
                onAdd: (newExportacion) {
                  agregarExportacion(newExportacion);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 35, 27, 154),
      ),
    );
  }
}

class AgregarExportacionScreen extends StatelessWidget {
  final Function(Exportacion) onAdd;

  const AgregarExportacionScreen({Key? key, required this.onAdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Exportación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Producto'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Kilos'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Precio en Dólar'),
            ),
            ElevatedButton(
              onPressed: () {
// Aquí se debería realizar la lógica para enviar la exportación al servidor
// y luego llamar al método onAdd con la nueva exportación creada.
              },
              child: Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditarExportacionScreen extends StatelessWidget {
  final Exportacion exportacion;
  final Function(Exportacion) onEdit;

  const EditarExportacionScreen(
      {Key? key, required this.exportacion, required this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Exportación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Producto'),
              controller: TextEditingController(text: exportacion.producto),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Kilos'),
              controller: TextEditingController(text: exportacion.kilos),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Precio en Dólar'),
              controller: TextEditingController(
                  text: exportacion.preciodolar.toString()),
            ),
            ElevatedButton(
              onPressed: () {
// Aquí se debería realizar la lógica para enviar la exportación actualizada al servidor
// y luego llamar al método onEdit con la exportación actualizada.
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
