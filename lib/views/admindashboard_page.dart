import 'dart:async';

import 'package:aplicativo_inclinometro/components/adminsidebar.dart';
import 'package:aplicativo_inclinometro/views/regiteroperator_page.dart';
import 'package:aplicativo_inclinometro/views/sensorevents_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/http/tago/FetchTagoIOData.dart';
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

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadOperators();
  }

  Future<void> _loadAdminData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

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

      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .where('company', isEqualTo: companyName)
              .where('userType', isEqualTo: 'operator')
              .get();

      List<Map<String, dynamic>> tempList = [];
      for (var doc in querySnapshot.docs) {
        print(
          "Operador encontrado: ${doc['userName']} da empresa $companyName",
        );
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
      drawer: AdminSideBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra superior personalizada com altura reduzida
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão do drawer
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFFFF4200), size: 28),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  // Logo do aplicativo (com tamanho controlado)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/inclimax-logo-lateral.png',
                        height: 35, // Reduzida a altura
                        width: 120, // Limitando a largura
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal - removidos espaços extras
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0), // Reduzido o padding superior
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16.0), // Margem inferior ajustada
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
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Reduzido o espaço entre o card e a seção de operadores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Operadores Cadastrados",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text("Novo", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF4200),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterOperatorPage(),
                              ),
                            ).then((_) {
                              _loadOperators();
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Espaço reduzido
                    Expanded(
                      child:
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : operators.isEmpty
                          ? Center(child: Text("Nenhum operador cadastrado"))
                          : ListView.builder(
                        itemCount: operators.length,
                        itemBuilder: (context, index) {
                          return OperatorExpansionCard(
                            operator: operators[index],
                            onDelete:
                                () => _deleteOperator(operators[index]['id']),
                            onDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OperatorDetailsPage(
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
                  ],
                ),
              ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Operador removido com sucesso')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao remover operador: $e')));
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
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
  }

  void _startPeriodicUpdates() {
    // Atualiza os dados a cada 30 segundos
    _updateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isExpanded) {
        _loadSensorsData();
      } else {
        _updateTimer?.cancel();
        _updateTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(
                widget.operator['username'].isNotEmpty
                    ? widget.operator['username'][0]
                    : "?",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF0055AA),
            ),
            title: Text(widget.operator['username']),
            subtitle: Text(widget.operator['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color(0xFFFF4200),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded) {
                        _loadSensorsData();
                        _startPeriodicUpdates();
                      } else {
                        _updateTimer?.cancel();
                        _updateTimer = null;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.blue),
                  tooltip: "Ver detalhes",
                  onPressed: widget.onDetails,
                ),
                // IconButton(
                //   icon: Icon(Icons.delete, color: Colors.red),
                //   tooltip: "Excluir operador",
                //   onPressed: widget.onDelete,
                // ),
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
      children:
          _sensorsData.map((sensorData) {
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

    // Verificar disponibilidade do sensor (10 minutos)
    bool isSensorAvailable = true;
    String statusText = "";

    if (sensorData.containsKey('lastUpdate') && sensorData['lastUpdate'] != null) {
      try {
        DateTime lastUpdate = DateTime.parse(sensorData['lastUpdate']);
        DateTime now = DateTime.now();
        Duration difference = now.difference(lastUpdate);

        if (difference.inMinutes > 10) {
          isSensorAvailable = false;
          statusText = "Sensor Indisponível";
        } else {
          statusText = "Última atualização: ${_formatTimeDifference(difference)}";
        }
      } catch (e) {
        print("Erro ao analisar data de atualização: $e");
        isSensorAvailable = false;
        statusText = "Data inválida";
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: isSensorAvailable ? Colors.grey[100] : Colors.grey[200],
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sensor ID: $sensorId",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (!isSensorAvailable)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        "Indisponível",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Divider(),

              if (!isSensorAvailable)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                            SizedBox(height: 8),
                            Text(
                              "Sensor Indisponível",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Sem comunicação há mais de 10 minutos",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botão para ver eventos (sempre visível)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child:
                      ElevatedButton.icon(
                        icon: Icon(Icons.event_note, size: 16, color: Colors.white),
                        label: Text("Ver Eventos", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF4200),
                          minimumSize: Size(double.infinity, 36),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _navigateToEventsScreen(sensorId),
                      )
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    _buildAngleRow("Ângulo Lateral", anguloLateral),
                    SizedBox(height: 4),
                    _buildAngleRow("Ângulo Frontal", anguloFrontal),
                    SizedBox(height: 8),

// Substituir todo o bloco da exibição de localização
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
                          // Widget clicável com efeito de toque
                          InkWell(
                            onTap: () => _openMap(latitude, longitude),
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF0055AA)),
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
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons.open_in_new,
                                            size: 14,
                                            color: Color(0xFF0055AA)),
                                        SizedBox(width: 4),
                                        Text(
                                          "Abrir Mapa",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "Coordenadas: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                          // Botão para ver eventos (agora é o único botão)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                            child:
                            ElevatedButton.icon(
                              icon: Icon(Icons.event_note, size: 16, color: Colors.white),
                              label: Text("Ver Eventos", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF4200),
                                minimumSize: Size(double.infinity, 36),
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () => _navigateToEventsScreen(sensorId),
                            )
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Localização não disponível",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Botão para ver eventos (quando não tem localização)
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child:
                            ElevatedButton.icon(
                              icon: Icon(Icons.event_note, size: 16, color: Colors.white),
                              label: Text("Ver Eventos", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF4200),
                                minimumSize: Size(double.infinity, 36),
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () => _navigateToEventsScreen(sensorId),
                            )
                          ),
                        ],
                      ),

                    if (isSensorAvailable && sensorData.containsKey('lastUpdate'))
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEventsScreen(String sensorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SensorEventsPage(sensorId: sensorId),
      ),
    );
  }

  String _formatTimeDifference(Duration difference) {
    if (difference.inMinutes < 1) {
      return "Agora mesmo";
    } else if (difference.inMinutes == 1) {
      return "1 minuto atrás";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutos atrás";
    } else if (difference.inHours == 1) {
      return "1 hora atrás";
    } else {
      return "${difference.inHours} horas atrás";
    }
  }

  String _formatLastUpdate(String? dateTimeStr) {
    if (dateTimeStr == null) return "Desconhecida";
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Formato inválido";
    }
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot operatorDoc =
          await widget.firestore
              .collection('users')
              .doc(widget.operator['id'])
              .get();

      if (!operatorDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> operatorData =
          operatorDoc.data() as Map<String, dynamic>;
      List<String> sensorIds = [];

      if (operatorData.containsKey('sensorId') &&
          operatorData['sensorId'] is List) {
        sensorIds = List<String>.from(operatorData['sensorId']);
      } else if (operatorData.containsKey('sensoresIDs') &&
          operatorData['sensoresIDs'] is List) {
        sensorIds = List<String>.from(operatorData['sensoresIDs']);
      }

      if (sensorIds.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> sensorsData = [];

      final tagoService = TagoIOService();

      for (String sensorId in sensorIds) {
        Map<String, dynamic> sensorData = await tagoService.fetchTagoIOData(sensorId);
        if (sensorData.isNotEmpty) {
          sensorData['id'] = sensorId;
          sensorsData.add(sensorData);
        }
      }

      setState(() {
        _sensorsData = sensorsData;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar dados dos sensores: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o mapa: $e')),
      );
    }
  }
}
