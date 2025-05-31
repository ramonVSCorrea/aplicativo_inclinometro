import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class AllEventsPage extends StatefulWidget {
  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];
  Map<String, List<Map<String, dynamic>>> _groupedEvents = {};
  Set<String> _expandedGroups = {};
  final Set<String> _expandedItems = {};
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String deviceToken = '55156222-043d-4058-8ed1-bae50449a22a';

      final response = await http.get(
        Uri.parse('http://api.tago.io/data?variables=event'),
        headers: {
          'device-token': deviceToken
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        List<Map<String, dynamic>> eventsList = [];
        Map<String, List<Map<String, dynamic>>> groupedEvents = {};

        if (jsonData.containsKey('result') && jsonData['result'] is List) {
          for (var item in jsonData['result']) {
            if (item.containsKey('metadata') &&
                item['metadata'] is Map &&
                item['metadata'].containsKey('event')) {

              final eventData = {
                'id': item['id'] ?? '',
                'time': item['time'] ?? DateTime.now().toIso8601String(),
                'event': item['metadata']['event'] ?? 'Evento desconhecido',
                'description': item['metadata']['description'] ?? 'Sem descrição',
                'lateralAngle': item['metadata']['lateralAngle'] ?? 0.0,
                'frontalAngle': item['metadata']['frontalAngle'] ?? 0.0,
                'latitude': item['metadata']['latitude'] ?? null,
                'longitude': item['metadata']['longitude'] ?? null,
                'group': item['group'] ?? 'Desconhecido',
                'device': item['device'] ?? 'Desconhecido',
              };

              eventsList.add(eventData);

              // Agrupar eventos por ID do sensor (group)
              String sensorId = item['group'] ?? 'Desconhecido';
              if (!groupedEvents.containsKey(sensorId)) {
                groupedEvents[sensorId] = [];
              }
              groupedEvents[sensorId]!.add(eventData);
            }
          }
        }

        // Ordenar os eventos dentro de cada grupo por data (mais recente primeiro)
        groupedEvents.forEach((key, value) {
          value.sort((a, b) {
            DateTime dateA = DateTime.parse(a['time']);
            DateTime dateB = DateTime.parse(b['time']);
            return dateB.compareTo(dateA);
          });
        });

        setState(() {
          _events = eventsList;
          _groupedEvents = groupedEvents;
          _isLoading = false;
        });
      } else {
        print('Falha ao obter eventos do Tago IO: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao conectar ao Tago IO: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return "Data inválida";
    }
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

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        print('Permissão de armazenamento concedida');
      } else {
        print('Permissão de armazenamento negada');
      }
    }
  }

  Future<void> _exportAllEventsToCSV() async {
    if (_events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não há eventos para exportar')),
      );
      return;
    }

    if (_isExporting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export já está em andamento')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Solicitar permissão de armazenamento
      await requestStoragePermission();

      // Preparar conteúdo CSV
      final csvHeader = 'Data e Hora,Sensor ID,Evento,Descrição,Ângulo Lateral,Ângulo Frontal,Latitude,Longitude\n';
      String csvContent = csvHeader;
      for (var event in _events) {
        final formattedDate = _formatDate(event['time']);
        final sensorId = event['group'].toString();
        final eventType = event['event'].toString().replaceAll(',', ' ');
        final description = event['description'].toString().replaceAll(',', ' ');
        final lateralAngle = event['lateralAngle'] ?? 'N/A';
        final frontalAngle = event['frontalAngle'] ?? 'N/A';
        final latitude = event['latitude'] ?? 'N/A';
        final longitude = event['longitude'] ?? 'N/A';

        csvContent += '$formattedDate,"$sensorId","$eventType","$description",$lateralAngle,$frontalAngle,$latitude,$longitude\n';
      }

      // Nome sugerido para o arquivo
      final now = DateTime.now();
      final suggestedFileName = 'todos_eventos_${now.day}-${now.month}-${now.year}.csv';

      if (Platform.isAndroid) {
        // Usar intent CREATE_DOCUMENT em Android
        try {
          // Este approach usa uma intent do sistema para criar documentos
          final params = SaveFileDialogParams(
            sourceFilePath: null, // Conteúdo será gravado depois
            data: utf8.encode(csvContent), // Passar o conteúdo como bytes
            fileName: suggestedFileName,
            mimeTypesFilter: ['text/csv'],
          );

          final filePath = await FlutterFileDialog.saveFile(params: params);

          if (filePath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Arquivo salvo com sucesso: $filePath'))
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Operação cancelada pelo usuário'))
            );
          }
        } catch (e) {
          // Fallback para o método FilePicker
          await _saveUsingFilePicker(csvContent, suggestedFileName);
        }
      } else {
        // Para iOS e outros sistemas
        await _saveUsingFilePicker(csvContent, suggestedFileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar eventos: $e'))
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _saveUsingFilePicker(String content, String suggestedFileName) async {
    final TextEditingController fileNameController = TextEditingController(text: suggestedFileName);

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Escolha onde salvar o arquivo CSV',
    );

    if (selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operação cancelada'))
      );
      return;
    }

    String? fileName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Nome do arquivo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFFFF4200),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fileNameController,
                decoration: InputDecoration(
                  labelText: 'Digite o nome do arquivo',
                  hintText: 'todos_eventos.csv',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                String name = fileNameController.text.trim();
                if (!name.toLowerCase().endsWith('.csv')) name += '.csv';
                Navigator.of(context).pop(name);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF4200)),
              child: Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (fileName == null) return;

    final filePath = '$selectedDirectory/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      bool? replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Arquivo já existe'),
          content: Text('Deseja substituir o arquivo existente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF4200)),
              child: Text('Sim', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (replace != true) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Arquivo não substituído'))
        );
        return;
      }
    }

    await file.writeAsString(content);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eventos salvos em $filePath'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFF4200)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Histórico de Eventos",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFFFF4200)),
            onPressed: _loadAllEvents,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
          : _events.isEmpty
          ? Center(
        child: Text(
          "Nenhum evento registrado",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontFamily: 'Poppins',
          ),
        ),
      )
          : RefreshIndicator(
        color: Color(0xFFFF4200),
        onRefresh: _loadAllEvents,
        child: ListView.builder(
          itemCount: _groupedEvents.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            String sensorId = _groupedEvents.keys.elementAt(index);
            List<Map<String, dynamic>> sensorEvents = _groupedEvents[sensorId]!;
            bool isGroupExpanded = _expandedGroups.contains(sensorId);

            return Card(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Color(0xFFFF4200).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Cabeçalho do grupo/sensor
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isGroupExpanded) {
                          _expandedGroups.remove(sensorId);
                        } else {
                          _expandedGroups.add(sensorId);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF4200).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sensors,
                              color: Color(0xFFFF4200),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sensor: $sensorId",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${sensorEvents.length} eventos registrados",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isGroupExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Color(0xFFFF4200),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Eventos do sensor (quando expandido)
                  if (isGroupExpanded)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sensorEvents.length,
                      itemBuilder: (context, eventIndex) {
                        final event = sensorEvents[eventIndex];
                        final String itemKey = '$sensorId-$eventIndex';
                        final bool isEventExpanded = _expandedItems.contains(itemKey);

                        // Extrair dados de localização
                        double? latitude = _getDoubleValue(event['latitude']);
                        double? longitude = _getDoubleValue(event['longitude']);
                        bool hasLocation = latitude != null && longitude != null;

                        Color eventColor;
                        IconData eventIcon;

                        // Definir cor e ícone baseado no tipo de evento
                        switch (event['event'].toString().toLowerCase()) {
                        // Eventos críticos - vermelho
                          case 'bloqueio':
                            eventColor = Colors.red[700]!;
                            eventIcon = Icons.block;
                            break;
                          case 'inclinômetro desconectado':
                          case 'wi-fi desconectado':
                            eventColor = Colors.red[700]!;
                            eventIcon = Icons.link_off;
                            break;

                        // Eventos de alerta - laranja
                          case 'alerta':
                          case 'valores de bloqueio alterados':
                            eventColor = Colors.orange[700]!;
                            eventIcon = Icons.warning_amber;
                            break;

                        // Eventos positivos - verde
                          case 'desbloqueio':
                          case 'sensor zerado':
                          case 'sensor calibrado':
                          case 'inclinômetro conectado':
                          case 'wi-fi conectado':
                            eventColor = Colors.green[600]!;
                            eventIcon = Icons.check_circle;
                            break;

                        // Eventos informativos - azul
                          case 'início do basculamento':
                            eventColor = Color(0xFF0055AA);
                            eventIcon = Icons.arrow_upward;
                            break;
                          case 'fim do basculamento':
                            eventColor = Color(0xFF0055AA);
                            eventIcon = Icons.arrow_downward;
                            break;

                        // Outros eventos - laranja padrão
                          default:
                            eventColor = Color(0xFFFF4200);
                            eventIcon = Icons.info;
                        }

                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: eventColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isEventExpanded) {
                                  _expandedItems.remove(itemKey);
                                } else {
                                  _expandedItems.add(itemKey);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: eventColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(eventIcon, color: eventColor),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['event'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _formatDate(event['time']),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isEventExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  if (isEventExpanded) ...[
                                    SizedBox(height: 12),
                                    Divider(),
                                    SizedBox(height: 8),
                                    Text(
                                      "Descrição:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      event['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildAngleInfo(
                                            "Ângulo Lateral",
                                            event['lateralAngle'],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _buildAngleInfo(
                                            "Ângulo Frontal",
                                            event['frontalAngle'],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Seção de localização
                                    SizedBox(height: 16),
                                    if (hasLocation) ...[
                                      Text(
                                        "Localização:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => _openMap(latitude!, longitude!),
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
                                                      color: Color(0xFFFF4200),
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
                                          "Coordenadas: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ] else
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          "Localização não disponível para este evento",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isExporting ? null : _exportAllEventsToCSV,
        backgroundColor: _isExporting ? Colors.grey : Color(0xFFFF4200),
        tooltip: 'Exportar para CSV',
        child: _isExporting
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Icon(Icons.download, color: Colors.white),
      ),
    );
  }

  Widget _buildAngleInfo(String title, dynamic value) {
    double? angle;
    if (value is double) {
      angle = value;
    } else if (value is int) {
      angle = value.toDouble();
    } else if (value is String) {
      try {
        angle = double.parse(value);
      } catch (_) {}
    }

    Color angleColor = Colors.green;
    if (angle != null) {
      double absAngle = angle.abs();
      if (absAngle < 5) angleColor = Colors.green;
      else if (absAngle < 10) angleColor = Colors.yellow;
      else if (absAngle < 15) angleColor = Colors.orange;
      else angleColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFFF4200).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              if (angle != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: angleColor,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  "${angle.toStringAsFixed(1)}°",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ] else
                Text(
                  "N/A",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}