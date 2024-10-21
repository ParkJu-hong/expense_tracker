import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/datacategorys.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/datestate.dart';

class MinusData extends StatefulWidget {
  const MinusData({
    super.key,
    this.selectedDateTime,
  });

  final String? selectedDateTime;

  @override
  State<MinusData> createState() => _MinusDataState();
}

class _MinusDataState extends State<MinusData> {
  final List<Map<String, IconData>> minusCategory = MinusCategory().MinusIcons;
  final TextEditingController _controller = TextEditingController();
  int selectedIconIndex = 0;
  int iconIndex = 4;
  String? categoryInput;
  String? infoInput;
  int? amountInput;

  String previousText = '';

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
    categoryInput = minusCategory[0].keys.first;
    super.initState();

    _controller.addListener(() {
      final text = _controller.text.replaceAll(',', '');

      if (text != previousText) {
        final formattedText = formatNumber(text);

        _controller.value = _controller.value.copyWith(
          text: formattedText,
          selection: TextSelection.collapsed(
            offset: formattedText.length,
          ),
        );

        previousText = formattedText;
      }
    });
  }

  Future<void> insertDailyRecord(String selectedDateTime) async {
    final supabase = Supabase.instance.client;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');

    int insertAmount = -(amountInput ?? 0);

    await supabase.from('daily_record').insert({
      'user_uuid': storedId.toString(),
      'date': selectedDateTime,
      'category': categoryInput,
      'info': infoInput ?? '',
      'amount': insertAmount ?? 0,
    }).then((value) {
      print('Insert success $value');
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final datestate = Provider.of<Datestate>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                amountInput = int.parse(value.replaceAll(',', ''));
              },
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
                    for (int i = 0; i <= 2; i++)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedIconIndex == i
                              ? Colors.amber
                              : Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedIconIndex = i;
                            categoryInput = minusCategory[i].keys.first;
                          });
                        },
                        child: Column(
                          children: [
                            Icon(
                              minusCategory[i].values.first,
                            ),
                            Text(
                              minusCategory[i].keys.first,
                            ),
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
                    for (int i = 3; i <= 5; i++)
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
                            categoryInput = minusCategory[i].keys.first;
                          })
                        },
                        child: Column(
                          children: [
                            Icon(
                              minusCategory[i].values.first,
                            ),
                            Text(
                              minusCategory[i].keys.first,
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                infoInput = value;
              },
              decoration: const InputDecoration(
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
                      await insertDailyRecord(datestate.selectedDateTime);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const Home()),
                      // );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Home()), // 이동할 화면
                        (Route<dynamic> route) => false, // 모든 이전 화면을 삭제
                      );
                    },
                    child: const Text('완료'))
              ],
            ),
          )
        ],
      ),
    );
  }
}
