import 'dart:io'; // Para trabajar con archivos desde el sistema
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Para seleccionar archivos desde el dispositivo
import 'package:permission_handler/permission_handler.dart'; // Para solicitar permisos en tiempo de ejecución
import 'package:share_plus/share_plus.dart'; // Para compartir archivos usando el sistema
import 'package:path/path.dart' as path; // Para obtener el nombre del archivo

void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compartir Archivos',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple, // Color principal
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const FileSharePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Página principal donde se manejan las acciones del usuario
class FileSharePage extends StatefulWidget {
  const FileSharePage({super.key});

  @override
  State<FileSharePage> createState() => _FileSharePageState();
}

class _FileSharePageState extends State<FileSharePage> {
  String estado = 'Esperando...'; // Mensaje de estado
  File? archivoSeleccionado; // Archivo que se seleccionará

  @override
  void initState() {
    super.initState();
    solicitarPermisos(); // Al iniciar, solicita permisos
  }

  /// Solicita permisos de almacenamiento, Bluetooth y ubicación
  Future<void> solicitarPermisos() async {
    await [
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  /// Permite al usuario seleccionar un archivo del sistema
  Future<void> seleccionarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles();
    if (resultado != null && resultado.files.single.path != null) {
      setState(() {
        archivoSeleccionado = File(resultado.files.single.path!);
        estado =
            'Archivo seleccionado: ${path.basename(archivoSeleccionado!.path)}';
      });
    }
  }

  /// Comparte el archivo seleccionado utilizando el sistema operativo
  Future<void> compartirArchivo() async {
    if (archivoSeleccionado == null) {
      setState(() => estado = 'Por favor, seleccione un archivo.');
      return;
    }

    try {
      await Share.shareXFiles([
        XFile(archivoSeleccionado!.path),
      ], text: 'Te comparto este archivo 📎');
      setState(() => estado = 'Archivo compartido correctamente.');
    } catch (e) {
      setState(() => estado = 'Error al compartir: $e');
    }
  }

  /// Construye la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50], // Fondo claro
      appBar: AppBar(
        title: const Text('Compartir Archivos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón para seleccionar archivo con animación
            AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(
                  Icons.folder_open,
                  color: Colors.white,
                  size: 32,
                ),
                label: const Text('Seleccionar archivo'),
                onPressed: seleccionarArchivo,
              ),
            ),

            const SizedBox(height: 20),

            // Botón para compartir el archivo con animación
            AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.share, color: Colors.white, size: 32),
                label: const Text('Compartir archivo'),
                onPressed: compartirArchivo,
              ),
            ),

            const SizedBox(height: 30),

            // Tarjeta para mostrar el nombre del archivo y el estado
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      archivoSeleccionado != null
                          ? path.basename(archivoSeleccionado!.path)
                          : 'No se ha seleccionado ningún archivo.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      estado,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
