import 'package:aplicativo_inclinometro/components/create_custom_container.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LockAnglePage extends StatefulWidget {
  @override
  _LockAnglePageState createState() => _LockAnglePageState();
}

class _LockAnglePageState extends State<LockAnglePage> {
  double BloqueioLateral = 0;
  double BloqueioFrontal = 0;

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
              '$BloqueioLateralº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: BloqueioLateral.abs() < 5.0 ? Colors.red : Colors.green,
              ),
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
                SizedBox(width: 25),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          BloqueioLateral++;
                        });
                      },
                      child: Icon(Icons.add, size: 10),
                      mini: true,
                      backgroundColor: Colors.blue,
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          BloqueioLateral--;
                        });
                      },
                      child: Icon(Icons.remove, size: 10),
                      mini: true,
                      backgroundColor: Colors.red,
                    ),
                  ],
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
              '$BloqueioFrontalº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: BloqueioFrontal.abs() > 5.0 ? Colors.red : Colors.green,
              ),
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
                SizedBox(width: 25),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          BloqueioFrontal++;
                        });
                      },
                      child: Icon(Icons.add, size: 10),
                      mini: true,
                      backgroundColor: Colors.blue,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          BloqueioFrontal--;
                        });
                      },
                      child: Icon(Icons.remove, size: 10),
                      mini: true,
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              label: "Salvar",
              onPressed: () {
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
                            title: Text("Bloqueio Lateral: $BloqueioLateralº"),
                          ),
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text("Bloqueio Frontal: $BloqueioFrontalº"),
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
