import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    getDate();
    foundScorllIndex = foundIndex(DateTime.now().day);
    super.initState();
  }

  // Initialize variables
  static const IconData space_dashboard_outlined =
      IconData(0xf3bd, fontFamily: 'MaterialIcons');
  static const IconData cancel_outlined =
      IconData(0xef28, fontFamily: 'MaterialIcons');
  List<Map<int, String>> dayOfTheWeek = [];
  static const IconData money_outlined =
      IconData(0xf1e0, fontFamily: 'MaterialIcons');
  List<String> currentWeek = [];
  List<List<String>> weeks = [];
  int today = DateTime.now().day;
  int foundScorllIndex = 0;
  Widget listExpenseTracker = Container(
    margin: const EdgeInsets.only(top: 20),
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
                size: 38,
              ),
            ),
            const Text('용돈'),
          ],
        ),
        const Text('+ 50,000 원'),
      ],
    ),
  );

  // functions start
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

    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int daysInMonth = lastDayOfMonth.day;
    List<DateTime> daysOfMonth = [];

    for (int i = 0; i < daysInMonth; i++) {
      daysOfMonth.add(DateTime(now.year, now.month, i + 1));
    }

    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    int firstWeekday = firstDayOfMonth.weekday;

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
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: const Icon(
                            space_dashboard_outlined,
                            size: 38,
                          ),
                        ),
                        const Text('9월'),
                        Container(
                          child: const Icon(
                            cancel_outlined,
                            size: 38,
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
                          height: 100,
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
                                            fontSize: 50,
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
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(10),
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
                                    fontSize: 20,
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
                                    fontSize: 20,
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
                                      size: 38,
                                    ),
                                  ),
                                  const Text('용돈'),
                                ],
                              ),
                              const Text('+ 50,000 원'),
                            ],
                          ),
                        ),
                        for (int i = 0; i < 5; i++) listExpenseTracker,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.75,
            top: MediaQuery.of(context).size.height * 0.9,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Text('+'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Text('-'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
