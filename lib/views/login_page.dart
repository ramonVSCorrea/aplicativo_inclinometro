import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false; // Estado para rastrear a opção de lembrar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          top: 60,
          left: 40,
          right: 40,
        ),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 128,
              height: 128,
              child: Image.asset('assets/logo.png'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Login",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "E-mail",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            EmailField(), // Utilizando o componente de e-mail
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Senha",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            PasswordField(), // Utilizando o componente de senha
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const Text(
                      "Lembrar",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Esqueceu senha?",
                  style: TextStyle(
                    color: Color(0xFF2805FF),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            CustomButton(
              label: "Entrar",
              onPressed: () {},
            ),
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Container(
                height: 240,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Não tem conta? ",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Cadastre-se",
                      style: TextStyle(
                        color: Color(0xFF2805FF),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
