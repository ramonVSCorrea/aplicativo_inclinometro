import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterOperatorPage extends StatefulWidget {
  @override
  _RegisterOperatorPageState createState() => _RegisterOperatorPageState();
}

class _RegisterOperatorPageState extends State<RegisterOperatorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Operador"),
        backgroundColor: Color(0xFFA59AFF),
      ),
      body: Container(
        padding: const EdgeInsets.all(40),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: <Widget>[
            const Text(
              "Cadastro de Operador",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Nome completo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(height: 10),
            NameField(controller: _nameController),
            const SizedBox(height: 20),
            const Text(
              "E-mail",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(height: 10),
            EmailField(controller: _emailController),
            const SizedBox(height: 20),
            const Text(
              "Senha",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(height: 10),
            PasswordField(controller: _passwordController),
            const SizedBox(height: 30),
            isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFA59AFF)))
                : CustomButton(
              label: "Cadastrar Operador",
              onPressed: _registerOperator,
            ),
            // CustomButton(
            //   label: "Cadastrar Operador",
            //   onPressed: _registerOperator,
            // ),
          ],
        ),
      ),
    );
  }

  void _registerOperator() async {
    setState(() {
      isLoading = true;
    });

    String username = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Preencha todos os campos");
      return;
    }

    String adminUid = FirebaseAuth.instance.currentUser!.uid;
    try {
      bool success = await _auth.registerOperator(email, password, username, adminUid);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (success) {
        _showSuccessDialog("Operador cadastrado com sucesso");
        // Limpa os campos após o cadastro
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } else {
        _showErrorDialog(errorSignUp ?? "Erro ao cadastrar operador");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Erro ao cadastrar operador: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erro"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sucesso"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}