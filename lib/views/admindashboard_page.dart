import 'package:aplicativo_inclinometro/views/regiteroperator_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String adminName = "";
  String companyName = "";
  List<Map<String, dynamic>> operators = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadOperators();
  }

  Future<void> _loadAdminData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      setState(() {
        adminName = doc['username'] ?? "Admin";
        companyName = doc['company'] ?? "Empresa";
      });
    } catch (e) {
      print("Erro ao carregar dados do admin: $e");
    }
  }

  Future<void> _loadOperators() async {
    setState(() {
      isLoading = true;
    });

    try {
      String adminUid = _auth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('createdBy', isEqualTo: adminUid)
          .where('userType', isEqualTo: 'operator')
          .get();

      List<Map<String, dynamic>> tempList = [];
      querySnapshot.docs.forEach((doc) {
        tempList.add({
          'id': doc.id,
          'username': doc['username'] ?? "Sem nome",
          'email': doc['email'] ?? "Sem email",
          'createdAt': doc['createdAt'] ?? Timestamp.now(),
        });
      });

      setState(() {
        operators = tempList;
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar operadores: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Admin"),
        backgroundColor: Color(0xFFA59AFF),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bem-vindo, $adminName",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Empresa: $companyName",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Operadores Cadastrados",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Novo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA59AFF),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterOperatorPage()),
                    ).then((_) {
                      _loadOperators(); // Recarregar lista após retornar
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : operators.isEmpty
                  ? Center(child: Text("Nenhum operador cadastrado"))
                  : ListView.builder(
                itemCount: operators.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(operators[index]['username'][0]),
                        backgroundColor: Color(0xFFA59AFF),
                      ),
                      title: Text(operators[index]['username']),
                      subtitle: Text(operators[index]['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOperator(operators[index]['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Nav()),
                );
              },
              child: Text("Acessar Aplicativo", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteOperator(String operatorId) async {
    try {
      await _firestore.collection('users').doc(operatorId).delete();

      // Atualizar a lista após excluir
      _loadOperators();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operador removido com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover operador: $e')),
      );
    }
  }
}