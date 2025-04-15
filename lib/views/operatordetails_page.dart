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

  Future<void> _loadOperatorData([Function? onComplete]) async {
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

        if (onComplete != null) {
          onComplete();
        }
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "Editar operador",
            onPressed: () {
              _showEditDialog();
            },
          ),
        ],
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

  void _showEditDialog() {
    final TextEditingController nameController = TextEditingController(
        text: operatorData['userName'] ?? operatorData['username'] ?? "");
    final TextEditingController matriculaController = TextEditingController(
        text: operatorData['operatorId'] ?? operatorData['matricula'] ?? "");

    // Controllers para os sensores
    List<TextEditingController> sensorControllers = [];
    List<String> sensores = _getSensorList();

    // Adicionar controller para cada sensor
    for (String sensor in sensores) {
      sensorControllers.add(TextEditingController(text: sensor));
    }

    // Adicionar um campo vazio para novo sensor
    sensorControllers.add(TextEditingController());

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Operador"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Nome"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira um nome";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: matriculaController,
                    decoration: InputDecoration(labelText: "Matrícula"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Sensores Associados",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Lista de sensores
                  ...List.generate(sensorControllers.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: sensorControllers[index],
                              decoration: InputDecoration(
                                labelText: index < sensores.length
                                    ? "Sensor ${index + 1}"
                                    : "Novo sensor",
                                hintText: "ID do sensor",
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              // Remover apenas se não for o último (vazio)
                              if (index < sensorControllers.length - 1) {
                                sensorControllers.removeAt(index);
                                Navigator.of(context).pop();
                                _showEditDialog(); // Reabrir o diálogo
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Adicionar sensor"),
                    onPressed: () {
                      sensorControllers.add(TextEditingController());
                      Navigator.of(context).pop();
                      _showEditDialog(); // Reabrir o diálogo com o campo adicional
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    "E-mail: ${operatorData['email']}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    "Empresa: ${operatorData['company']}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Salvar"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Filtrar sensores não vazios
                  List<String> novosSensores = sensorControllers
                      .map((controller) => controller.text.trim())
                      .where((sensorId) => sensorId.isNotEmpty)
                      .toList();

                  _updateOperator(
                    nameController.text,
                    matriculaController.text,
                    novosSensores,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateOperator(String name, String matricula, List<String> sensores) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Determine qual campo de nome usar com base no que está presente no documento
      Map<String, dynamic> updateData = {};

      if (operatorData.containsKey('userName')) {
        updateData['userName'] = name;
      } else {
        updateData['username'] = name;
      }

      // Adiciona a matrícula apenas se não estiver vazia
      if (matricula.isNotEmpty) {
        if (operatorData.containsKey('operatorId')) {
          updateData['operatorId'] = matricula;
        } else {
          updateData['matricula'] = matricula;
        }
      }

      // Determinar qual campo de sensores usar
      if (operatorData.containsKey('sensorId')) {
        updateData['sensorId'] = sensores;
      } else if (operatorData.containsKey('sensoresIDs')) {
        updateData['sensoresIDs'] = sensores;
      } else {
        // Se não existir nenhum dos campos, usar sensorId como padrão
        updateData['sensorId'] = sensores;
      }

      await _firestore
          .collection('users')
          .doc(widget.operatorId)
          .update(updateData);

      // Recarregar os dados atualizados
      await _loadOperatorData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operador atualizado com sucesso')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar operador: $e')),
      );
    }
  }
}