import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = '9327bf900fc588599c67be85ac03e9aa';
  static const String city = 'Karachi'; // Change as needed

  static Future<String> getWeatherCategory() async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Fetch the temperature in Kelvin
      final temperatureInKelvin = data['main']['temp']; // Temperature in Kelvin

      // Convert temperature from Kelvin to Celsius
      final temperatureInCelsius = temperatureInKelvin - 273.15;

      // Debug: print temperature in Celsius
      print("Temperature in Celsius: $temperatureInCelsius");

      // Fetch the weather condition
      final weatherCondition = data['weather'][0]['main']; // e.g., "Clear", "Rain", etc.

      // Check for Rainy condition first, if true return "Rainy"
      if (weatherCondition.contains('Rain')) {
        return 'rainy';
      }

      // General classification based only on temperature
      if (temperatureInCelsius > 30) {
        return 'hot'; // Classifies as Hot if above 30°C
      } else if (temperatureInCelsius <= 30 && temperatureInCelsius > 20) {
        return 'pleasant'; // Classifies as Moderate if between 20°C and 30°C
      } else {
        return 'cold'; // Classifies as Cold if less than or equal to 20°C
      }
    }

    // If the request fails or data is missing, return 'Unknown'
    return 'Unknown';
  }
}
