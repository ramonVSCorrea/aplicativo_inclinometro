import 'package:flutter/material.dart';

class CalibrateSensorPage extends StatefulWidget {
  @override
  _CalibrateSensorPage createState() => _CalibrateSensorPage();
}

final double BloqueioLateral = 0.2;
final double BloqueioFrontal = 1.3;

class _CalibrateSensorPage extends State<CalibrateSensorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Calibrar Sensor',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 230, 4), // Cor do título
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF07300),
      ),
      body: Container(
        padding: const EdgeInsets.only(
          top: 60,
          left: 40,
          right: 40,
        ),
        color: Color(0xFFF07300),
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 70,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: const Text(
                "Calibração Lateral:",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 255, 230, 4),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              '$BloqueioLateralº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: BloqueioLateral > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Divider(
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: const Text(
                "Calibração Frontal:",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 255, 230, 4),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              '$BloqueioFrontalº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: BloqueioFrontal > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            // Defina a largura do botão como 200 pixels
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica do botão "Calibrar" aqui
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 255, 230, 4),
                  onPrimary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  'CALIBRAR',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // Defina a largura do botão "Limpar" como 200 pixels
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica do botão "Limpar" aqui
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 255, 230, 4),
                  onPrimary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  'LIMPAR',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
