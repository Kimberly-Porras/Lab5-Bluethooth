import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth File Transfer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> dispositivos = [];
  BluetoothDevice? seleccionado;
  String? archivoPath;
  String estado = 'Esperando...';

  @override
  void initState() {
    super.initState();
    solicitarPermisos();
    obtenerDispositivosEmparejados();
  }

  Future<void> solicitarPermisos() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.storage
    ].request();
  }

  Future<void> obtenerDispositivosEmparejados() async {
    final dispositivosEmp = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      dispositivos = dispositivosEmp;
    });
  }

  Future<void> seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        archivoPath = result.files.single.path;
      });
    }
  }

  Future<void> enviarArchivo() async {
    if (seleccionado == null || archivoPath == null) {
      setState(() {
        estado = 'Seleccione un dispositivo y un archivo';
      });
      return;
    }

    try {
      final connection = await BluetoothConnection.toAddress(seleccionado!.address);
      setState(() {
        estado = 'Conectado a ${seleccionado!.name}';
      });

      File archivo = File(archivoPath!);
      Uint8List bytes = await archivo.readAsBytes();

      connection.output.add(bytes);
      await connection.output.allSent;

      setState(() {
        estado = 'Archivo enviado: ${path.basename(archivoPath!)}';
      });

      connection.finish();
    } catch (e) {
      setState(() {
        estado = 'Error al enviar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth File Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<BluetoothDevice>(
              hint: const Text('Seleccionar dispositivo'),
              value: seleccionado,
              onChanged: (nuevo) {
                setState(() {
                  seleccionado = nuevo;
                });
              },
              items: dispositivos
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d.name ?? d.address),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: seleccionarArchivo,
              child: const Text('Seleccionar archivo'),
            ),
            if (archivoPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Archivo: ${path.basename(archivoPath!)}'),
              ),
            ElevatedButton(
              onPressed: enviarArchivo,
              child: const Text('Enviar archivo'),
            ),
            const SizedBox(height: 20),
            Text(estado, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
