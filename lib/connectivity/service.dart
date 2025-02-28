import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class InternetConnectivityService {
  static Future<bool> isConnect() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<bool> hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(Duration(seconds: 10)); // Shorter timeout

      return response.statusCode ==
          204; // This URL responds with 204 if internet is active
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isConnected() async {
    if (await isConnect()) {
      return await hasInternetAccess();
    }
    return false;
  }
}
