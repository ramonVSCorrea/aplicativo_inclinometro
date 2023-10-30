import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/repositories/user_repository.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserRepository.instance.getUser(widget.userId);
    if (user != null) {
      setState(() {
        _usernameController.text = user['username'];
        _emailController.text = user['email'];
      });
    }
  }

  Future<void> _updateProfile() async {
    final userData = {
      'id': widget.userId,
      'username': _usernameController.text,
      'email': _emailController.text,
    };

    await UserRepository.instance.updateUser(userData);

    Navigator.pop(context);
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
            EmailField(controller: _emailController),
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
