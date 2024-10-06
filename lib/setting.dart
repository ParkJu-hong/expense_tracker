import 'package:expense_tracker/fixedexpense.dart';
import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/datestate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  void test() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    final supabase = Supabase.instance.client;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.01,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '환경설정',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.09),
                    ),
                    IconButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ),
                        ),
                      },
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: MediaQuery.of(context).size.width * 0.09,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '전체 데이터 초기화',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => {
                            /*
                            // 전체 데이터 초기화로 라우팅
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FixedExpense(
                                  whatRecordsIs: 'fixed',
                                ),
                              ),
                            ),
                            */
                          },
                          icon: Icon(
                            Icons.arrow_right,
                            size: MediaQuery.of(context).size.width * 0.09,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Export Excel With E-mail',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => {
                            /*
                            // 엑셀 이메일로 보내는 위젯으로 라우팅
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FixedExpense(
                                  whatRecordsIs: 'fixed',
                                ),
                              ),
                            ),
                            */
                          },
                          icon: Icon(
                            Icons.arrow_right,
                            size: MediaQuery.of(context).size.width * 0.09,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
