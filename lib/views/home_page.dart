import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

final double AnguloLateral = 8.2;
final double AnguloFrontal = 3.7;

class _HomePage extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ângulos'),
        backgroundColor: const Color(0xFFF07300),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(
          top: 60,
          left: 40,
          right: 40,
        ),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),

            /**
             * Esse trecho do código escreve na tela
             * o ângulo lateral
             */
            const Text(
              "ÂNGULO LATERAL",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            Text(
              ' $AnguloLateralº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AnguloLateral > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('assets/truck1.png'),
            ),
            const SizedBox(
              height: 20,
            ),
            /**
             * Desenha a linha divisora
             */
            Divider(
              color: Colors.black,
            ),
            /**
             * Esse trecho escreve na tela o ângulo frontal
             */
            const SizedBox(
              height: 50,
            ),
            const Text(
              "ÂNGULO FRONTAL",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '$AnguloFrontalº',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AnguloFrontal > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(
              width: 150,
              height: 200,
              child: Image.asset('assets/truck2.png'),
            ),
          ],
        ),
      ),
    );
  }
}
