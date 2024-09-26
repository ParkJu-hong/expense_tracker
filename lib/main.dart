import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracker/expenseListScreen.dart';
import 'package:expense_tracker/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    // 나중에 environ 처리 해줄 것
    url: 'https://wflfymtgepbnbvrusccq.supabase.co', // Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmbGZ5bXRnZXBibmJ2cnVzY2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY5MDY4NjYsImV4cCI6MjA0MjQ4Mjg2Nn0.91_7B2fQ2RUz-1DZNal4B57SodAjbpr75kXBHhoPu2Q', // Supabase Anon Key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
          // primarySwatch: Colors.blue,
          ),
      home: const Home(),
    );
  }
}
