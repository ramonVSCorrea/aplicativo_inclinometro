import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicativo_inclinometro/components/sideBar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  Map<String, dynamic> userData = {};

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
      User? currentUser = _auth.currentUser;
      print("Current user: ${currentUser?.uid}");

      if (currentUser != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
        print("User data: ${doc.data()}");

        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do perfil'))
      );
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
            // Barra superior personalizada
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
                  // Título centralizado
                  Expanded(
                    child: Text(
                      'Meu Perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFFFF4200),
                      ),
                    ),
                  ),
                  // Botão de atualização
                  IconButton(
                    icon: Icon(Icons.refresh, color: Color(0xFFFF4200), size: 24),
                    onPressed: _loadUserData,
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
                  : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar do usuário
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 24),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF0055AA), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/profile1.png',
                            fit: BoxFit.cover,
                            width: 116,
                            height: 116,
                          ),
                        ),
                      ),
                    ),

                    // Informações do usuário
                    _buildProfileCard(),

                    SizedBox(height: 16),

                    // Informações da empresa
                    _buildCompanyCard(),

                    SizedBox(height: 16),

                    // Informações adicionais
                    _buildAdditionalInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Color(0xFF0055AA)),
                SizedBox(width: 8),
                Text(
                  'Informações Pessoais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Divider(),
            _buildInfoItem('Nome', userData['userName'] ?? 'Não informado'),
            _buildInfoItem('E-mail', userData['email'] ?? _auth.currentUser?.email ?? 'Não informado'),
            _buildInfoItem('Tipo de Usuário', _formatUserType(userData['userType'])),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Color(0xFF0055AA)),
                SizedBox(width: 8),
                Text(
                  'Empresa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Divider(),
            _buildInfoItem('Empresa', userData['company'] ?? 'Não informado'),
            if (userData.containsKey('createdAt') && userData['createdAt'] != null)
              _buildInfoItem('Cadastrado em', _formatTimestamp(userData['createdAt'])),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    // Sensores associados ao usuário, se houver
    List<dynamic> sensorIds = [];
    if (userData.containsKey('sensorId') && userData['sensorId'] is List) {
      sensorIds = userData['sensorId'];
    } else if (userData.containsKey('sensoresIDs') && userData['sensoresIDs'] is List) {
      sensorIds = userData['sensoresIDs'];
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Color(0xFF0055AA)),
                SizedBox(width: 8),
                Text(
                  'Sensores Associados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Divider(),
            sensorIds.isEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhum sensor associado a este usuário.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            )
                : Column(
              children: sensorIds.map((sensorId) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF4200).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFFFF4200).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bluetooth_connected,
                        color: Color(0xFFFF4200),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sensorId.toString(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ":",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUserType(String? userType) {
    if (userType == null) return 'Não definido';

    switch (userType.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'operator':
        return 'Operador';
      default:
        return userType;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        DateTime dateTime = timestamp.toDate();
        return '${dateTime.day.toString().padLeft(2, '0')}/'
            '${dateTime.month.toString().padLeft(2, '0')}/'
            '${dateTime.year} às '
            '${dateTime.hour.toString().padLeft(2, '0')}:'
            '${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return 'Data inválida';
      }
    } catch (e) {
      return 'Data inválida';
    }
  }
}