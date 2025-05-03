import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

User? user = FirebaseAuth.instance.currentUser;

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              accountName: Text('${user?.displayName}'),
              accountEmail: Text('${user?.email}'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(child: Image.asset('assets/profile1.png'))
              ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 43, 43, 43),
            ),
          ),
          ListTile(
            leading: Icon(Icons.adjust, color: Color(0xFFFF4200)),
            title: Text('Conectar Sensor'),
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => ConnectPage()));
              print('Tela Conectar Sensor');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFFFF4200)),
            title: Text('Logout'),
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
