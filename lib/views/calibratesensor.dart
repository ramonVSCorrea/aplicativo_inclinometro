import 'package:aplicativo_inclinometro/components/create_custom_container.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CalibrateSensorPage extends StatefulWidget {
  @override
  _CalibrateSensorPage createState() => _CalibrateSensorPage();
}

class _CalibrateSensorPage extends State<CalibrateSensorPage> {
  double calibracaoLateral = 3.5;
  double calibracaoFrontal = 8.2;

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
              '$calibracaoLateralº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color:
                    calibracaoLateral.abs() < 5.0 ? Colors.red : Colors.green,
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
              '$calibracaoFrontalº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color:
                    calibracaoFrontal.abs() > 5.0 ? Colors.red : Colors.green,
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
                setState(() {
                  if (calibracaoLateral == 0 && calibracaoFrontal == 0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Seu item já está calibrado"),
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
                  } else {
                    calibracaoLateral = 0;
                    calibracaoFrontal = 0;
                  }
                });
              },
              buttonWidth: 10,
              backgroundColor: Colors.green,
            ),

            CustomButton(
              label: "Limpar",
              onPressed: () {
                setState(() {
                  if (calibracaoLateral == 0 && calibracaoFrontal == 0) {
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
                  } else {
                    calibracaoLateral = 0;
                    calibracaoFrontal = 0;
                  }
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
