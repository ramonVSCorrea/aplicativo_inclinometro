import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorDetailsPage extends StatefulWidget {
  final String operatorId;

  const OperatorDetailsPage({
    Key? key,
    required this.operatorId
  }) : super(key: key);

  @override
  _OperatorDetailsPageState createState() => _OperatorDetailsPageState();
}

class _OperatorDetailsPageState extends State<OperatorDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  Map<String, dynamic> operatorData = {};
  bool isEditingEnabled = false;

  // Controladores para os campos de texto
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController sensorController = TextEditingController();

  // Lista para armazenar os sensores
  List<dynamic> sensorIds = [];

  @override
  void initState() {
    super.initState();
    _loadOperatorData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    sensorController.dispose();
    super.dispose();
  }

  // No _OperatorDetailsPageState, adicione uma variável para controlar o status
  String operatorStatus = 'ACTIVE';

  Future<void> _loadOperatorData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(widget.operatorId).get();

      if (doc.exists) {
        setState(() {
          operatorData = doc.data() as Map<String, dynamic>;

          // Inicializar os controladores de texto
          nameController.text = operatorData['userName'] ?? operatorData['username'] ?? "Usuário";
          emailController.text = operatorData['email'] ?? 'Não informado';

          // Carregar o status do operador
          operatorStatus = operatorData['status'] ?? 'ACTIVE';

          // Carregar sensores
          sensorIds = [];
          if (operatorData.containsKey('sensorId') && operatorData['sensorId'] is List) {
            sensorIds = List.from(operatorData['sensorId']);
          } else if (operatorData.containsKey('sensoresIDs') && operatorData['sensoresIDs'] is List) {
            sensorIds = List.from(operatorData['sensoresIDs']);
          }
        });
      }
    } catch (e) {
      print("Erro ao carregar dados do operador: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do operador'))
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para salvar as alterações
  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Atualiza os dados no Firestore
      await _firestore.collection('users').doc(widget.operatorId).update({
        'userName': nameController.text,
        'email': emailController.text,
        'sensoresIDs': sensorIds, // Atualiza os sensores
        'status': operatorStatus // Atualiza o status
      });

      // Atualiza os dados locais
      setState(() {
        operatorData['userName'] = nameController.text;
        operatorData['email'] = emailController.text;
        operatorData['sensoresIDs'] = sensorIds;
        operatorData['status'] = operatorStatus;
        isEditingEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados atualizados com sucesso'))
      );
    } catch (e) {
      print("Erro ao salvar alterações: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar alterações'))
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Adicione um método para alternar o status
  void _toggleStatus() {
    setState(() {
      operatorStatus = operatorStatus == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    });

    // Se não estiver no modo de edição, salvar imediatamente
    if (!isEditingEnabled) {
      _updateStatus();
    }
  }

  // Método para atualizar apenas o status
  Future<void> _updateStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(widget.operatorId).update({
        'status': operatorStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para ${operatorStatus == 'ACTIVE' ? 'Ativo' : 'Inativo'}'))
      );

      // Atualiza os dados locais
      setState(() {
        operatorData['status'] = operatorStatus;
      });
    } catch (e) {
      print("Erro ao atualizar status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status'))
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para adicionar um sensor
  void _addSensor() {
    if (sensorController.text.trim().isNotEmpty) {
      setState(() {
        if (!sensorIds.contains(sensorController.text.trim())) {
          sensorIds.add(sensorController.text.trim());
          sensorController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Este sensor já está associado ao operador'))
          );
        }
      });
    }
  }

  // Função para remover um sensor
  void _removeSensor(dynamic sensor) {
    setState(() {
      sensorIds.remove(sensor);
    });
  }

  // Função para excluir o operador
  void _deleteOperator() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Excluir Operador",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFFFF4200),
            ),
          ),
          content: Text(
            "Deseja realmente excluir este operador? Esta ação não pode ser desfeita.",
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
                "Cancelar",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore.collection('users').doc(widget.operatorId).delete();
                  Navigator.of(context).pop(); // Fecha o diálogo
                  Navigator.of(context).pop(); // Volta para a tela anterior

                  // Feedback visual para o usuário
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Operador removido com sucesso'),
                        backgroundColor: Colors.green,
                      )
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao remover operador: $e'),
                        backgroundColor: Colors.red,
                      )
                  );
                }
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
                "Excluir",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  // Botão de voltar
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFFFF4200), size: 28),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Título centralizado
                  Expanded(
                    child: Text(
                      'Detalhes do Operador',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFFFF4200),
                      ),
                    ),
                  ),
                  // Botão de edição ou atualização
                  IconButton(
                    icon: Icon(
                        isEditingEnabled ? Icons.save : Icons.edit,
                        color: Color(0xFFFF4200),
                        size: 24
                    ),
                    onPressed: isEditingEnabled ? _saveChanges : () {
                      setState(() {
                        isEditingEnabled = true;
                      });
                    },
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
                        border: Border.all(color: Color(0xFFFF4200), width: 3),
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

                    // Informações do operador
                    _buildProfileCard(),

                    SizedBox(height: 16),

                    // Informações da empresa
                    _buildCompanyCard(),

                    SizedBox(height: 16),

                    // Informações dos sensores associados
                    _buildSensorsCard(),

                    SizedBox(height: 24),

                    // Botão de excluir operador
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever, color: Colors.white),
                      label: Text(
                        'Excluir Operador',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _deleteOperator,
                    ),
                    SizedBox(height: 16),
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
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Color(0xFFFF4200)),
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
            isEditingEnabled
                ? _buildEditableInfoItem('Nome', nameController)
                : _buildInfoItem('Nome', operatorData['userName'] ?? operatorData['username'] ?? "Usuário"),

            isEditingEnabled
                ? _buildEditableInfoItem('E-mail', emailController)
                : _buildInfoItem('E-mail', operatorData['email'] ?? 'Não informado'),

            // Matrícula não é editável
            _buildInfoItem('Matrícula', operatorData['operatorId'] ?? 'Não informado'),

            _buildInfoItem('Tipo de Usuário', 'Operador'),

            // Campo de status com opção de alternar
            _buildStatusToggle(),
          ],
        ),
      ),
    );
  }

  // Widget para alternar o status
  Widget _buildStatusToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "Status:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: isEditingEnabled || true ? _toggleStatus : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: operatorStatus == 'ACTIVE' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: operatorStatus == 'ACTIVE' ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    operatorStatus == 'ACTIVE' ? Icons.check_circle : Icons.cancel,
                    color: operatorStatus == 'ACTIVE' ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    operatorStatus == 'ACTIVE' ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      color: operatorStatus == 'ACTIVE' ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: Color(0xFFFF4200)),
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
            _buildInfoItem('Empresa', operatorData['company'] ?? 'Não informado'),

            if (operatorData.containsKey('createdAt') && operatorData['createdAt'] != null)
              _buildInfoItem('Cadastrado em', _formatTimestamp(operatorData['createdAt'])),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Color(0xFFFF4200)),
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

            // Campo para adicionar sensor (apenas visível no modo edição)
            if (isEditingEnabled)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sensorController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFFF4200).withOpacity(0.5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFFF4200).withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFFF4200)),
                          ),
                          hintText: 'ID do sensor',
                          hintStyle: TextStyle(fontFamily: 'Poppins'),
                        ),
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Color(0xFFFF4200)),
                      onPressed: _addSensor,
                    ),
                  ],
                ),
              ),

            // Lista de sensores
            sensorIds.isEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhum sensor associado a este operador.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
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
                      // Botão para remover sensor (apenas visível no modo edição)
                      if (isEditingEnabled)
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSensor(sensorId),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
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

  Widget _buildEditableInfoItem(String label, TextEditingController controller) {
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
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFFF4200).withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFFF4200).withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFFF4200)),
                ),
              ),
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
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