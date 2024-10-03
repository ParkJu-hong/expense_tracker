import 'package:expense_tracker/dashboard.dart';
import 'package:expense_tracker/datestate.dart';
import 'package:expense_tracker/fixeddata.dart';
import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/datacategorys.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/*
  month records
*/

class FixedExpense extends StatefulWidget {
  const FixedExpense({
    super.key,
    this.whatRecordsIs,
  });

  final String? whatRecordsIs;

  @override
  State<FixedExpense> createState() => _FixedExpenseState();
}

class _FixedExpenseState extends State<FixedExpense> {
  final supabase = Supabase.instance.client;
  final List<Map<String, IconData>> fixedIcons = FixedCategory().fixedIcons;
  String? selectedDateTime;
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;
  String? totalFixedAmount;
  List<Map<String, dynamic>> toalFixedAmountRecords = [];
  String recordsTypeTitle = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateState = Provider.of<Datestate>(context, listen: false);
      initializeData(dateState.selectedDateTime, widget.whatRecordsIs);
    });
  }

  Future<void> initializeData(
      String selectedDate, String? whatRecordsIs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');

    String categoryQuery = "";
    String recordsTypeTitleResult = "";

    selectedYear = selectedDate.split('-')[0];
    selectedMonth = selectedDate.split('-')[1];
    selectedDay = selectedDate.split('-')[2];
    DateTime startDate = DateTime.parse('$selectedYear-$selectedMonth-01');
    DateTime nextMonthStartDate =
        DateTime(startDate.year, startDate.month + 1, 1);

    if (whatRecordsIs == 'fixed') {
      categoryQuery =
          'category.eq.주거비,category.eq.공과금,category.eq.통신비,category.eq.저축,category.eq.보험';
      recordsTypeTitleResult = '고정지출';
    } else if (whatRecordsIs == 'income') {
      categoryQuery = 'category.eq.월급,category.eq.용돈,category.eq.기타';
      recordsTypeTitleResult = '수입';
    } else if (whatRecordsIs == 'living') {
      categoryQuery =
          'category.eq.식비,category.eq.생활용품,category.eq.교통우류비,category.eq.문화생활비,category.eq.의류미용비,category.eq.의료/건강';
      recordsTypeTitleResult = '생활비';
    } else if (whatRecordsIs == 'special') {
      categoryQuery = 'category.eq.특별지출,category.eq.경조비';
      recordsTypeTitleResult = '특별지출';
    } else if (whatRecordsIs == 'totalAmount') {
      categoryQuery =
          'category.eq.식비,category.eq.생활용품,category.eq.교통우류비,category.eq.문화생활비,category.eq.의류미용비,category.eq.의료/건강,category.eq.경조비,category.eq.기타,category.eq.특별지출,category.eq.주거비,category.eq.공과금,category.eq.통신비,category.eq.저축,category.eq.보험';
      recordsTypeTitleResult = '총 지출';
    }

    // fetch totalFixedAmount
    await supabase
        .from('daily_record')
        .select('amount, category')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or(categoryQuery)
        .then((recordAmounts) {
      int totalAmountResult = 0;
      if (recordAmounts.isNotEmpty) {
        for (var recordAmount in recordAmounts) {
          totalAmountResult += (recordAmount['amount'] ?? 0) as int;
        }
      }

      String formattedNumber = totalAmountResult.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
          );
      setState(() {
        totalFixedAmount = formattedNumber;
        toalFixedAmountRecords = recordAmounts;
        recordsTypeTitle = recordsTypeTitleResult;
      });
    }).catchError((error) {
      setState(() {
        totalFixedAmount = '0';
        toalFixedAmountRecords = [];
        recordsTypeTitle = recordsTypeTitleResult;
      });
      print(error);
    });
  }

  IconData whatIconIs(String recordCategory) {
    IconData result = const IconData(0xee80, fontFamily: 'MaterialIcons');
    for (int i = 0; i < fixedIcons.length; i++) {
      if (recordCategory == fixedIcons[i].keys.first) {
        result = fixedIcons[i].values.first;
        break;
      }
    }

    return result;
  }

  // widget functions

  Widget getListFixedExpenseWidget(context, dailyRecord) {
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

    return Container(
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
              Icon(
                whatIconIs(dailyRecord['category'].toString()),
                size: 23,
              ),
              Text(dailyRecord['category'].toString()),
            ],
          ),
          Text('- $formattedNumber 원'),
        ],
      ),
    );
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
                builder: (context) => const Dashboard(),
              ),
            );
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(recordsTypeTitle),
                    Text('$selectedYear년 $selectedMonth월'),
                    totalFixedAmount != null
                        ? Text('$totalFixedAmount 원')
                        : const CircularProgressIndicator(),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: ListView(
                  children: [
                    ...toalFixedAmountRecords.map(
                        (record) => getListFixedExpenseWidget(context, record)),
                  ],
                ),
              ),
            ],
          ),
          if (widget.whatRecordsIs == 'fixed')
            Positioned(
              left: MediaQuery.of(context).size.width * 0.65,
              top: MediaQuery.of(context).size.height * 0.75,
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
                            builder: (context) => FixedData(
                                  selectedDateTime: datestate.selectedDateTime,
                                  whatRecordIs: 'fixed',
                                )),
                      ),
                    },
                    child: const Text('고정 지출 추가'),
                  ),
                ],
              ),
            )
          else if (widget.whatRecordsIs == 'special')
            Positioned(
              left: MediaQuery.of(context).size.width * 0.65,
              top: MediaQuery.of(context).size.height * 0.75,
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
                            builder: (context) => FixedData(
                                  selectedDateTime: datestate.selectedDateTime,
                                  whatRecordIs: 'special',
                                )),
                      ),
                    },
                    child: const Text('특별 지출 추가'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
