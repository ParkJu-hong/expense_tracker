import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  가상 ios 시뮬레이터가 안되니 나중에 C to 8 pins cable 사서
  내 핸드폰으로 테스트 해볼 것
 */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  String? _userId;

  @override
  void initState() {
    super.initState();
    // _initializeUser();
    _userId = 'test';
  }

  // 사용자 UUID 초기화 함수
  Future<void> _initializeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');

    setState(() {
      _userId = storedUserId;
    });

    print("User ID: $_userId");
  }

  // Supabase에 데이터 저장
  Future<void> _saveData(String data) async {
    print('_saveData 실행');
    final response = await supabase.from('user_data').insert({
      'userId': _userId,
      'data': data,
    });

    if (response.error == null) {
      print('데이터 저장 성공');
    } else {
      print('데이터 저장 실패: ${response.error!.message}');
    }
  }

  // Supabase에서 사용자 데이터 가져오기
  Future<void> _getData(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Home()));
    /*
    final response = await supabase
        .from('user_data')
        .select()
        .eq('userId', _userId.toString());
    response.add({'test_key': 'test_value'});
    print(response);
    if (response != [] || response != null) {
      print('_getData if문 실행');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Home()));
      print('데이터 조회 성공: $response');
    } else {
      print('데이터 조회 실패: $response');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase UUID Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('User ID: $_userId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveData('사용자의 데이터');
              },
              child: const Text('데이터 저장'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _getData(context);
              },
              child: const Text('데이터 가져오기'),
            ),
          ],
        ),
      ),
    );
  }
}
