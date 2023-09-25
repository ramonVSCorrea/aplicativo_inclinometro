import 'package:flutter/material.dart';

class LockAnglePage extends StatefulWidget {
  @override
  _LockAnglePage createState() => _LockAnglePage();
}

final double BloqueioLateral = 3.5;
final double BloqueioFrontal = 5.0;

class _LockAnglePage extends State<LockAnglePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Largura da tela

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Ângulo de Bloqueio',
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

            /**
             * Esse trecho do código escreve na tela
             * o ângulo lateral
             */
            Container(
              margin: EdgeInsets.only(left: 20.0), // Margem de 20 pixels à esquerda
              child: const Text(
                "Bloqueio Lateral",
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

            /**
             * Desenha a linha divisora
             */
            Divider(
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            /**
             * Esse trecho escreve na tela o ângulo frontal
             */
            const SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0), // Margem de 20 pixels à esquerda
              child: const Text(
                "ÂNGULO FRONTAL",
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
            SizedBox(
              height: 70,
            ),

            // Defina a largura do botão como 50% da largura da tela
            SizedBox(
              width: screenWidth * 0.5, // 50% da largura da tela
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica do botão "Salvar" aqui
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 255, 230, 4), // Cor de fundo
                  onPrimary: Colors.black, // Cor do texto preto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Border radius
                  ),
                ),
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    fontSize: 30, // Tamanho da fonte
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
