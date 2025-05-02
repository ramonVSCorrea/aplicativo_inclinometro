import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SensorEventsPage extends StatefulWidget {
  final String sensorId;

  SensorEventsPage({required this.sensorId});

  @override
  _SensorEventsPageState createState() => _SensorEventsPageState();
}

class _SensorEventsPageState extends State<SensorEventsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];
  final Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String deviceToken = '55156222-043d-4058-8ed1-bae50449a22a';

      final response = await http.get(
        Uri.parse('http://api.tago.io/data?variables=event&groups=${widget.sensorId}'),
        headers: {
          'device-token': deviceToken
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        List<Map<String, dynamic>> eventsList = [];

        if (jsonData.containsKey('result') && jsonData['result'] is List) {
          for (var item in jsonData['result']) {
            if (item.containsKey('metadata') &&
                item['metadata'] is Map &&
                item['metadata'].containsKey('event')) {

              eventsList.add({
                'id': item['id'] ?? '',
                'time': item['time'] ?? DateTime.now().toIso8601String(),
                'event': item['metadata']['event'] ?? 'Evento desconhecido',
                'description': item['metadata']['description'] ?? 'Sem descrição',
                'lateralAngle': item['metadata']['lateralAngle'] ?? 0.0,
                'frontalAngle': item['metadata']['frontalAngle'] ?? 0.0,
                'latitude': item['metadata']['latitude'] ?? null,
                'longitude': item['metadata']['longitude'] ?? null,
              });
            }
          }
        }

        setState(() {
          _events = eventsList;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eventos do Sensor ${widget.sensorId}"),
        backgroundColor: Color(0xFFA59AFF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? Center(
        child: Text(
          "Nenhum evento registrado para este sensor",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView.builder(
          itemCount: _events.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final event = _events[index];
            final bool isExpanded = _expandedItems.contains(index);

            // Extrair dados de localização
            double? latitude = _getDoubleValue(event['latitude']);
            double? longitude = _getDoubleValue(event['longitude']);
            bool hasLocation = latitude != null && longitude != null;

            Color eventColor;
            IconData eventIcon;

            // Definir cor e ícone baseado no tipo de evento
            switch (event['event'].toString().toLowerCase()) {
              case 'bloqueio':
                eventColor = Colors.red;
                eventIcon = Icons.block;
                break;
              case 'alerta':
                eventColor = Colors.orange;
                eventIcon = Icons.warning_amber;
                break;
              case 'desbloqueio':
                eventColor = Colors.green;
                eventIcon = Icons.check_circle;
                break;
              default:
                eventColor = Colors.blue;
                eventIcon = Icons.info;
            }

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
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
                    if (isExpanded) {
                      _expandedItems.remove(index);
                    } else {
                      _expandedItems.add(index);
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
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatDate(event['time']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 8),
                        Text(
                          "Descrição:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          event['description'],
                          style: TextStyle(fontSize: 14),
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
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Container(color: Colors.grey[100]),
                                Center(
                                  child: Icon(
                                    Icons.location_on,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
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
                              "Coordenadas: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}",
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
                        ] else
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Localização não disponível para este evento",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
                  ),
                ),
              ] else
                Text(
                  "N/A",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}