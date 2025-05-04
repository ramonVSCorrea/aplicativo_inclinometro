import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/firebase_edit_profile_page.dart';

class AdminSideBar extends StatefulWidget {
  const AdminSideBar({super.key});

  @override
  _AdminSideBarState createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};
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
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMenuItems(context),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String userName = userData['userName'] ?? userData['username'] ?? user?.displayName ?? "Administrador";
    String company = userData['company'] ?? "Empresa não informada";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: Color(0xFF0055AA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/profile1.png',
                  fit: BoxFit.cover,
                  width: 76,
                  height: 76,
                ),
              ),
            ),
          ),
          Text(
            userName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              company,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Dashboard
        _buildMenuItem(
          context: context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            // Se já estiver no dashboard, não faça nada
            if (Navigator.canPop(context)) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
        ),

        // Meu Perfil
        _buildMenuItem(
          context: context,
          icon: Icons.person,
          title: 'Meu Perfil',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FirebaseEditProfilePage()),
            );
          },
        ),

        Divider(color: Colors.grey.withOpacity(0.2)),

        // Gerenciar Sensores
        _buildMenuItem(
          context: context,
          icon: Icons.sensors,
          title: 'Gerenciar Sensores',
          onTap: () {
            Navigator.pop(context);
            // Navegue para a página de gerenciamento de sensores
          },
        ),

        // Configurações
        _buildMenuItem(
          context: context,
          icon: Icons.settings,
          title: 'Configurações',
          onTap: () {
            Navigator.pop(context);
            // Navegue para as configurações
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFF4200).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFFFF4200),
                  size: 22,
                ),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Sair"),
                  content: Text("Deseja realmente sair do aplicativo?"),
                  actions: [
                    TextButton(
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(
                        "Sair",
                        style: TextStyle(color: Color(0xFFFF4200)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}