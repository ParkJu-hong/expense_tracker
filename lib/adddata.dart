import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/addcategory.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class AddData extends StatefulWidget {
  const AddData({super.key});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final List<Map<String, IconData>> _addCategory = AddCategory().addIcons;
  final TextEditingController _controller = TextEditingController();
  int selectedIconIndex = 0;
  int iconIndex = 4;

  // functions starts
  String formatNumber(String s) {
    if (s.isEmpty) return '';
    final number = int.parse(s);
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final text = _controller.text;
      _controller.value = _controller.value.copyWith(
        text: formatNumber(text.replaceAll(',', '')), // 콤마 제거 후 다시 포맷
        selection: TextSelection.collapsed(
          offset: formatNumber(text.replaceAll(',', '')).length,
        ),
      );
    });
  }

  Future<void> insertDailyRecord() async {
    DateTime now = DateTime.now();
    String dateString = now.toIso8601String(); // ISO 8601 형식의 문자열로 변환
    // Map<String, dynamic> jsonData = {
    //   'current_time': dateString,
    // };
    // String jsonString = jsonEncode(jsonData);
    final supabase = Supabase.instance.client;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    await supabase.from('daily_record').insert({
      'user_uuid': storedId.toString(),
      'date': dateString,
      'category': 'testCategory',
      'info': 'testInfo',
      'amount': 10000
    }).then((value) {
      print(value);
    }).catchError((error) {
      print('error test');
      print(error);
    });
  }

  /*
      id serial primary key,
  user_uuid text not null references user_data(device_uuid),
  date date not null,
  category text not null,
  info text,
  amount int not null,
  created_at timestamp not null default now()
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 왼쪽 방향 화살표 아이콘
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              textAlign: TextAlign.right,
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ex) 10,000',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 0; i <= 3; i++)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedIconIndex == i
                              ? Colors.amber
                              : Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => {
                          setState(() {
                            selectedIconIndex = i;
                          })
                        },
                        child: Column(
                          children: [
                            Icon(_addCategory[i].values.first),
                            Text(_addCategory[i].keys.first),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 4; i <= 7; i++)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedIconIndex == i
                              ? Colors.amber
                              : Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => {
                          setState(() {
                            selectedIconIndex = i;
                          })
                        },
                        child: Column(
                          children: [
                            Icon(_addCategory[i].values.first),
                            Text(_addCategory[i].keys.first),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '내역',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await insertDailyRecord();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  },
                  child: const Text('완료'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
