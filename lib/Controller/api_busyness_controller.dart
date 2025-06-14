import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTestController {
  static const String _baseUrl = 'https://nedtest.store/api/busyness';

  // Fetch the current busyness state
  static Future<Map<String, dynamic>> fetchBusynessStatus() async {
    final response = await http.get(Uri.parse('$_baseUrl'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load busyness status');
    }
  }

  // Update the busyness state
  static Future<void> updateBusynessStatus(String state) async {
    final response = await http.post(
      Uri.parse('$_baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'state': state}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update busyness status');
    }
  }
}