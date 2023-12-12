import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  ForgetPasswordPage({super.key});

  void _resetPassword(BuildContext context) async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
    } catch(e){
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Redefinir Senha'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
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
            EmailField(controller: emailController),
            const SizedBox(
              height: 30,
            ),
            CustomButton(
              label: "Salvar Alterações",
              onPressed: () => _resetPassword(context),
            ),
          ],
        ),
      ),
    );
  }
}
