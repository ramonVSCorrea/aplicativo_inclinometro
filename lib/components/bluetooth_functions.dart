import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<BluetoothDiscoveryResult> discoveryResults = [];
bool isDiscovering = false;
bool requestCfg = false;
bool sendDate = false;
//bool requestLeitura = false;
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

          if (jsonData.containsKey('configurations') && jsonData.containsKey('wifiConfigs')) {
            final configs = jsonData['configurations'];
            final wifiConfigs = jsonData['wifiConfigs'];

            if (configs.containsKey('blockLateralAngle') &&
                configs.containsKey('blockFrontalAngle') &&
                wifiConfigs.containsKey('SSID') &&
                wifiConfigs.containsKey('password')) {
              bloqueioLateral = configs['blockLateralAngle'].toDouble();
              bloqueioFrontal = configs['blockFrontalAngle'].toDouble();
              calibracaoLateral = configs['calibrateLateralAngle'].toDouble();
              calibracaoFrontal = configs['calibrateFrontalAngle'].toDouble();
              ssid = wifiConfigs['SSID'];
              password = wifiConfigs['password'];

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
          else if(jsonData.containsKey('totalEventos')) {
            totalEventos = jsonData['totalEventos'];
            requestTotalEventos = true;
          }

          else if(jsonData.containsKey('evento')){
            Map<String, dynamic> mapaEvento = jsonData['evento'];

            Evento novoEvento = Evento(
                data: mapaEvento['data'],
                hora: mapaEvento['hora'],
                tipoEvento: mapaEvento['tipoEvento'],
                angLat: mapaEvento['AngLat'],
                angFront: mapaEvento['AngFront']
            );

            eventos.add(novoEvento);

            requestLerEvento = true;
          }

          else if(jsonData.containsKey('bascula')){
            if(jsonData['bascula'] == 1){
              requestMovimentaBascula = true;
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
      if(!sendDate){
        Map<String, dynamic> jsonData = {
          "alteraData": {
            "dia": DateTime.now().day,
            "mes": DateTime.now().month,
            "ano": DateTime.now().year,
            "hora": DateTime.now().hour,
            "minuto": DateTime.now().minute,
          }
        };

        String msgBT = jsonEncode(jsonData);

        try {
          connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
          await connection!.output.allSent;
          print('Mensagem enviada: $msgBT');
          sendDate = true;
        } catch (ex) {
          print('Erro ao enviar mensagem: $ex');
          connected = false;
          loadConnectedDevice();
        }
      }
      else if (!requestCfg) {
        String msgBT = '{"requisitaCfg": 1}\n';

        try {
          connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
          await connection!.output.allSent;
          print('Mensagem enviada: $msgBT');
        } catch (ex) {
          print('Erro ao enviar mensagem: $ex');
          connected = false;
          loadConnectedDevice();
        }
      } else if (requestLeitura && !requestTotalEventos && !requestLerEvento) {
        String msgBT = '{"requisicaoLeitura": 1}\n';

        try {
          connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
          await connection!.output.allSent;
          print('Mensagem enviada: $msgBT');
        } catch (ex) {
          print('Erro ao enviar mensagem: $ex');
          connected = false;
          loadConnectedDevice();
        }
        requestLeitura = false;
      }

      if (cont >= 10) {
        cont = 0;
        if(!requestLerEvento && !requestTotalEventos)
          requestLeitura = true;
      } else {
        cont++;
      }
    }
    // Aguarde um período de tempo (por exemplo, 1 segundo) antes de enviar a próxima mensagem.
    await Future.delayed(Duration(milliseconds: 500));
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