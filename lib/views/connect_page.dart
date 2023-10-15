import 'dart:typed_data';
import 'dart:convert';

import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class ConnectPage extends StatefulWidget {
  @override
  _ConnectPage createState() => _ConnectPage();
}

class _ConnectPage extends State<ConnectPage> {
  List<BluetoothDiscoveryResult> discoveryResults = [];
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  Future<void> _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
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
        connection?.input?.listen((Uint8List data) {
          final msgBT = String.fromCharCodes(data);

          if(msgBT.isNotEmpty){
            try{
              print('Received message: $msgBT');
              final jsonData = jsonDecode(msgBT);
              if(jsonData.containsKey('leituras')){
                final leituras = jsonData['leituras'];
                if(leituras.containsKey('anguloLateral') && leituras.containsKey('anguloFrontal')){
                  anguloLateral = leituras['anguloLateral'];
                  anguloFrontal = leituras['anguloFrontal'];
                  print('mensagem recebida com sucesso!');
                }
              }
            } catch (e){
              print('Erro ao fazer parse do JSON: $e');
            }
          }
        });

      // Realize ações de comunicação com o dispositivo aqui
    } catch (error) {
      print('Erro de conexão: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Dispositivos Bluetooth'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: isDiscovering ? null : _startDiscovery,
            child: Text('Buscar Dispositivos Bluetooth'),
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