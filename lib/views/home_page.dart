import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 1);

    Timer.periodic(duration, (Timer timer) {
      setState(() {});
    });
  }

  void sendMessage(bool cmd) async {
    String msgBT;

    if (cmd == true) {
      msgBT = '{"comandoBascula":{"subir": 1,"descer": 0}}';
    } else {
      msgBT = '{"comandoBascula":{"subir": 0,"descer": 1}}';
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
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Início',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // Ajuste de tamanho de fonte
            color: Colors.white,
          ),
        ),
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
                height: 30,
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
                connection == null ? '---' : '${anguloLateral.abs()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 30 : 50, // Ajuste de tamanho de fonte
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
                  fontSize:30, // Ajuste de tamanho de fonte
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                connection == null ? '---' : '${anguloFrontal.abs()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30, // Ajuste de tamanho de fonte
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
                      blurRadius:10,
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
            onPressed: () => sendMessage(true),
            child: Icon(Icons.arrow_upward),
            backgroundColor: const Color(0xFFF07300),
          ),
          SizedBox(height: 16), // Espaço entre os botões
          FloatingActionButton(
            onPressed: () => sendMessage(false),
            child: Icon(Icons.arrow_downward),
            backgroundColor: const Color(0xFFF07300),
          ),
        ],
      ),
    );
  }
}
