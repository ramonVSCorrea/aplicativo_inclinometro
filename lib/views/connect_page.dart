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
    //BluetoothConnection connection;
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connectedDevice = device;
        connected = true;
      });
      isRunning = true;
      comunicBluetooth();
      saveConnectedDevice(device);
      //listenBluetooth();
      // Realize ações de comunicação com o dispositivo aqui
    } catch (error) {
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
