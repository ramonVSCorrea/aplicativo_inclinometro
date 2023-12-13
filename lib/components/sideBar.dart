import 'package:aplicativo_inclinometro/views/firebase_edit_profile_page.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplicativo_inclinometro/views/edit_profile_page.dart';

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
            leading: Icon(Icons.person, color: Color(0xFFF07300)),
            title: Text('Editar Perfil'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FirebaseEditProfilePage()));
              print("Tela editar perfil");
            },
          ),

          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Configurações'),
          //   onTap: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => SettingsPage()));
          //   },
          // ),

          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFFF07300)),
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
