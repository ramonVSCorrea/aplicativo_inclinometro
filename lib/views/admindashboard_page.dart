import 'dart:async';

import 'package:aplicativo_inclinometro/components/adminsidebar.dart';
import 'package:aplicativo_inclinometro/views/regiteroperator_page.dart';
import 'package:aplicativo_inclinometro/views/sensorevents_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/sideBar.dart';
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
  List<Map<String, dynamic>> filteredOperators = []; // Nova lista para resultados filtrados
  bool isLoading = true;
  TextEditingController searchController = TextEditingController(); // Controlador para campo de busca

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadOperators();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Método para filtrar operadores baseado no texto de busca
  void _filterOperators(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOperators = List.from(operators);
      } else {
        query = query.toLowerCase();
        filteredOperators = operators.where((operator) {
          // Busca por nome
          final username = operator['username'].toString().toLowerCase();
          if (username.contains(query)) return true;

          // Busca por matrícula
          final matricula = operator['matricula']?.toString().toLowerCase() ?? '';
          if (matricula.contains(query)) return true;

          // Busca por ID de sensor associado
          final sensorIds = operator['sensorIds'] ?? [];
          if (sensorIds is List) {
            for (var sensorId in sensorIds) {
              if (sensorId.toString().toLowerCase().contains(query)) {
                return true;
              }
            }
          }

          return false;
        }).toList();
      }
    });
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

        // Obter sensores associados ao operador
        List<String> sensorIds = [];
        if (doc.data().toString().contains('sensorId') && doc['sensorId'] is List) {
          sensorIds = List<String>.from(doc['sensorId']);
        } else if (doc.data().toString().contains('sensoresIDs') && doc['sensoresIDs'] is List) {
          sensorIds = List<String>.from(doc['sensoresIDs']);
        }

        tempList.add({
          'id': doc.id,
          'username': doc['userName'] ?? doc['userName'] ?? "Sem nome",
          'email': doc['email'] ?? "Sem email",
          'createdAt': doc['createdAt'] ?? Timestamp.now(),
          'operatorId': doc['operatorId'] ?? "",
          'sensorIds': sensorIds,
        });
      }

      setState(() {
        operators = tempList;
        filteredOperators = tempList; // Inicializa a lista filtrada com todos os operadores
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
      backgroundColor: Colors.white,
      drawer: SideBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra superior personalizada (mantida como está)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'assets/inclimax-logo-lateral.png',
                        height: 35,
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal com cards redesenhados
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de boas-vindas com novo estilo
                    Container(
                      margin: EdgeInsets.only(bottom: 16.0),
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
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
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
                                    Icons.person,
                                    color: Color(0xFFFF4200),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bem-vindo, $adminName",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      "Empresa: $companyName",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Título e botão de novo operador
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Operadores Cadastrados",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text("Novo",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF4200),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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

                    SizedBox(height: 8),

                    // Barra de pesquisa
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child:
                      TextField(
                        controller: searchController,
                        onChanged: _filterOperators,
                        cursorColor: Color(0xFFFF4200), // Cor do cursor
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Buscar por nome, matrícula ou ID sensor",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: 'Poppins',
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFFFF4200),
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              _filterOperators('');
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                      )
                    ),

                    // Lista de operadores
                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
                          : filteredOperators.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              searchController.text.isEmpty
                                  ? "Nenhum operador cadastrado"
                                  : "Nenhum resultado encontrado",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        itemCount: filteredOperators.length,
                        itemBuilder: (context, index) {
                          return OperatorExpansionCard(
                            operator: filteredOperators[index],
                            onDelete: () => _deleteOperator(filteredOperators[index]['id']),
                            onDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OperatorDetailsPage(
                                    operatorId: filteredOperators[index]['id'],
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
    return Container(
      margin: EdgeInsets.only(bottom: 10),
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
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Color(0xFFFF4200).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Color(0xFFFF4200),
                child: Text(
                  widget.operator['username'].isNotEmpty
                      ? widget.operator['username'][0]
                      : "?",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              widget.operator['username'],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.operator['email'],
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
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
                  icon: Icon(
                      Icons.info_outline,
                      color: Color(0xFF0055AA)
                  ),
                  tooltip: "Ver detalhes",
                  onPressed: widget.onDetails,
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
              child: Center(child: CircularProgressIndicator(color: Color(0xFFFF4200))),
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
          style: TextStyle(fontStyle: FontStyle.italic, fontFamily: 'Poppins'),
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSensorAvailable ? Colors.grey.shade200 : Colors.red.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF4200).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sensors,
                        color: Color(0xFFFF4200),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Sensor ID: $sensorId",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
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
                        fontFamily: 'Poppins',
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
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Sem comunicação há mais de 10 minutos",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.event_note, size: 16, color: Colors.white),
                        label: Text(
                          "Ver Eventos",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF4200),
                          minimumSize: Size(double.infinity, 36),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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

                  if (latitude != null && longitude != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Localização",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4),
                        InkWell(
                          onTap: () => _openMap(latitude, longitude),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFFF4200).withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[50],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.location_on,
                                    size: 40,
                                    color: Color(0xFFFF4200),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons.open_in_new,
                                          size: 14,
                                          color: Color(0xFFFF4200)
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Abrir Mapa",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.event_note, size: 16, color: Colors.white),
                              label: Text(
                                "Ver Eventos",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF4200),
                                minimumSize: Size(double.infinity, 36),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.event_note, size: 16, color: Colors.white),
                              label: Text(
                                "Ver Eventos",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF4200),
                                minimumSize: Size(double.infinity, 36),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                ],
              ),
          ],
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

  Widget _buildAngleRow(String title, double? value) {
    Color angleColor = value != null ? _getAngleColor(value) : Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: value != null ? angleColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          value != null
              ? Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: angleColor,
                ),
              ),
              SizedBox(width: 4),
              Text(
                "${value.toStringAsFixed(1)}°",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: angleColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          )
              : Text(
            "N/A",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
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