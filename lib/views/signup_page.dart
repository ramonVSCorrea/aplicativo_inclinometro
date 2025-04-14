import 'package:aplicativo_inclinometro/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/terms_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  final FirebaseAuthService _auth = FirebaseAuthService();

  bool acceptedTerms = false;

  bool isLoading = false;

  @override
  void dispose(){
    _nameController.dispose;
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          top: 40,
          left: 40,
          right: 40,
        ),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 118,
              height: 118,
              child: Image.asset('assets/inclimaxLogo.png'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Registro",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "Primeiro nome",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            NameField(
              controller: _nameController,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Último nome",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            NameField(
              controller: _lastnameController,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "E-mail",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            EmailField(controller: _emailController),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Empresa",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(
                hintText: 'Nome da empresa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                prefixIcon: Icon(Icons.business),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            const Text(
              "Senha",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFFF4200),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            PasswordField(controller: _passwordController),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TermsDialog();
                  },
                );
              },
              child: Text(
                "Termos de Uso",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFFFF4200),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      acceptedTerms = value!;
                    });
                  },
                ),
                Text(
                  "Aceito os Termos de Uso",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Color(0xFFFF4200),
                  ),
                ),
              ],
            ),

            isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
                : CustomButton(
              label: "Continue",
              onPressed: () async {
                if (!acceptedTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Aceite os termos de uso')),
                  );
                  return;
                }
                _signUp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isLoading = true;
    });

    String username = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String company = _companyController.text;

    try {
      User? user = await _auth.signUpWithEmailAndPassword(
          email,
          password,
          username,
          company
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        _showSuccessDialog("Usuário cadastrado com sucesso!");
      } else {
        _showErrorDialog(errorSignUp ?? "Erro ao cadastrar");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Erro no cadastro: $e");
    }
  }

  void _showErrorDialog(String message) {
    // Simplificar a mensagem de erro
    String simplifiedMessage = message;
    if (message.contains("Erro no cadastro:")) {
      simplifiedMessage = "Falha ao processar o cadastro. Verifique suas informações e tente novamente.";
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sucesso"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Ir para login"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}
