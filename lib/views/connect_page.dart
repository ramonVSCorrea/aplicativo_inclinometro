import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

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
  bool requestCfg = false;
  bool requestLeitura = false;
  late bool _isRunning;
  int cont = 0;

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
      _isRunning = true;
      comunicBluetooth();
      //listenBluetooth();
      // Realize ações de comunicação com o dispositivo aqui
    } catch (error) {
      print('Erro de conexão: $error');
    }
  }

  void listenBluetooth() async{
    connection?.input?.listen((Uint8List data) {
      final msgBT = String.fromCharCodes(data);

      if (msgBT.isNotEmpty) {
        try {
          print('Received message: $msgBT');
          final jsonData = jsonDecode(msgBT);

          if (jsonData.containsKey('configuracoes')) {
            final configs = jsonData['configuracoes'];

            if (configs.containsKey('bloqueioLateral') && configs.containsKey('bloqueioFrontal')) {
              bloqueioLateral = configs['bloqueioLateral'].toDouble();
              bloqueioFrontal = configs['bloqueioFrontal'].toDouble();
              calibracaoLateral = configs['calibracaoLateral'].toDouble();
              calibracaoFrontal = configs['calibracaoFrontal'].toDouble();
              print('mensagem recebida com sucesso!');
              requestCfg = true;
              requestLeitura = true;
              cont = 0;
            }
          } else if (jsonData.containsKey('leituras')) {
            final leituras = jsonData['leituras'];

            if (leituras.containsKey('anguloLateral') && leituras.containsKey('anguloFrontal')) {
              anguloLateral = leituras['anguloLateral'];
              anguloFrontal = leituras['anguloFrontal'];
              print('mensagem de leitura recebida com sucesso!');
              requestLeitura = true;
              cont = 0;
            }
          }
        } catch (e) {
          print('Erro ao fazer parse do JSON: $e');
        }
      }
    });
  }

  void comunicBluetooth() async {
    listenBluetooth();
    while (_isRunning) {
      if(!sendingMSG) {
        if (!requestCfg) {
          String msgBT = '{"requisitaCfg": 1}';

          try {
            connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
            await connection!.output.allSent;
            print('Mensagem enviada: $msgBT');
          } catch (ex) {
            print('Erro ao enviar mensagem: $ex');
          }
        }

        else if (requestLeitura) {
          String msgBT = '{"requisicaoLeitura": 1}';

          try {
            connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
            await connection!.output.allSent;
            print('Mensagem enviada: $msgBT');
          } catch (ex) {
            print('Erro ao enviar mensagem: $ex');
          }
          requestLeitura = false;
        }

        if (cont >= 10) {
          cont = 0;
          requestLeitura = true;
        } else {
          cont++;
        }
      }
        // Aguarde um período de tempo (por exemplo, 1 segundo) antes de enviar a próxima mensagem.
        await Future.delayed(Duration(seconds: 1));
    }
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
          ElevatedButton(
            onPressed: isDiscovering ? null : _startDiscovery,
            child: Text('Buscar Novos Dispositivos'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFF07300)), // Altere a cor aqui
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