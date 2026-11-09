import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await Supabase.initialize(
    url: 'https://isiggphtpfrmxyosnhzc.supabase.co', 
    // Use the Publishable key (or the legacy anon key)
    publishableKey: 'sb_publishable_AtjjW81lUvI0c-QWqJZwxw_HFLA6mtF', 
  );

  // 2. Enforce Portrait Mode
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Run the App
  runApp(const ComebakApp());
}