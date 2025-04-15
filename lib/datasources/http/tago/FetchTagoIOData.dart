import 'dart:convert';

import 'package:http/http.dart' as http;

class TagoIOService {
  Future<Map<String, dynamic>> fetchTagoIOData(String sensorId) async {
    try {
      String deviceToken = '55156222-043d-4058-8ed1-bae50449a22a';

      final response = await http.get(
        Uri.parse('http://api.tago.io/data?variables=inclinationData&groups=$sensorId&query=last_value'),
        headers: {
          'device-token': deviceToken
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        // Adaptar a resposta do Tago IO para o formato esperado
        return {
          'anguloLateral': _extractValue(jsonData, 'anguloLateral'),
          'anguloFrontal': _extractValue(jsonData, 'anguloFrontal'),
          'latitude': _extractValue(jsonData, 'latitude'),
          'longitude': _extractValue(jsonData, 'longitude'),
          'lastUpdate': _extractValue(jsonData, 'lastUpdate'),
        };
      } else {
        print('Falha ao obter dados do Tago IO: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Erro ao conectar ao Tago IO: $e');
      return {};
    }
  }

  dynamic _extractValue(Map<String, dynamic> jsonData, String field) {
    try {
      // Verificar se a resposta possui o formato esperado
      if (jsonData.containsKey('result') &&
          jsonData['result'] is List &&
          jsonData['result'].isNotEmpty) {

        // Obter o primeiro resultado (último valor)
        var lastData = jsonData['result'][0];

        // Para o campo lastUpdate, retornar diretamente o timestamp
        if (field == 'lastUpdate') {
          return lastData['time'];
        }

        // Verificar se o objeto possui campo metadata
        if (lastData.containsKey('metadata') && lastData['metadata'] is Map) {
          var metadata = lastData['metadata'];

          // Mapeamento dos campos de acordo com a resposta do TagoIO
          Map<String, String> fieldMapping = {
            'anguloLateral': 'lateralAngle',
            'anguloFrontal': 'frontalAngle',
            'latitude': 'latitude',
            'longitude': 'longitude'
          };

          // Retornar o valor correspondente do campo no metadata
          if (fieldMapping.containsKey(field) &&
              metadata.containsKey(fieldMapping[field])) {
            return metadata[fieldMapping[field]];
          }
        }
      }

      return null;
    } catch (e) {
      print('Erro ao extrair valor de $field: $e');
      return null;
    }
  }
}
