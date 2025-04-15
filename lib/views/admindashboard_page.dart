import 'package:aplicativo_inclinometro/views/regiteroperator_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'operatordetails_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      if (companyName.isEmpty) {
        await _loadAdminData();
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('company', isEqualTo: companyName)
          .where('userType', isEqualTo: 'operator')
          .get();

      List<Map<String, dynamic>> tempList = [];
      for (var doc in querySnapshot.docs) {
        print("Operador encontrado: ${doc['userName']} da empresa $companyName");
        tempList.add({
          'id': doc.id,
          'username': doc['userName'] ?? doc['userName'] ?? "Sem nome",
          'email': doc['email'] ?? "Sem email",
          'createdAt': doc['createdAt'] ?? Timestamp.now(),
        });
      }

      setState(() {
        operators = tempList;
        isLoading = false;
      });
      print("Total de operadores encontrados: ${operators.length}");
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
                  return OperatorExpansionCard(
                    operator: operators[index],
                    onDelete: () => _deleteOperator(operators[index]['id']),
                    onDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OperatorDetailsPage(
                            operatorId: operators[index]['id'],
                          ),
                        ),
                      ).then((_) {
                        _loadOperators();
                      });
                    },
                    firestore: _firestore,
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


class OperatorExpansionCard extends StatefulWidget {
  final Map<String, dynamic> operator;
  final VoidCallback onDelete;
  final VoidCallback onDetails;
  final FirebaseFirestore firestore;

  OperatorExpansionCard({
    required this.operator,
    required this.onDelete,
    required this.onDetails,
    required this.firestore,
  });

  @override
  _OperatorExpansionCardState createState() => _OperatorExpansionCardState();
}

class _OperatorExpansionCardState extends State<OperatorExpansionCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _sensorsData = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(widget.operator['username'].isNotEmpty
                  ? widget.operator['username'][0]
                  : "?"),
              backgroundColor: Color(0xFFA59AFF),
            ),
            title: Text(widget.operator['username']),
            subtitle: Text(widget.operator['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Color(0xFFA59AFF),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded && _sensorsData.isEmpty) {
                        _loadSensorsData();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.blue),
                  tooltip: "Ver detalhes",
                  onPressed: widget.onDetails,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: "Excluir operador",
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded && _sensorsData.isEmpty) {
                  _loadSensorsData();
                }
              });
            },
          ),
          if (_isExpanded)
            _isLoading
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : _buildSensorsInfo(),
        ],
      ),
    );
  }

  Widget _buildSensorsInfo() {
    if (_sensorsData.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Nenhum sensor associado a este operador.",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: _sensorsData.map((sensorData) {
        return _buildSensorCard(sensorData);
      }).toList(),
    );
  }

  Widget _buildSensorCard(Map<String, dynamic> sensorData) {
    String sensorId = sensorData['id'] ?? "Desconhecido";
    double? anguloLateral = _getDoubleValue(sensorData['anguloLateral'] ?? sensorData['lateral_angle']);
    double? anguloFrontal = _getDoubleValue(sensorData['anguloFrontal'] ?? sensorData['frontal_angle']);
    double? latitude = _getDoubleValue(sensorData['latitude']);
    double? longitude = _getDoubleValue(sensorData['longitude']);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.grey[100],
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sensor ID: $sensorId",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Divider(),
              SizedBox(height: 8),
              _buildAngleRow("Ângulo Lateral", anguloLateral),
              SizedBox(height: 4),
              _buildAngleRow("Ângulo Frontal", anguloFrontal),
              SizedBox(height: 8),
              if (latitude != null && longitude != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Localização",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          // Fundo cinza claro
                          Container(color: Colors.grey[200]),
                          // Ícone de localização centralizado
                          Center(
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                          // Texto de marca d'água
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Text(
                              "Mapa",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        "Coordenadas: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.map, size: 16),
                        label: Text("Abrir no mapa"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFA59AFF),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 32),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _openMap(latitude, longitude),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  "Localização não disponível",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAngleRow(String title, double? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        value != null
            ? Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getAngleColor(value),
              ),
            ),
            SizedBox(width: 4),
            Text(
              "${value.toStringAsFixed(1)}°",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getAngleColor(value),
              ),
            ),
          ],
        )
            : Text(
          "N/A",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ],
    );
  }

  Color _getAngleColor(double angle) {
    double absAngle = angle.abs();
    if (absAngle < 5) return Colors.green;
    if (absAngle < 10) return Colors.yellow;
    if (absAngle < 15) return Colors.orange;
    return Colors.red;
  }

  Future<void> _loadSensorsData() async {
    setState(() {
      _isLoading = true;
    });

    // Aguardar um breve período para simular o carregamento
    await Future.delayed(Duration(milliseconds: 800));

    // Dados fictícios de sensores para demonstração
    List<Map<String, dynamic>> demoSensors = [
      {
        'id': 'SENSOR123',
        'anguloLateral': 3.2,
        'anguloFrontal': 1.5,
        'latitude': -23.550520,
        'longitude': -46.633308,
      },
      {
        'id': 'SENSOR456',
        'anguloLateral': 7.8,
        'anguloFrontal': 9.2,
        'latitude': -23.551234,
        'longitude': -46.642123,
      },
      {
        'id': 'SENSOR789',
        'anguloLateral': 14.5,
        'anguloFrontal': 18.3,
        'latitude': -23.548975,
        'longitude': -46.639856,
      },
    ];

    setState(() {
      _sensorsData = demoSensors;
      _isLoading = false;
    });
  }

  double? _getDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o mapa: $e')),
      );
    }
  }
}