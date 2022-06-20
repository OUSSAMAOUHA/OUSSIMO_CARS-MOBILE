import 'dart:convert';
import 'package:http/http.dart' as http;

class VoitureTracer {
  String baseUrl = "http://vehiculetracker.herokuapp.com/sendvoiteur";
  Future<List> getAllVoitureTracer() async {
    try {
      var response = await http.get(Uri.parse(baseUrl));
      print("hello");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error("Server Error");
      }
    } catch (e) {
      return Future.error(e);
    }
  }
}
