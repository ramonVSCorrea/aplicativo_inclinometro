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

  Future<Map<String, dynamic>> fetchSensorConfigurations(String sensorId) async {
    try {
      final response = await http.get(
        Uri.parse('http://api.tago.io/data?variables=deviceConfigurations&groups=$sensorId&query=last_value'),
        headers: {'device-token': '55156222-043d-4058-8ed1-bae50449a22a'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Verifica se há dados disponíveis
        if (jsonResponse['result'] != null && jsonResponse['result'].isNotEmpty) {
          final result = jsonResponse['result'][0];

          // Extrair dados do campo metadata
          if (result.containsKey('metadata') && result['metadata'] is Map) {
            Map<String, dynamic> metadata = result['metadata'];
            Map<String, dynamic> configData = {};

            // Combina as configurações de diferentes campos do metadata
            if (metadata.containsKey('configurations') && metadata['configurations'] is Map) {
              configData.addAll(metadata['configurations']);
            }

            if (metadata.containsKey('wifiConfigs') && metadata['wifiConfigs'] is Map) {
              configData.addAll(metadata['wifiConfigs']);
            }

            // Adiciona outros campos relevantes se necessário
            return configData;
          }
        }
        return {};
      } else {
        print('Falha ao buscar configurações: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Erro ao buscar configurações: $e');
      return {};
    }
  }
}
