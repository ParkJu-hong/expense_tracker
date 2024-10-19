import 'package:expense_tracker/fixedexpense.dart';
import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/datestate.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // 나중에 environ 처리 해줄 것
    url: 'https://wflfymtgepbnbvrusccq.supabase.co', // Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmbGZ5bXRnZXBibmJ2cnVzY2NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY5MDY4NjYsImV4cCI6MjA0MjQ4Mjg2Nn0.91_7B2fQ2RUz-1DZNal4B57SodAjbpr75kXBHhoPu2Q', // Supabase Anon Key
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Datestate()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  final supabase = Supabase.instance.client;
  final storage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();
  String? _uniqueId;

  @override
  void initState() {
    super.initState();
  }

  Future<String> _loadUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');

    if (storedId == null) {
      // UUID가 없으면 새로 생성하고 저장
      _uniqueId = _uuid.v4();
      await prefs.setString('uuid', _uniqueId!);
      await storage.write(key: 'uuid', value: _uniqueId);
      String returnValue = '';
      await supabase
          .from('user_data')
          .insert({'device_uuid': _uniqueId}).then((value) {
        returnValue = value.toString();
      });
      return returnValue.toString();
    } else {
      // 저장된 UUID가 있으면 사용
      try {
        final response = await supabase
            .from('user_data')
            .select()
            .eq('device_uuid', storedId);
        _uniqueId = response[0]['device_uuid'];
        return _uniqueId.toString();
      } catch (error) {
        print('Error occurred: $error');
        return error.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      title: 'Expense Tracker',
      theme: ThemeData(
          // primarySwatch: Colors.blue,
          ),
      home: FutureBuilder(
        future: _loadUniqueId(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(150),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 15),
              ),
            );
          } else {
            return const Home();
          }
        },
      ),
    );
  }
}
