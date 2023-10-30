import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/database/db.dart';
import 'package:aplicativo_inclinometro/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';

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
              "Registro",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
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
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
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
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
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
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            EmailField(controller: _emailController),
            const SizedBox(
              height: 10,
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
            PasswordField(controller: _passwordController),
            const SizedBox(
              height: 10,
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
                const Text(
                  "Aceito os Termos de Uso",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Color(0xFFA59AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
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

                  print('Dados do usuário:');
                  print('Username: ${_nameController.text}');
                  print('Lastname: ${_lastnameController.text}');
                  print('Email: $email');
                  print('Password: ${_passwordController.text}');

                  Map<String, dynamic> userData = {
                    'username': _nameController.text,
                    'lastname': _lastnameController.text,
                    'email': email,
                    'password': _passwordController.text,
                  };

                  UserRepository.instance.insertUser(userData);

                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Nav()));
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
