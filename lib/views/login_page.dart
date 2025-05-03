import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';
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

import 'admindashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuthService _auth = FirebaseAuthService();

  bool isLoading = false;
  bool _loginWithMatricula = true; // Definido como true para iniciar com matricula

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60, left: 40, right: 40),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 128,
              height: 128,
              child: Image.asset('assets/inclimaxLogo.png'),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),

            // Opções de login (matrícula ou e-mail - invertido)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _loginWithMatricula = true;
                        _loginController.clear();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _loginWithMatricula ? Color(0xFFFF4200) : Colors.grey.shade200,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)
                        ),
                      ),
                      child: Text(
                        "Operador",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _loginWithMatricula ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _loginWithMatricula = false;
                        _loginController.clear();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_loginWithMatricula ? Color(0xFFFF4200) : Colors.grey.shade200,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                      ),
                      child: Text(
                        "Administrador",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_loginWithMatricula ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              _loginWithMatricula ? "Código de Operador" : "E-mail",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(height: 10),

            // Campo de entrada dinâmico (matrícula ou e-mail)
            _loginWithMatricula ?
            _buildMatriculaField() :
            EmailField(controller: _loginController),

            const SizedBox(height: 20),
            const Text(
              "Senha",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(height: 10),
            PasswordField(controller: _passwordController),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/resetPassword');
                  },
                  child: Container(
                    child: const Row(
                      children: [
                        Text(
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
            const SizedBox(height: 5),
            isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
                : CustomButton(
              label: "Entrar",
              onPressed: _signIn,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Container(
                height: 40,
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

  // Campo personalizado para matrícula
  Widget _buildMatriculaField() {
    return TextField(
      controller: _loginController,
      keyboardType: TextInputType.number,
      maxLength: 7,
      decoration: InputDecoration(
        hintText: 'Código de operador',
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: Icon(Icons.badge),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      isLoading = true;
    });

    String login = _loginController.text;
    String password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Preencha todos os campos");
      return;
    }

    try {
      User? user;

      if (_loginWithMatricula) {
        // Login com matrícula
        user = await _auth.signInWithMatricula(login, password);
      } else {
        // Login com e-mail
        user = await _auth.signInWithEmailAndPassword(login, password);
      }

      // Verifica se o widget ainda está montado
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        print("Usuário conectado com sucesso");

        // Verificar o tipo de usuário e direcionar
        if (_auth.isAdmin()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Nav()),
            //MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            //MaterialPageRoute(builder: (context) => Nav()),
            MaterialPageRoute(builder: (context) => HomePage())
          );
        }
      } else {
        // Mostra erro em um diálogo
        _showErrorDialog(_loginWithMatricula
            ? "Matrícula ou senha incorreta"
            : "E-mail ou senha incorreta");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Erro ao fazer login: $e");
    }
  }

  void _showErrorDialog(String message) {
    // Simplificar a mensagem de erro
    String simplifiedMessage = message;
    if (message.contains("Erro ao fazer login:")) {
      simplifiedMessage = "Falha ao processar o login. Verifique suas informações e tente novamente.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Erro",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                simplifiedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFF4200),
                  minimumSize: Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }
}