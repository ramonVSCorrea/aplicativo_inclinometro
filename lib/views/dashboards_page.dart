import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            userName = userData['name'] ?? userData['username'] ?? "Usuário";
            companyName = userData['company'] ?? "Empresa não definida";
            isLoading = false;
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
      appBar: AppBar(
        title: Text("Dashboards"),
        backgroundColor: Color(0xFFA59AFF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de boas-vindas
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bem-vindo, $userName",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      companyName,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Título seção
            Text(
              "Visão Geral",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),

            SizedBox(height: 16),

            // Aqui você pode adicionar seus widgets de dashboard
            // Por enquanto, vou adicionar alguns cards vazios
            _buildDashboardPlaceholder(
                "Resumo de Sensores",
                Icons.sensors,
                "Aqui serão exibidas informações sobre os sensores"
            ),

            SizedBox(height: 16),

            _buildDashboardPlaceholder(
                "Eventos Recentes",
                Icons.event_note,
                "Aqui serão exibidos os eventos recentes"
            ),

            SizedBox(height: 16),

            _buildDashboardPlaceholder(
                "Estatísticas",
                Icons.bar_chart,
                "Aqui serão exibidas estatísticas de uso"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPlaceholder(String title, IconData icon, String description) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFA59AFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFFA59AFF),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard_customize,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
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
}