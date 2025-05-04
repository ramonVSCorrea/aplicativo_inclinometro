import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';
import 'package:aplicativo_inclinometro/views/dashboards_page.dart';
import 'package:aplicativo_inclinometro/views/calibratesensor.dart';
import 'package:aplicativo_inclinometro/views/lockangle_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/userprofile_page.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  String userType = 'operator'; // valor padrão

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
            userType = userData['userType'] ?? 'operator';
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
            // Status da conexão
            if (connected != null)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: connected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        connected
                            ? "Sensor Conectado"
                            : "Sensor Desconectado",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    String userName = userData['userName'] ?? userData['username'] ?? user?.displayName ?? "Usuário";
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
        // Meu Perfil (comum para todos os tipos)
        _buildMenuItem(
          context: context,
          icon: Icons.person,
          title: 'Meu Perfil',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()),
            );
          },
        ),

        // Itens específicos para administrador
        if (userType == 'admin') ...[
          _buildMenuItem(
            context: context,
            icon: Icons.dashboard,
            title: 'Dashboards',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardsPage()),
              );
            },
          ),
        ],

        // Conectar Sensor (comum para todos os tipos)
        _buildMenuItem(
          context: context,
          icon: Icons.bluetooth,
          title: 'Conectar Sensor',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConnectPage()),
            );
          },
        ),

        // Home (somente para operadores)
        if (userType == 'operator') ...[
          _buildMenuItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],

        // Itens adicionais para administrador
        if (userType == 'admin') ...[
          _buildMenuItem(
            context: context,
            icon: Icons.lock,
            title: 'Ângulos de Bloqueio',
            onTap: () {
              Navigator.pop(context);
              if (connected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LockAnglePage()),
                );
              } else {
                _showConnectDeviceDialog(context);
              }
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.adjust,
            title: 'Calibrar Sensor',
            onTap: () {
              Navigator.pop(context);
              if (connected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalibrateSensorPage()),
                );
              } else {
                _showConnectDeviceDialog(context);
              }
            },
          ),
        ],
      ],
    );
  }

  // Dialog para mostrar quando não há dispositivo conectado
  void _showConnectDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Dispositivo não conectado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFF0055AA),
            ),
          ),
          content: Text(
            'É necessário conectar um sensor antes de acessar esta função.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF4200),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Conectar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          titlePadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          backgroundColor: Colors.white,
          elevation: 10,
        );
      },
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    "Sair",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.red[700],
                    ),
                  ),
                  content: Text(
                    "Deseja realmente sair do aplicativo?",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Sair",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  titlePadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  backgroundColor: Colors.white,
                  elevation: 10,
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
  }}