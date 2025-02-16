import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuthService _auth = FirebaseAuthService();

  bool rememberMe = false;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



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
              child: Image.asset('assets/inclimaxLogo.png'),
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
            EmailField(
              controller: _emailController,
            ),
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
            PasswordField(
              controller: _passwordController,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Row(
                //   children: <Widget>[
                //     Checkbox(
                //       value: rememberMe,
                //       onChanged: (bool? value) {
                //         setState(() {
                //           rememberMe = value!;
                //         });
                //       },
                //     ),
                //     const Text(
                //       "Lembrar",
                //       style: TextStyle(
                //         fontFamily: 'Poppins',
                //         fontSize: 14,
                //         fontWeight: FontWeight.w400,
                //       ),
                //     ),
                //   ],
                // ),
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/resetPassword');
                  },
                  child: Container(
                    child: const Row(
                      children: [
                        const Text(
                          "Esqueceu sua senha?",
                          style: TextStyle(
                            color: Color(0xFF2805FF),
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            CustomButton(
              label: "Entrar",
              onPressed: () async {
                _signIn();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$errorSignUp'),
                  ));
                // final providedPassword = _passwordController.text;
                // final hashedPassword = hashPassword(providedPassword);
                //
                // final isAuthenticated =
                //     await UserRepository.instance.authenticateUser(
                //   _emailController.text,
                //   hashedPassword,
                // );
                //
                // if (isAuthenticated != null) {
                //   final pref = await SharedPreferences.getInstance();
                //   pref.setInt('userId', isAuthenticated);
                //   Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Nav(),
                //     ),
                //   );
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //     content: Text('Usuário ou senha inválidos'),
                //   ));
                // }
              },
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

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if(user != null){
      print("User is successfully signedIn");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Nav(),
          ),
        );
    } else {
      print("Some error happend");
    }
  }
}
