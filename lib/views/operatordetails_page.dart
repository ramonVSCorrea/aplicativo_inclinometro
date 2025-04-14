import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OperatorDetailsPage extends StatefulWidget {
  final String operatorId;

  OperatorDetailsPage({required this.operatorId});

  @override
  _OperatorDetailsPageState createState() => _OperatorDetailsPageState();
}

class _OperatorDetailsPageState extends State<OperatorDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> operatorData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOperatorData();
  }

  Future<void> _loadOperatorData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(widget.operatorId)
          .get();

      if (doc.exists) {
        setState(() {
          operatorData = doc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operador não encontrado')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado para a área de transferência')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Operador"),
        backgroundColor: Color(0xFFA59AFF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFA59AFF),
                child: Text(
                  _getInitials(),
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              "Informações Básicas",
              [
                _buildDetailItem("Nome", operatorData['userName'] ?? operatorData['username'] ?? "Sem nome"),
                _buildDetailItem("Email", operatorData['email'] ?? "Sem email"),
                _buildDetailItem("Matrícula", operatorData['operatorId'] ?? operatorData['matricula'] ?? "Não definida"),
                _buildDetailItem("Empresa", operatorData['company'] ?? "Não definida"),
              ],
            ),
            SizedBox(height: 16),
            if (operatorData.containsKey('sensorId') || operatorData.containsKey('sensoresIDs'))
              _buildInfoCard(
                "Sensores Associados",
                [
                  _buildListItem(
                      "IDs dos Sensores",
                      _getSensorList()
                  ),
                ],
              ),
            SizedBox(height: 16),
            _buildTimestampCard(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showResetPasswordConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text("Redefinir senha do operador"),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSensorList() {
    if (operatorData.containsKey('sensoresIDs') && operatorData['sensoresIDs'] is List) {
      return (operatorData['sensoresIDs'] as List).map((e) => e.toString()).toList();
    } else if (operatorData.containsKey('sensorId') && operatorData['sensorId'] is List) {
      return (operatorData['sensorId'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  String _getInitials() {
    String name = operatorData['userName'] ?? operatorData['username'] ?? "";
    if (name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Row(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 20),
                onPressed: () => _copyToClipboard(value, label),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String label, List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          items.isEmpty
              ? Text("Nenhum sensor associado")
              : Column(
            children: items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item),
                  IconButton(
                    icon: Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(item, "ID do Sensor"),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampCard() {
    Timestamp? timestamp = operatorData['createdAt'] as Timestamp?;
    String createdDate = timestamp != null
        ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
        : "Data não disponível";

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Criado em",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  createdDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (operatorData.containsKey('createdBy'))
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Criado por",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Admin (${operatorData['createdBy'].toString().substring(0, 6)}...)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Redefinir senha"),
          content: Text("Deseja enviar um e-mail para redefinição de senha ao operador?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Enviar"),
              onPressed: () {
                Navigator.of(context).pop();
                _sendPasswordResetEmail();
              },
            ),
          ],
        );
      },
    );
  }

  void _sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: operatorData['email'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail de redefinição enviado para ${operatorData['email']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar e-mail: $e')),
      );
    }
  }
}