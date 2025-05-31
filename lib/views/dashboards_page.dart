import 'package:aplicativo_inclinometro/components/adminsidebar.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/sideBar.dart';
import 'allevents_page.dart';

class DashboardsPage extends StatefulWidget {
  @override
  _DashboardsPageState createState() => _DashboardsPageState();
}

class _DashboardsPageState extends State<DashboardsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = "";
  String companyName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            userName = userData['username'] ?? userData['userName'] ?? "Usuário";
            companyName = userData['company'] ?? "Empresa não informada";
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SideBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra superior com título centralizado
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFFFF4200), size: 28),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Dashboards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Espaço vazio para equilibrar o layout
                  SizedBox(width: 48),
                ],
              ),
            ),

            // Conteúdo principal (sem o card de bem-vindo)
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
                  : Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboards Disponíveis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),

                    Expanded(
                      child: ListView(
                        children: [
                          _buildDashboardCard(
                              "Monitoramento em Tempo Real",
                              Icons.assessment,
                              "Visualize dados dos sensores em tempo real com gráficos e alertas automatizados",
                              onTap: () {
                                // Navegação para a tela de monitoramento em tempo real (se existir)
                              }
                          ),
                          _buildDashboardCard(
                              "Histórico de Dados",
                              Icons.history,
                              "Acesse o histórico completo de dados capturados pelos sensores",
                              onTap: () {
                                // Navegar para a tela AllEventsPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllEventsPage(),
                                  ),
                                );
                              }
                          ),
                          _buildDashboardCard(
                              "Relatórios Analíticos",
                              Icons.insert_chart,
                              "Relatórios detalhados com análises de tendências e estatísticas dos sensores",
                              onTap: () {
                                // Navegação para a tela de relatórios analíticos (se existir)
                              }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, String description, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF4200).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: Color(0xFFFF4200),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFFFF4200),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFF4200).withOpacity(0.1)),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
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