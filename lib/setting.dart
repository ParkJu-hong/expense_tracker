import 'package:expense_tracker/dashboard.dart';
import 'package:expense_tracker/home.dart';
import 'package:expense_tracker/resetdata.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/createexcelfile.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  String seletedStartDate = '';
  String seletedEndDate = '';

  String formatDate(String dateString) {
    DateTime? parsedDate = DateTime.parse(dateString);

    return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      _range = '${DateFormat('yyyy/MM/dd').format(args.value.startDate)} -'
          // ignore: lines_longer_than_80_chars
          ' ${DateFormat('yyyy/MM/dd').format(args.value.endDate ?? args.value.startDate)}';
    } else if (args.value is DateTime) {
      _selectedDate = args.value.toString();
    } else if (args.value is List<DateTime>) {
      _dateCount = args.value.length.toString();
    } else {
      _rangeCount = args.value.length.toString();
    }

    setState(() {
      seletedStartDate = formatDateRange(_range)[0];
      seletedStartDate = formatDateRange(_range)[1];
    });
  }

  List<String> formatDateRange(String dateRange) {
    // 슬래시와 공백을 기준으로 문자열을 분리
    List<String> dates = dateRange.split(' - ');

    // 각 날짜를 '/'를 '-'로 변환
    String startDate = dates[0].replaceAll('/', '-');
    String endDate = dates[1].replaceAll('/', '-');

    return [startDate, endDate];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return Future.value(true); // Pop 처리가 되었음을 나타냄
        }
        return Future.value(false); // Pop이 발생하지 않았을 때
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Text(
              '환경설정',
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width * 0.09),
            ),
          ],
          toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
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
                        '전체 데이터 초기화',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetData(),
                                ),
                              ),
                            },
                            icon: Icon(
                              Icons.arrow_right,
                              size: MediaQuery.of(context).size.width * 0.12,
                              weight: MediaQuery.of(context).size.width * 0.08,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: SizedBox(
                              height: 300,
                              width: 300,
                              child: SfDateRangePicker(
                                onSelectionChanged: _onSelectionChanged,
                                selectionMode:
                                    DateRangePickerSelectionMode.range,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  String filePath = await createExcelFile(
                                      seletedStartDate, seletedEndDate);
                                  await sendEmailWithAttachmentExcel(
                                      filePath,
                                      seletedStartDate,
                                      seletedEndDate,
                                      context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('엑셀 파일이 메일로 전송되었습니다.')),
                                  );
                                },
                                child: const Text('확인'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('취소'),
                              ),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Export excel with Email",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Icon(
                              Icons.arrow_right,
                              size: MediaQuery.of(context).size.width * 0.12,
                              weight: MediaQuery.of(context).size.width * 0.08,
                            )
                          ],
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await sendEmailFeedback(context);
                          // Optionally, you can show a confirmation message after sending feedback.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('피드백이 전송되었습니다. 감사합니다!')),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "피드백",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Icon(
                              Icons.arrow_right,
                              size: MediaQuery.of(context).size.width * 0.12,
                              weight: MediaQuery.of(context).size.width * 0.08,
                            )
                          ],
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
    );
  }
}
