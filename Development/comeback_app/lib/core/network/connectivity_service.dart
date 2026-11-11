import 'package:connectivity_plus/connectivity_plus.dart';

// Minimal connectivity helper. Treats result as a hint only —
// always pair with try/catch or timeout on real network calls.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  // Returns true when the device reports no network interface.
  // Does NOT guarantee reachability of the internet (captive portals, etc.).
  Future<bool> isOffline() async {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }
}
