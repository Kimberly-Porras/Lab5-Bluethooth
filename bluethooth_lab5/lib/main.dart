import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

/// Aplicación principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compartir Archivos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FileSharePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Página principal de la app
class FileSharePage extends StatefulWidget {
  const FileSharePage({super.key});

  @override
  State<FileSharePage> createState() => _FileSharePageState();
}

class _FileSharePageState extends State<FileSharePage> {
  String estado = 'Esperando...';
  File? archivoSeleccionado;

  @override
  void initState() {
    super.initState();
    solicitarPermisos();
  }

  /// Solicita los permisos necesarios en Android
  Future<void> solicitarPermisos() async {
    await [
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  /// Selecciona un archivo desde el sistema
  Future<void> seleccionarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles();
    if (resultado != null && resultado.files.single.path != null) {
      setState(() {
        archivoSeleccionado = File(resultado.files.single.path!);
        estado = 'Archivo seleccionado: ${path.basename(archivoSeleccionado!.path)}';
      });
    }
  }

  /// Comparte el archivo con el sistema Android (Bluetooth, Nearby, WhatsApp, etc.)
  Future<void> compartirArchivo() async {
    if (archivoSeleccionado == null) {
      setState(() => estado = 'Por favor, seleccione un archivo.');
      return;
    }

    try {
      await Share.shareXFiles([XFile(archivoSeleccionado!.path)], text: 'Te comparto este archivo 📎');
      setState(() => estado = 'Archivo compartido correctamente.');
    } catch (e) {
      setState(() => estado = 'Error al compartir: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartir Archivos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: seleccionarArchivo,
              child: const Text('Seleccionar archivo'),
            ),
            const SizedBox(height: 10),
            if (archivoSeleccionado != null)
              Text('Archivo: ${path.basename(archivoSeleccionado!.path)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: compartirArchivo,
              child: const Text('Compartir archivo'),
            ),
            const SizedBox(height: 30),
            Text(
              estado,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
