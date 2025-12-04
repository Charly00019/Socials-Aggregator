import 'dart:convert';
import 'package:http/http.dart' as http;

class TwitterService {
  // Fetch tweets from your backend API
  static Future<List<dynamic>> fetchTweets() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/tweets/timeline'), // Emulator
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // your backend likely returns { data: [...] }
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load tweets: ${response.statusCode} ${response.body}');
    }
  }
}
