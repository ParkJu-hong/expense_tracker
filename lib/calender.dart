import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  // Initialize variables
  static const IconData arrow_drop_down =
      IconData(0xe098, fontFamily: 'MaterialIcons');

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final ScrollController _scrollController = ScrollController();
  double _calendarHeight = 350;
  final double _maxCalendarHeight = 350;
  final double _minCalendarHeight = 0;

  // functions starts
  @override
  void initState() {
    super.initState();
    initializeDateFormatting().then((_) {
      _scrollController.addListener(() {
        double scrollOffset = _scrollController.position.pixels;
        setState(() {
          _calendarHeight = (_maxCalendarHeight - scrollOffset)
              .clamp(_minCalendarHeight, _maxCalendarHeight);
        });
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
          // Calender widget
          SizedBox(
            height: _calendarHeight,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedTextStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  color: Colors.white,
                ),
                todayTextStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                  color: Colors.white,
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarFormat: CalendarFormat.month,
              locale: 'ko_KR',
            ),
          ),
          // scroll widget
          Expanded(
            child: Container(
              color: Colors.amber,
              child: Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return const Icon(arrow_drop_down);
                    else
                      return ListTile(
                        title: Text('항목 $index'),
                        subtitle: const Text('이곳은 스크롤 가능한 영역입니다.'),
                      );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
