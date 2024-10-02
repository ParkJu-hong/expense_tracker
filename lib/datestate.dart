import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Datestate with ChangeNotifier {
  final int _count = 0;

  String selectedDateTime = DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get count => _count;

  void chageSelectedDateTime(selectedDate) {
    selectedDateTime = selectedDate;
    notifyListeners(); // 상태가 변경되면 리스너들에게 알림
  }
}
