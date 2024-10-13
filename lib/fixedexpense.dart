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
import 'package:pie_chart/pie_chart.dart';

/*
  month records
*/

class FixedExpense extends StatefulWidget {
  FixedExpense({
    super.key,
    this.whatRecordsIs,
    this.ratioOfTotalAmount,
  });

  final String? whatRecordsIs;
  Map<String, double>? ratioOfTotalAmount;

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
  double? heightFor;
  Map<String, double>? dataMap;
  final List<Map<String, IconData>> _addCategory = AddCategory().addIcons;
  final List<Map<String, IconData>> _minusCategory = MinusCategory().MinusIcons;

  @override
  void initState() {
    dataMap = widget.ratioOfTotalAmount;
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
        .select('id, date, amount, category, info')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or(categoryQuery)
        .then((recordAmounts) {
      print("recordAmounts : $recordAmounts");
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
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FixedExpense(
                                                    whatRecordsIs:
                                                        widget.whatRecordsIs,
                                                  ),
                                                ),
                                              );
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FixedExpense(
                                      whatRecordsIs: widget.whatRecordsIs,
                                    ),
                                  ),
                                );
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
                Icon(
                  whatIconIs(dailyRecord['category'].toString(), sign),
                  size: 23,
                ),
                Text(dailyRecord['category'].toString()),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Text(dailyRecord['date'].toString()),
              ],
            ),
            Text('- $formattedNumber 원'),
          ],
        ),
      ),
    );
  }

  Widget getCircleGraphExpenseWidget(context, dailyRecords) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        // alignment: AlignmentGeometry.lerp(a, b, t),
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PieChart(
              dataMap: dataMap!,
              animationDuration: const Duration(milliseconds: 800),
              //chartType: ChartType.ring, // 또는 ChartType.disc
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
              legendOptions: const LegendOptions(
                showLegends: true, // 범례 표시 여부
              ),
            ),
          ],
        ));
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
                height: widget.whatRecordsIs == 'totalAmount'
                    ? MediaQuery.of(context).size.height * 0.3
                    : MediaQuery.of(context).size.height * 0.7,
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
              if (widget.whatRecordsIs == 'totalAmount')
                getCircleGraphExpenseWidget(context, toalFixedAmountRecords)
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
