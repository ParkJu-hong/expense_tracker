import 'package:expense_tracker/adddata.dart';
import 'package:expense_tracker/minusdata.dart';
import 'package:expense_tracker/setting.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/datestate.dart';
import 'package:expense_tracker/datacategorys.dart';
import 'package:month_year_picker/month_year_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateState = Provider.of<Datestate>(context, listen: false);
      initializeData(dateState.selectedDateTime);
    });
  }

  @override
  void dispose() {
    if (_pageViewController.hasClients) {
      _pageViewController.dispose();
    }
    super.dispose();
  }

  // Initialize variables
  final supabase = Supabase.instance.client;
  static const IconData space_dashboard_outlined =
      IconData(0xf3bd, fontFamily: 'MaterialIcons');
  String? nowMonth;
  int today = DateTime.now().day;
  List<Map<int, String>> dayOfTheWeek = [];
  List<List<String>> weeks = [];
  List<dynamic> dailyRecords = [];
  int foundScorllIndex = 0;
  String totalAmount = '';
  final List<Map<String, IconData>> _addCategory = AddCategory().addIcons;
  final List<Map<String, IconData>> _minusCategory = MinusCategory().MinusIcons;
  final List<Map<String, IconData>> _fixedCategory = FixedCategory().fixedIcons;
  final List<Map<String, IconData>> _specialCategory = [
    SpecialCategory().specialIcon
  ];
  PageController _pageViewController = PageController(
    initialPage: 0,
  );

  // functions start

  void setDate(List<Map<int, String>> dayOfTheWeek, String selectedDate) {
    List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    String selectedYear = selectedDate.split('-')[0];
    String selectedMonth = selectedDate.split('-')[1];

    nowMonth = selectedDate.split('-')[1];

    String firstDayOfMonth = dayOfTheWeek.first.values.first;

    List<String> firstWeek = [];
    int startIndex = weekDays.indexOf(firstDayOfMonth);

    for (int i = 0; i < startIndex; i++) {
      firstWeek.add('');
    }

    for (int i = 0; i < 7 - startIndex; i++) {
      String dateString =
          '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${(i + 1).toString().padLeft(2, '0')}';
      firstWeek.add(dateString);
    }
    weeks.add(firstWeek);

    for (int i = 7 - startIndex; i < dayOfTheWeek.length; i += 7) {
      List<String> week = [];
      for (int j = i; j < i + 7 && j < dayOfTheWeek.length; j++) {
        String dateString =
            '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${(j + 1).toString().padLeft(2, '0')}';
        week.add(dateString);
      }

      if (week.length < 7) {
        for (int k = week.length; k < 7; k++) {
          week.add('');
        }
      }
      weeks.add(week);
    }
  }

  void getDate(String selectedDate) {
    DateTime tempSelectedDate = DateTime.parse(selectedDate);
    String tempSelectedDateString = formatDate(selectedDate);

    DateTime lastDayOfMonth =
        DateTime(tempSelectedDate.year, tempSelectedDate.month + 1, 0);

    int daysInMonth = lastDayOfMonth.day;
    List<DateTime> daysOfMonth = [];

    for (int i = 0; i < daysInMonth; i++) {
      daysOfMonth.add(DateTime(int.parse(tempSelectedDateString.split('-')[0]),
          int.parse(tempSelectedDateString.split('-')[1]), i + 1));
    }

    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<Map<int, String>> result = [];

    for (var day in daysOfMonth) {
      result.add({day.day: weekdays[day.weekday - 1]});
    }

    setDate(result, selectedDate);
  }

  int foundIndex(target) {
    int foundIndex = -1;
    for (int i = 0; i < weeks.length; i++) {
      for (int j = 0; j < weeks[i].length; j++) {
        if (weeks[i][j].contains(target.toString())) {
          foundIndex = i;
          break;
        }
      }
    }
    return foundIndex;
  }

  Future<String> getTotalAmountOfAday(String nowDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    String result = '';
    await supabase
        .from('user_data')
        .select('''
    daily_record(amount)
  ''')
        .eq('daily_record.user_uuid', storedId.toString())
        .eq('daily_record.date', nowDate)
        .then((value) {
          int totalAmountResult = 0;

          for (var item in value) {
            final dailyRecords = item['daily_record'] as List?;
            if (dailyRecords != null) {
              for (var record in dailyRecords) {
                totalAmountResult += (record['amount'] ?? 0) as int;
              }
            }
          }

          String formattedNumber =
              totalAmountResult.toString().replaceAllMapped(
                    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                    (Match match) => '${match[1]},',
                  );
          setState(() {
            totalAmount = formattedNumber;
          });

          result = formattedNumber;
        })
        .catchError((error) {
          print(error);
        });
    return result;
  }

  Future<List<Map<String, dynamic>>> getDailyRecords(String nowDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    List<Map<String, dynamic>> result = [];

    await supabase
        .from('daily_record')
        .select('''
          id, category, amount, info, date
    ''')
        .eq('user_uuid', storedId.toString())
        .eq('date', nowDate)
        .then((value) {
          setState(() {
            dailyRecords = value;
          });
          result = value;
        })
        .catchError((error) {
          print(error);
        });

    return result;
  }

  Future<void> initializeData(selectedDate) async {
    try {
      getDate(selectedDate);
      String result1 = await getTotalAmountOfAday(selectedDate);
      List<Map<String, dynamic>> result2 = await getDailyRecords(selectedDate);
      foundScorllIndex = foundIndex(selectedDate.toString());

      if (_pageViewController.hasClients) {
        _pageViewController.jumpToPage(foundScorllIndex);
      } else {
        _pageViewController = PageController(initialPage: foundScorllIndex);
      }

      setState(() {
        dailyRecords = result2[0]['daily_record'];
        totalAmount = result1;
      });
    } catch (error) {
      print(error);
    }
  }

  String extractDay(String day) {
    if (day.isNotEmpty) {
      String extractedDay = day.split('-')[2];
      return extractedDay.replaceFirst(RegExp(r'^0+'), '');
    }
    return '';
  }

  IconData whatIconIs(String recordCategory, String sign) {
    IconData result = const IconData(0xee80, fontFamily: 'MaterialIcons');
    if (sign == '+') {
      for (int i = 0; i < _addCategory.length; i++) {
        if (recordCategory == _addCategory[i].keys.first) {
          result = _addCategory[i].values.first;
          break;
        }
      }
    } else if (sign == '-') {
      for (int i = 0; i < _minusCategory.length; i++) {
        if (recordCategory == _minusCategory[i].keys.first) {
          result = _minusCategory[i].values.first;
          break;
        }
      }
      for (int i = 0; i < _fixedCategory.length; i++) {
        if (recordCategory == _fixedCategory[i].keys.first) {
          result = _fixedCategory[i].values.first;
          break;
        }
      }
      for (int i = 0; i < _specialCategory.length; i++) {
        if (recordCategory == _specialCategory[i].keys.first) {
          result = _specialCategory[i].values.first;
          break;
        }
      }
    } else if (sign == '') {
      return result;
    }

    return result;
  }

  Future<String> deleteRecord(int recordId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    String result = 'nothing';
    await supabase
        .from('daily_record')
        .delete()
        .eq('id', recordId)
        .eq('user_uuid', storedId.toString())
        .then((response) {
      result = 'success';
    }).catchError((error) {
      print("deleted error : $error");
      result = 'error';
    });
    return result;
  }

  // widget functions

  Widget getListExpenseTracker(context, dailyRecord) {
    int? amount;

    if (dailyRecord['amount'].toString().contains('-')) {
      amount = dailyRecord['amount'].abs();
    } else {
      amount = dailyRecord['amount'];
    }
    String formattedNumber = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
    String sign = (dailyRecord['amount'] != null && dailyRecord['amount'] > 0)
        ? '+'
        : (dailyRecord['amount'] != null && dailyRecord['amount'] < 0)
            ? '-'
            : '';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          whatIconIs(dailyRecord['category'].toString(), sign),
                          size: MediaQuery.of(context).size.width * 0.09,
                          // color: Colors.blue,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Text(
                          dailyRecord['category'],
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            fontWeight: FontWeight.w700,
                            color: Colors.black, // 텍스트 색상
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // 요소 간 간격
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          dailyRecord['date'].toString(),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600], // 회색 텍스트
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "$sign $formattedNumber 원",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.07,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue, // 금액 색상
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          dailyRecord['info'].toString(),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87, // 다크 그레이 텍스트
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // 버튼과 텍스트 간격
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            String result =
                                await deleteRecord(dailyRecord['id']);

                            if (result == 'success') {
                              return showDialog(
                                context: context,
                                barrierDismissible: true, // 모달 바깥을 클릭하면 닫히도록 설정
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.03),
                                      width: MediaQuery.of(context).size.width *
                                          0.06,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("삭제 되었습니다."),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: TextButton.styleFrom(
                                              textStyle: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            child: const Text('확인'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) {
                                Navigator.pop(context);
                                setState(() {
                                  final dateState = Provider.of<Datestate>(
                                      context,
                                      listen: false);
                                  initializeData(dateState.selectedDateTime);
                                });
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => const Home()),
                                // );
                              });
                            } else if (result == 'error') {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.03),
                                      width: MediaQuery.of(context).size.width *
                                          0.06,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      child: const Text('오류가 발생하였습니다.'),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.09,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  child: Icon(
                    whatIconIs(dailyRecord['category'].toString(), sign),
                    size: MediaQuery.of(context).size.width * 0.09,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.04,
                ),
                Text(
                  dailyRecord['category'].toString(),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$sign $formattedNumber 원',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressed(
      {required BuildContext context,
      String? locale,
      String? selectedDateTime}) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.parse(selectedDateTime.toString()),
      firstDate: DateTime(2019),
      lastDate: DateTime(2030),
      locale: localeObj,
    );

    if (selected != null) {
      weeks.clear();
      String yearMonthDay = formatDate(selected.toString());
      setState(() {
        context.read<Datestate>().chageSelectedDateTime(yearMonthDay);
      });
      await initializeData(yearMonthDay);
    }
  }

  String formatDate(String dateString) {
    DateTime? parsedDate = DateTime.parse(dateString);

    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final datestate = Provider.of<Datestate>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.01,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  bool isBack = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Dashboard()),
                                          ) ==
                                          null ??
                                      false;
                                  if (isBack) {
                                    initializeData(datestate.selectedDateTime);
                                  }
                                },
                                icon: Icon(
                                  space_dashboard_outlined,
                                  size: MediaQuery.of(context).size.width * 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: Text(
                                  '$nowMonth 월',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.08,
                                  ),
                                ),
                                onPressed: () async => _onPressed(
                                    context: context,
                                    locale: 'ko',
                                    selectedDateTime:
                                        datestate.selectedDateTime),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Day of week
              Flexible(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('일'),
                            Text('월'),
                            Text('화'),
                            Text('수'),
                            Text('목'),
                            Text('금'),
                            Text('토'),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                          child: PageView.builder(
                            controller:
                                _pageViewController, //_pageViewController,
                            itemCount: weeks.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, pageIndex) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: weeks[pageIndex].map((day) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        context
                                            .read<Datestate>()
                                            .chageSelectedDateTime(day);
                                      });
                                      getDailyRecords(
                                          datestate.selectedDateTime);
                                      getTotalAmountOfAday(
                                          datestate.selectedDateTime);
                                    },
                                    child: Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.10,
                                        child: Text(
                                          day.isNotEmpty ? extractDay(day) : '',
                                          style: TextStyle(
                                            color: extractDay(datestate
                                                        .selectedDateTime) ==
                                                    extractDay(day)
                                                ? Colors.indigo
                                                : Colors.black,
                                            fontWeight: extractDay(datestate
                                                        .selectedDateTime) ==
                                                    extractDay(day)
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            // fontSize: MediaQuery.of(context)
                                            //         .size
                                            //         .width *
                                            //     0.070,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.050,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Total price of a day
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: const Text(
                            '오늘',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.09,
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.01,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                Text(
                                  totalAmount,
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // List of Expense Tracker of today
              Flexible(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        ...dailyRecords.map(
                            (record) => getListExpenseTracker(context, record)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Add or Minus record button of expense_tracker
          Positioned(
            left: MediaQuery.of(context).size.width * 0.6,
            top: MediaQuery.of(context).size.height * 0.79,
            child: Row(
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddData(
                          selectedDateTime: datestate.selectedDateTime,
                        ),
                      ),
                    ),
                  },
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.09,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.015,
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MinusData(
                              selectedDateTime: datestate.selectedDateTime)),
                    ),
                  },
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.09,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
