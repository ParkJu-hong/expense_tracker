import 'package:expense_tracker/dashboard.dart';
import 'package:expense_tracker/fixedexpense.dart';
import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/datacategorys.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/datestate.dart';

class FixedData extends StatefulWidget {
  const FixedData({
    super.key,
    this.selectedDateTime,
    this.whatRecordIs,
  });

  final String? selectedDateTime;
  final String? whatRecordIs;

  @override
  State<FixedData> createState() => _FixedDataState();
}

class _FixedDataState extends State<FixedData> {
  final List<Map<String, IconData>> fixedCategorys = FixedCategory().fixedIcons;
  final Map<String, IconData> specialCategorys = SpecialCategory().specialIcon;

  final TextEditingController _controller = TextEditingController();
  int selectedIconIndex = 0;
  int iconIndex = 4;
  String categoryInput = "";
  String? infoInput;
  int? amountInput;

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
    if (widget.whatRecordIs == 'fixed') {
      categoryInput = fixedCategorys[0].keys.first;
    } else if (widget.whatRecordIs == 'special') {
      categoryInput = specialCategorys.keys.first;
    }
    super.initState();

    _controller.addListener(() {
      final text = _controller.text;
      _controller.value = _controller.value.copyWith(
        text: formatNumber(text.replaceAll(',', '')),
        selection: TextSelection.collapsed(
          offset: formatNumber(text.replaceAll(',', '')).length,
        ),
      );
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
      'info': infoInput,
      'amount': insertAmount,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.whatRecordIs == 'fixed'
                    ? const FixedExpense(
                        whatRecordsIs: 'fixed',
                      )
                    : const FixedExpense(
                        whatRecordsIs: 'special',
                      ),
              ),
            );
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
          if (widget.whatRecordIs == 'fixed')
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
                              categoryInput = fixedCategorys[i].keys.first;
                            });
                          },
                          child: Column(
                            children: [
                              Icon(fixedCategorys[i].values.first),
                              Text(fixedCategorys[i].keys.first),
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
                      for (int i = 3; i <= 4; i++)
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
                              categoryInput = fixedCategorys[i].keys.first;
                            })
                          },
                          child: Column(
                            children: [
                              Icon(fixedCategorys[i].values.first),
                              Text(fixedCategorys[i].keys.first),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          else if (widget.whatRecordIs == 'special')
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.amber,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            categoryInput = specialCategorys.keys.first;
                          });
                        },
                        child: Column(
                          children: [
                            Icon(specialCategorys.values.first),
                            Text(specialCategorys.keys.first),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => widget.whatRecordIs == 'fixed'
                                ? const FixedExpense(
                                    whatRecordsIs: 'fixed',
                                  )
                                : const FixedExpense(
                                    whatRecordsIs: 'special',
                                  ),
                          ));
                    },
                    child: const Text('완료'))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
