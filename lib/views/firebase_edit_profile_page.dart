import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/password_field.dart';


class FirebaseEditProfilePage extends StatefulWidget {
  @override
  State<FirebaseEditProfilePage> createState() =>
      _FirebaseEditProfilePageState();
}

class _FirebaseEditProfilePageState extends State<FirebaseEditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? nomeUsuario = user?.displayName;
    List<String>? partes = nomeUsuario?.split(" ");

    if(user != null){
      setState(() {
        _usernameController.text = partes![0];
        _lastnameController.text = partes![1];
      });
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    String _nomeUsuario = _usernameController.text + " " + _lastnameController.text;

    if (user != null) {
      try {
        if(_nomeUsuario.isNotEmpty){
          await user.updateDisplayName(_nomeUsuario);
        }
        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        print('Erro ao atualizar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
      ),

      body: Container(
        padding: const EdgeInsets.only(
          top: 60,
          left: 40,
          right: 40,
        ),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Nome de Usuário",
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
            NameField(
              controller: _usernameController,
            ),
            const SizedBox(
              height: 20,
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
            const SizedBox(
              height: 10,
            ),
            NameField(
              controller: _lastnameController,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Senha",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'P-posts',
                  color: Color(0xFFA59AFF),
                )),
            const SizedBox(
              height: 10,
            ),
            PasswordField(
              controller: _passwordController,
            ),
            // const SizedBox(
            //   height: 20,
            // ),
            // const Text(
            //   "E-mail",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.w900,
            //     fontFamily: 'Poppins',
            //     color: Color(0xFFA59AFF),
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // EmailField(controller: _emailController),
            const SizedBox(
              height: 30,
            ),
            CustomButton(
              label: "Salvar Alterações",
              onPressed: _updateProfile,
            ),
          ],
        ),
      ),
    );
  }
}
