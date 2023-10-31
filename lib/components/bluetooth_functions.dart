import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<BluetoothDiscoveryResult> discoveryResults = [];
bool isDiscovering = false;
bool requestCfg = false;
bool requestLeitura = false;
late bool isRunning;
int cont = 0;
BluetoothDevice? connectedDevice;

void listenBluetooth() async {
  connection?.input?.listen((Uint8List data) {
    final msgBT = String.fromCharCodes(data);

    if (msgBT.isNotEmpty) {
      try {
        print('Received message: $msgBT');
        final jsonData = jsonDecode(msgBT);

        if (jsonData.containsKey('configuracoes')) {
          final configs = jsonData['configuracoes'];

          if (configs.containsKey('bloqueioLateral') &&
              configs.containsKey('bloqueioFrontal')) {
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

          if (leituras.containsKey('anguloLateral') &&
              leituras.containsKey('anguloFrontal')) {
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
  while (isRunning) {
    if (!sendingMSG) {
      if (!requestCfg) {
        String msgBT = '{"requisitaCfg": 1}';

        try {
          connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
          await connection!.output.allSent;
          print('Mensagem enviada: $msgBT');
        } catch (ex) {
          print('Erro ao enviar mensagem: $ex');
        }
      } else if (requestLeitura) {
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

Future<void> loadConnectedDevice() async {
  final prefs = await SharedPreferences.getInstance();
  final deviceName = prefs.getString('connectedDeviceName');
  final deviceAddress = prefs.getString('connectedDeviceAddress');

  print('name: $deviceName - address: $deviceAddress');

  if(deviceName != null && deviceAddress != null && !connected){
    connection = await BluetoothConnection.toAddress(deviceAddress);
    //setState(() {
      connectedDevice = BluetoothDevice(name: deviceName, address: deviceAddress);
      connected = true;
    //});
    isRunning = true;
    comunicBluetooth();
  }

  // else {
  //   _getBondedDevices();
  // }
}