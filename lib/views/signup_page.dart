import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/database/db.dart';
import 'package:aplicativo_inclinometro/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/terms_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool acceptedTerms = false;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
                color: Color(0xFFA59AFF),
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
                color: Color(0xFFA59AFF),
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
                color: Color(0xFFA59AFF),
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
              "Senha",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
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
                  color: Color(0xFFA59AFF),
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
                    color: Color(0xFFA59AFF),
                  ),
                ),
              ],
            ),
            CustomButton(
              label: "Continue",
              onPressed: () async {
                if (!acceptedTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Aceite os termos de uso')),
                  );
                  return;
                }

                final email = _emailController.text;
                final isRegistered =
                    await UserRepository.instance.isEmailRegistered(email);

                if (isRegistered) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Este email já está registrado')),
                  );
                } else {
                  await DB.instance.database;

                  Map<String, dynamic> userData = {
                    'username': _nameController.text,
                    'lastname': _lastnameController.text,
                    'email': email,
                    'password': hashPassword(_passwordController.text),
                  };

                  final createdUserId =
                      await UserRepository.instance.insertUser(userData);

                  if (createdUserId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Conta criada com sucesso')),
                    );

                    final pref = await SharedPreferences.getInstance();
                    pref.setInt('userId', createdUserId);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Nav(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar conta')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
