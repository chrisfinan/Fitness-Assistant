import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'global_vars.dart';

Future<http.Response> authenticatedGetRequest(String endpoint) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sessionToken = prefs.getString('session_token');

  // Attach session token
  final response = await http.get(
    Uri.parse('$baseUrl/$endpoint'),
    headers: {
      'Cookie': sessionToken ?? '',
      'Content-Type': 'application/json',
    },
  );

  return response;
}