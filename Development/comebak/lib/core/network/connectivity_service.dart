import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Layer 1: network interface up? (connectivity_plus)
// Layer 2: actual internet? (HTTP probe — catches captive portals / dead routers)
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final InternetConnection _internet = InternetConnection.createInstance(
    customCheckOptions: [
      InternetCheckOption(
        uri: Uri.parse('https://clients3.google.com/generate_204'),
        timeout: const Duration(seconds: 2),
      ),
      InternetCheckOption(
        uri: Uri.parse('https://www.gstatic.com/generate_204'),
        timeout: const Duration(seconds: 2),
      ),
    ],
  );

  // True when offline for app purposes (no interface OR no reachable internet).
  Future<bool> isOffline() async {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return true;
    }
    final hasInternet = await _internet.hasInternetAccess;
    return !hasInternet;
  }
}