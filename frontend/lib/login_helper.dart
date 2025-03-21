import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'global_vars.dart';

Future<http.Response> authenticatedGetRequest(String endpoint) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sessionToken = prefs.getString('session_token');

  final response = await http.get(
    Uri.parse('$baseUrl/$endpoint'),
    headers: {
      'Cookie': sessionToken ?? '', // Attach session token
      'Content-Type': 'application/json',
    },
  );

  return response;
}
