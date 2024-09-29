import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  (done) 1. Create Add, Minus widget
    1) create add categorys 
    2) layout widget
    3) 

  2. set supabase database table

  3. uuid storage에 저장 후 
  테이블 생성 (gpt 참고)
  
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // 나중에 environ 처리 해줄 것
    url: 'https://wflfymtgepbnbvrusccq.supabase.co', // Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmbGZ5bXRnZXBibmJ2cnVzY2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY5MDY4NjYsImV4cCI6MjA0MjQ4Mjg2Nn0.91_7B2fQ2RUz-1DZNal4B57SodAjbpr75kXBHhoPu2Q', // Supabase Anon Key
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Uuid _uuid = const Uuid();
  String? _uniqueId;

  @override
  void initState() {
    super.initState();
    _loadUniqueId();
  }

  // UUID를 로컬 스토리지에서 불러오는 함수
  Future<void> _loadUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');

    if (storedId == null) {
      // UUID가 없으면 새로 생성하고 저장
      _uniqueId = _uuid.v4();
      await prefs.setString('uuid', _uniqueId!);
    } else {
      // 저장된 UUID가 있으면 사용
      _uniqueId = storedId;
    }

    // setState를 호출하여 UI 업데이트
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
          // primarySwatch: Colors.blue,
          ),
      home: const Scaffold(
        body: Home(),
      ),
    );
  }
}
