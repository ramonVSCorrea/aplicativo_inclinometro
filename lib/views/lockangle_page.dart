import 'dart:typed_data';

import 'package:aplicativo_inclinometro/components/create_custom_container.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class LockAnglePage extends StatefulWidget {
  @override
  _LockAnglePageState createState() => _LockAnglePageState();
}

class _LockAnglePageState extends State<LockAnglePage> {
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

  double BloqueioLateral = bloqueioLateral;
  double BloqueioFrontal = bloqueioFrontal;

  void sendMessage() async{
    String msgBT = '{"configuracoesBLQ":{"bloqueioLateral": ${bloqueioLateral.toStringAsFixed(2)},"bloqueioFrontal": ${bloqueioFrontal.toStringAsFixed(2)}}}';

    if(connection == null){
      print('Conexão Bluetooth não estabelecida!');
      return;
    }

    try{
      connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
      await connection!.output.allSent;
      print('Mensagem enviada: $msgBT');
    } catch(ex){
      print('Erro ao enviar mensagem: $ex');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Largura da tela

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Ângulo de Bloqueio',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
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
        padding: const EdgeInsets.only(
          top: 30,
          left: 40,
          right: 40,
        ),
        color: Color.fromARGB(255, 246, 246, 246),
        child: ListView(
          children: <Widget>[
            /**
             * Esse trecho do código escreve na tela
             * o ângulo lateral
             */
            Container(
              margin: EdgeInsets.only(left: 40.0),
              child: const Text(
                "Bloqueio Lateral",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            Text(
              '${BloqueioLateral.toStringAsFixed(2)}º',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                //color: BloqueioLateral.abs() < 5.0 ? Colors.red : Colors.green,
              ),
            ),

            Slider(
              min: 0.0,
              max: 8.0,
              activeColor: const Color(0xFFF07300),
              inactiveColor: const Color(0x67F07300),
              value: BloqueioLateral,
              onChanged: (value){
                setState(() {
                  BloqueioLateral = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomContainer(
                  child: Transform.rotate(
                    angle: BloqueioLateral * (pi / 180),
                    child: Image.asset(
                      'assets/truck1.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),

            /**
             * Desenha a linha divisora
             */
            Divider(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            /**
             * Esse trecho escreve na tela o ângulo frontal
             */
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 40.0),
              child: const Text(
                "Bloqueio Frontal",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '${BloqueioFrontal.toStringAsFixed(2)}º',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                //color: bloqueio.abs() > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            Slider(
              min: 0.0,
              max: 10.0,
              activeColor: const Color(0xFFF07300),
              inactiveColor: const Color(0x67F07300),
              value: BloqueioFrontal,
              onChanged: (value){
                setState(() {
                  BloqueioFrontal = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomContainer(
                  child: Transform.rotate(
                    angle: BloqueioFrontal * (pi / 180),
                    child: Image.asset(
                      'assets/truck2.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              label: "Salvar",
              onPressed: () {
                bloqueioLateral = BloqueioLateral;
                bloqueioFrontal = BloqueioFrontal;
                sendMessage();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Valores Salvos"),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text("Bloqueio Lateral: ${bloqueioLateral.toStringAsFixed(2)}º"),
                          ),
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text("Bloqueio Frontal: ${bloqueioFrontal.toStringAsFixed(2)}º"),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
