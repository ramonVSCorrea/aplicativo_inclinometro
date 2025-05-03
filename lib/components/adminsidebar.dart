import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/edit_profile_page.dart';
import '../views/firebase_edit_profile_page.dart';

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  _AdminSideBarState createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  User? user = FirebaseAuth.instance.currentUser;
  String userName = '';
  String companyName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            userName = userData['name'] ?? 'Administrador';
            companyName = userData['company'] ?? 'Empresa não definida';
            isLoading = false;
          });
        } else {
          setState(() {
            userName = user?.displayName ?? 'Administrador';
            companyName = 'Empresa não definida';
            isLoading = false;
          });
        }
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
        setState(() {
          userName = user?.displayName ?? 'Administrador';
          companyName = 'Empresa não definida';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(isLoading ? 'Carregando...' : userName),
            accountEmail: Text(isLoading ? 'Carregando...' : companyName),
            currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(child: Image.asset('assets/profile1.png'))
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0055AA)
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Color(0xFFFF4200)),
            title: Text('Editar Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirebaseEditProfilePage())
                  //MaterialPageRoute(builder: (context) => ProfilePage(userId: userId))
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFFFF4200)),
            title: Text('Logout'),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao fazer logout: $e'))
                );
              }
            },
          ),
        ],
      ),
    );
  }
}