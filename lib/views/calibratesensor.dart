// ignore_for_file: unused_local_variable

import 'package:aplicativo_inclinometro/components/create_custom_container.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:typed_data';

class CalibrateSensorPage extends StatefulWidget {
  @override
  _CalibrateSensorPage createState() => _CalibrateSensorPage();
}

class _CalibrateSensorPage extends State<CalibrateSensorPage> {
  @override
  void initState() {
    super.initState();
    sendingMSG = true;
  }

  @override
  void dispose() {
    sendingMSG = false;
    super.dispose();
  }

  void sendMessage(int cmd) async {
    //sendingMSG = true;
    String msgBT = '{"configuraCalib": $cmd}';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calibrar Sensor',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Nav()));
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 40,
        ),
        color: Color(0xFFF6F6F6),
        child: ListView(
          children: <Widget>[
            // Calibração Lateral
            Container(
              child: Text(
                "Calibrar Sensor Lateral",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              '${calibracaoLateral.toStringAsFixed(2)}º',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                // color:
                //     calibracaoLateral.abs() < 5.0 ? Colors.red : Colors.green,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomContainer(
                  child: Transform.rotate(
                    angle: calibracaoLateral * (pi / 180),
                    child: Image.asset(
                      'assets/truck1.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),

            // Linha divisora
            Divider(
              color: Colors.black,
            ),

            // Calibração Frontal
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 40),
              child: Text(
                "Calibrar Sensor Frontal",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '${calibracaoFrontal.toStringAsFixed(2)}º',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                // color:
                //     calibracaoFrontal.abs() > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomContainer(
                  child: Transform.rotate(
                    angle: calibracaoFrontal * (pi / 180),
                    child: Image.asset(
                      'assets/truck2.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),

            CustomButton(
              label: "Calibrar",
              onPressed: () {
                sendMessage(1);
                calibracaoLateral = anguloLateral;
                calibracaoFrontal = anguloFrontal;
                setState(() {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Seu sensor foi calibrado!"),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text("Fechar"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              buttonWidth: 10,
              backgroundColor: Colors.green,
            ),

            CustomButton(
              label: "Limpar",
              onPressed: () {
                sendMessage(0);
                calibracaoLateral = 0;
                calibracaoFrontal = 0;
                setState(() {
                  //if (calibracaoLateral == 0 && calibracaoFrontal == 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Seu item já foi limpado"),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text("Fechar"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  //} else {

                  //}
                });
              },
              buttonWidth: 20,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
