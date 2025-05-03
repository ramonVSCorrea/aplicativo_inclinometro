// ignore_for_file: unused_element, unused_field, unused_import, unused_local_variable
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:aplicativo_inclinometro/components/bluetooth_functions.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplicativo_inclinometro/components/sideBar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 0;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 1);
    loadConnectedDevice();
    if(connected)
      _checkBluetoothConnection();
    Timer.periodic(duration, (Timer timer) {
       setState(() {});
    });
  }

  Future<void> _checkBluetoothConnection() async{
    try {
      List<BluetoothDevice> bondedDevices = await _bluetooth.getBondedDevices();

      if (bondedDevices.isNotEmpty) {
        setState(() {
          connected = true;
        });
        print('Estou aqui');
      } else {
        setState(() {
          connected = false;
        });
        print('Estou aqui');
      }
    } catch(error){
      print('Erro ao verificar a conexão bluetooth: $error');
      setState(() {
        connected = false;
      });
    }
  }

  void enviaMovimentaBascula(bool cmd) async{
    int tentativas = 0;
    bool flagMsg = true;
    int cont = 0;

    while(flagMsg && tentativas < 500){
      sendMessage(cmd);
      while(true){
        if(requestMovimentaBascula){
          flagMsg = false;
          requestMovimentaBascula = false;
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
        cont++;
        if(cont == 300){
          cont = 0;
          break;
        }
      }
      tentativas++;
    }
  }

  void sendMessage(bool cmd) async {
    //sendingMSG = true;
    String msgBT;

    if (cmd == true) {
      msgBT = '{"comandoBascula":{"subir": 1,"descer": 0}}\n';
    } else {
      msgBT = '{"comandoBascula":{"subir": 0,"descer": 1}}\n';
    }

    if (connection == null) {
      print('Conexão Bluetooth não estabelecida!');
      return;
    }

    try {
      connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
      await connection!.output.allSent;
      print('Mensagem enviada: $msgBT');
    } catch (ex) {
      print('Erro ao enviar mensagem: $ex');
    }

    //sendingMSG = false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        title: Text(
          'Início',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // Ajuste de tamanho de fonte
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: connected
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                onPressed: () {
                  print('Icone Clicado');
                },
              ),
              Text(
                connected ? 'Conectado' : 'Desconectado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Ângulo Lateral",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30, // Ajuste de tamanho de fonte
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                connected == false ? '---' : '${anguloLateral.abs()}°',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                      screenWidth < 400 ? 30 : 50, // Ajuste de tamanho de fonte
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: (anguloLateral.abs() >= bloqueioLateral)
                      ? Colors.red
                      : (anguloLateral.abs() >= bloqueioLateral * 0.7) &&
                              (anguloLateral.abs() < bloqueioLateral)
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(70),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: anguloLateral * (pi / 180),
                    child: Image.asset(
                      'assets/truck1.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.black,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Ângulo Frontal",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30, // Ajuste de tamanho de fonte
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                connected == false ? '---' : '${anguloFrontal.abs()}°',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                      screenWidth < 400 ? 30 : 50, // Ajuste de tamanho de fonte
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: (anguloFrontal.abs() >= bloqueioFrontal)
                      ? Colors.red
                      : (anguloFrontal.abs() >= bloqueioFrontal * 0.7) &&
                              (anguloFrontal.abs() < bloqueioFrontal)
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(70),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: anguloFrontal * (pi / 180),
                    child: Image.asset(
                      'assets/truck2.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(

            //onPressed: () => sendMessage(true),
            onPressed: () => enviaMovimentaBascula(true),
            child: Icon(Icons.arrow_upward, color: Colors.white),
            backgroundColor: const Color(0xFFFF4200),

          ),
          SizedBox(height: 16),
          FloatingActionButton(
            //onPressed: () => sendMessage(false),
            onPressed: () => enviaMovimentaBascula(false),
            child: Icon(Icons.arrow_downward, color: Colors.white),
            backgroundColor: const Color(0xFFFF4200),
          ),
        ],
      ),
    );
  }
}
