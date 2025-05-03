// ignore_for_file: unused_import

import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplicativo_inclinometro/components/bluetooth_functions.dart';

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPage createState() => _ConnectPage();
}

class _ConnectPage extends State<ConnectPage> {
  @override
  void initState() {
    super.initState();
    _getBondedDevices();
    //loadConnectedDevice();
  }

  Future<void> _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      discoveryResults = bondedDevices.map((device) {
        return BluetoothDiscoveryResult(
          device: device,
          rssi: -55,
        );
      }).toList();
    });
  }

  Future<void> _startDiscovery() async {
    setState(() {
      isDiscovering = true;
      discoveryResults = [];
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      setState(() {
        discoveryResults.add(result);
      });
    });

    await Future.delayed(Duration(seconds: 10));
    FlutterBluetoothSerial.instance.cancelDiscovery();
    setState(() {
      isDiscovering = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Mostrar diálogo de progresso de conexão
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Conectando a ${device.name ?? 'dispositivo'}..."),
            ],
          ),
        );
      },
    );

    try {
      // Tentativa de conexão
      connection = await BluetoothConnection.toAddress(device.address);

      // Fechar o diálogo de progresso
      Navigator.of(context).pop();

      // Se chegou aqui, a conexão foi bem-sucedida
      setState(() {
        connectedDevice = device;
        connected = true;
      });

      // Salvar dispositivo e iniciar comunicação
      isRunning = true;
      comunicBluetooth();
      saveConnectedDevice(device);

      // Mostrar diálogo de sucesso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Conectado",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Conectado com sucesso a ${device.name ?? 'dispositivo'}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFF07300),
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );

    } catch (error) {
      // Fechar o diálogo de progresso
      Navigator.of(context).pop();

      // Mostrar diálogo de erro
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String errorMessage = error.toString();
          String simplifiedMessage;

          // Mensagem de erro simplificada
          if (errorMessage.contains('timed out')) {
            simplifiedMessage = "Tempo esgotado ao tentar conectar";
          } else if (errorMessage.contains('rejected')) {
            simplifiedMessage = "Conexão rejeitada pelo dispositivo";
          } else {
            simplifiedMessage = "Não foi possível conectar ao dispositivo";
          }

          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Erro",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  simplifiedMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFF07300),
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );

      print('Erro de conexão: $error');
    }
  }

  void saveConnectedDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('connectedDeviceName', device.name ?? '');
    prefs.setString('connectedDeviceAddress', device.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectar Sensor'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
      ),
      body: Column(
        children: <Widget>[
          if (connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Conectado a: ${connectedDevice!.name}"),
            ),
          ElevatedButton(
            onPressed: isDiscovering ? null : _startDiscovery,
            child: Text('Buscar Novos Dispositivos'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Color(0xFFF07300)), // Altere a cor aqui
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: discoveryResults.length,
              itemBuilder: (context, index) {
                final result = discoveryResults[index];
                final device = result.device;
                return ListTile(
                  title: Text(device.name ?? 'Nome Desconhecido'),
                  subtitle: Text(device.address),
                  onTap: () {
                    // Conecte-se ao dispositivo quando o usuário tocar no item da lista
                    _connectToDevice(device);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
