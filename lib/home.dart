import 'package:expense_tracker/adddata.dart';
import 'package:expense_tracker/calender.dart';
import 'package:expense_tracker/minusdata.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/dashboard.dart';
import 'package:expense_tracker/search.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState(); // super.initState()를 첫 번째 줄에 위치시킴
    getDate();
    // getDeviceInfo();
    foundScorllIndex = foundIndex(DateTime.now().day);
  }

  // Initialize variables
  static const IconData space_dashboard_outlined =
      IconData(0xf3bd, fontFamily: 'MaterialIcons');
  static const IconData money_outlined =
      IconData(0xf1e0, fontFamily: 'MaterialIcons');
  static const IconData calendar_month =
      IconData(0xf06bb, fontFamily: 'MaterialIcons');
  static const IconData search = IconData(0xe567, fontFamily: 'MaterialIcons');
  List<Map<int, String>> dayOfTheWeek = [];
  List<String> currentWeek = [];
  List<List<String>> weeks = [];
  int today = DateTime.now().day;
  int foundScorllIndex = 0;

  // functions start

  /*
  Future<void> getDeviceInfo() async {
    BaseDeviceInfo webBrowserInfo = await deviceInfo.deviceInfo;
    print('test');
    print(webBrowserInfo.data);
  }
  */

  List<String> setDate(List<Map<int, String>> dayOfTheWeek) {
    List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    DateTime now = DateTime.now();
    int currentDay = now.day;

    String firstDayOfMonth = dayOfTheWeek.first.values.first;

    List<String> firstWeek = [];
    int startIndex = weekDays.indexOf(firstDayOfMonth);

    for (int i = 0; i < startIndex; i++) {
      firstWeek.add('');
    }

    for (int i = 0; i < 7 - startIndex; i++) {
      firstWeek.add((i + 1).toString());
    }
    weeks.add(firstWeek);

    for (int i = 7 - startIndex; i < dayOfTheWeek.length; i += 7) {
      List<String> week = [];
      for (int j = i; j < i + 7 && j < dayOfTheWeek.length; j++) {
        week.add((j + 1).toString());
      }

      if (week.length < 7) {
        for (int k = week.length; k < 7; k++) {
          week.add('');
        }
      }
      weeks.add(week);
    }

    List<String> currentWeek = [];
    for (var week in weeks) {
      if (week.contains(currentDay.toString())) {
        currentWeek = week;
        break;
      }
    }

    return currentWeek;
  }

  void getDate() {
    DateTime now = DateTime.now();

    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int daysInMonth = lastDayOfMonth.day;
    List<DateTime> daysOfMonth = [];

    for (int i = 0; i < daysInMonth; i++) {
      daysOfMonth.add(DateTime(now.year, now.month, i + 1));
    }

    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<Map<int, String>> result = [];

    for (var day in daysOfMonth) {
      result.add({day.day: weekdays[day.weekday - 1]});
    }

    currentWeek = setDate(result);
  }

  int foundIndex(
    target,
  ) {
    int foundIndex = -1;

    for (int i = 0; i < weeks.length; i++) {
      if (weeks[i].contains(target.toString())) {
        foundIndex = i;
        break;
      }
    }

    return foundIndex;
  }

  Widget getListExpenseTracker(context) {
    return Container(
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
                child: const Icon(
                  money_outlined,
                  size: 23,
                ),
              ),
              const Text('용돈'),
            ],
          ),
          const Text('+ 50,000 원'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: IconButton(
                              onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Dashboard()),
                                    )
                                  },
                              icon: Icon(
                                space_dashboard_outlined,
                                size: MediaQuery.of(context).size.width * 0.09,
                              )),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '9월',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Search()),
                                  )
                                },
                                icon: Icon(
                                  search,
                                  size:
                                      MediaQuery.of(context).size.width * 0.09,
                                ),
                              ),
                              IconButton(
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Calender()),
                                  )
                                },
                                icon: Icon(
                                  calendar_month,
                                  size:
                                      MediaQuery.of(context).size.width * 0.09,
                                ),
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
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: PageView.builder(
                            controller: PageController(
                              initialPage: foundScorllIndex,
                            ),
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
                                        today = int.parse(day);
                                      });
                                    },
                                    child: Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.10,
                                        child: Text(
                                          day.isNotEmpty ? day : '',
                                          style: TextStyle(
                                            color: day == today.toString()
                                                ? Colors.redAccent
                                                : Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.070,
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
                          padding: const EdgeInsets.all(8),
                          child: Container(
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
                                const Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                const Text(
                                  '38,000',
                                  style: TextStyle(
                                    fontSize: 15,
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
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
                                    child: const Icon(
                                      money_outlined,
                                      size: 23,
                                    ),
                                  ),
                                  const Text('용돈'),
                                ],
                              ),
                              const Text('+ 50,000 원'),
                            ],
                          ),
                        ),
                        for (int i = 0; i < 5; i++)
                          getListExpenseTracker(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Add or Minus record button of expense_tracker
          Positioned(
            left: MediaQuery.of(context).size.width * 0.75,
            top: MediaQuery.of(context).size.height * 0.9,
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
                      MaterialPageRoute(builder: (context) => const AddData()),
                    ),
                  },
                  child: const Text('+'),
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
                          builder: (context) => const MinusData()),
                    ),
                  },
                  child: const Text('-'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
