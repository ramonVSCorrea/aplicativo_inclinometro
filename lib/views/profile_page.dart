import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/repositories/user_repository.dart';
import 'package:aplicativo_inclinometro/views/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    //_loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserRepository.instance.getUser(widget.userId);
    if (user != null) {
      setState(() {
        userData = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pushReplacement(
        //         context, MaterialPageRoute(builder: (context) => Nav()));
        //   },
        // ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userData['username'] ?? 'Usuário'),
              accountEmail: Text(userData['email'] ?? 'email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/profile1.png'),
              ),
              decoration: BoxDecoration(color: const Color(0xFFF07300)),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(userId: widget.userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/profile1.png'),
                radius: 75,
              ),
              SizedBox(height: 20),
              Text(
                userData['username'] ?? 'Usuário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF07300),
                ),
              ),
              SizedBox(height: 10),
              Text(
                userData['email'] ?? 'email@example.com',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
