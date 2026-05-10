import 'package:flutter/material.dart';
import 'package:mainpageonly/services/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aofdidiidclzkkbdgbkc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZmRpZGlpZGNsemtrYmRnYmtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NzM0MjEsImV4cCI6MjA5MzQ0OTQyMX0.0W-UTp4bYgmj7ExHHkSCGZtpPQpwSAhe0GVG4rtxTjg',
  );

  runApp( 
  const ProviderScope(
    child: ReloopOmanApp(),
  ),
);
}

class ReloopOmanApp extends StatelessWidget {
  const ReloopOmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reloop Oman',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const AuthGate(),
    );
  }
}