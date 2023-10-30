import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/repositories/user_repository.dart';

// CRIADA COM FINS DE VERIFICAR OS USUARIOS
class AllUsersPage extends StatefulWidget {
  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  List<Map<String, dynamic>> allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    final users = await UserRepository.instance.getAllUsers();
    setState(() {
      allUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos os Usuários'),
      ),
      body: ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final user = allUsers[index];
          return ListTile(
            title: Text('${user['username']}, ${user['lastname']}'),
            subtitle: Text(
                'ID: ${user['id']}, Email: ${user['email']}, Password: ${user['password']}, Data de Criação: ${user['created_at']}'),
          );
        },
      ),
    );
  }
}
