import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:aplicativo_inclinometro/components/nav.dart';

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
        title: Text('Início'),
        backgroundColor: const Color(0xFFF07300),
        //centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFFFFEFE),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),

            /**
             * Esse trecho do código escreve na tela
             * o ângulo lateral
             */
            const Text(
              "Ângulo Lateral",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
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
                color: AnguloLateral.abs() > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Transform.rotate(
              angle: AnguloLateral * (pi / 180),
              child: Image.asset(
                'assets/truck1.png',
                width: 150,
                height: 150,
              ),
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
              "Ângulo Frontal",
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
                color: AnguloFrontal.abs() > 5.0 ? Colors.red : Colors.green,
              ),
            ),
            Transform.rotate(
              angle: AnguloFrontal * (pi / 180),
              child: Image.asset(
                'assets/truck2.png',
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
