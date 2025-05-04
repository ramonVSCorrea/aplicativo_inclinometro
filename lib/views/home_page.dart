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
  final bool isAdminMode;

  HomePage({this.isAdminMode = false});

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
      } else {
        setState(() {
          connected = false;
        });
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
      backgroundColor: Colors.white,
      drawer: widget.isAdminMode ? null : SideBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra superior personalizada com altura reduzida
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão do drawer ou botão de voltar
                  widget.isAdminMode
                      ? IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFFFF4200), size: 28),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                      : Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFFFF4200), size: 28),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  // Botão de conexão do sensor
                  _buildConnectionButton(),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
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
                        fontSize: 30,
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
                        fontSize: screenWidth < 400 ? 30 : 50,
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
                        border: Border.all(
                          color: (anguloLateral.abs() >= bloqueioLateral)
                              ? Colors.red
                              : (anguloLateral.abs() >= bloqueioLateral * 0.7) &&
                              (anguloLateral.abs() < bloqueioLateral)
                              ? Colors.orange
                              : Colors.green,
                          width: 4.0,
                        ),
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
                        fontSize: 30,
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
                        fontSize: screenWidth < 400 ? 30 : 50,
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
                        border: Border.all(
                          color: (anguloFrontal.abs() >= bloqueioFrontal)
                              ? Colors.red
                              : (anguloFrontal.abs() >= bloqueioFrontal * 0.7) &&
                              (anguloFrontal.abs() < bloqueioFrontal)
                              ? Colors.orange
                              : Colors.green,
                          width: 4.0,
                        ),
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
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => enviaMovimentaBascula(true),
            child: Icon(Icons.arrow_upward, color: Colors.white),
            backgroundColor: const Color(0xFFFF4200),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => enviaMovimentaBascula(false),
            child: Icon(Icons.arrow_downward, color: Colors.white),
            backgroundColor: const Color(0xFFFF4200),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionButton() {
    return GestureDetector(
      onTap: _handleConnectionButtonPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: connected ? Color(0xFF0055AA) : Color(0xFFFF4200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              connected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_searching,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              connected ? 'Conectado' : 'Conectar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConnectionButtonPressed() async {
    if (connected) {
      // Se estiver conectado, desconecta
      _disconnectDevice();
    } else {
      // Verificar se já existe um dispositivo salvo
      final prefs = await SharedPreferences.getInstance();
      String? savedAddress = prefs.getString('connectedDeviceAddress');

      if (savedAddress != null && savedAddress.isNotEmpty) {
        // Tenta reconectar ao dispositivo salvo
        _reconnectToSavedDevice(savedAddress);
      } else {
        // Se não existe dispositivo salvo, navega para a página de conexão
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectPage(),
          ),
        ).then((_) {
          // Atualiza o estado após retornar da ConnectPage
          setState(() {});
        });
      }
    }
  }

  void _disconnectDevice() async {
    // Mostrar diálogo de confirmação
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Desconectar"),
          content: Text("Deseja realmente desconectar do sensor?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Desconectar"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      try {
        // Parar a execução da comunicação Bluetooth
        isRunning = false;

        // Fechar a conexão
        if (connection != null) {
          await connection!.close();
          connection = null;
        }

        // Atualizar o estado
        setState(() {
          connected = false;
          connectedDevice = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dispositivo desconectado')),
        );
      } catch (e) {
        print('Erro ao desconectar: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao desconectar: $e')),
        );
      }
    }
  }

  void _reconnectToSavedDevice(String address) async {
    // Mostrar diálogo de reconexão
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
              Text("Reconectando ao sensor..."),
            ],
          ),
        );
      },
    );

    try {
      // Tentativa de reconexão
      connection = await BluetoothConnection.toAddress(address);

      // Obter o nome do dispositivo antes de atualizar o estado
      final prefs = await SharedPreferences.getInstance();
      String? deviceName = prefs.getString('connectedDeviceName');

      // Fechar o diálogo de progresso
      Navigator.of(context).pop();

      // Se chegou aqui, a conexão foi bem-sucedida
      setState(() {
        connectedDevice = BluetoothDevice(
          address: address,
          name: deviceName,
        );
        connected = true;
      });

      // Iniciar comunicação
      isRunning = true;
      comunicBluetooth();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reconectado com sucesso')),
      );
    } catch (error) {
      // Fechar o diálogo de progresso
      Navigator.of(context).pop();

      // Mostrar página de conexão se falhar a reconexão
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectPage(),
        ),
      ).then((_) {
        // Atualiza o estado após retornar da ConnectPage
        setState(() {});
      });
    }
  }}
