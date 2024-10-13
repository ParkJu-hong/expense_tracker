import 'package:expense_tracker/fixedexpense.dart';
import 'package:expense_tracker/home.dart';
import 'package:expense_tracker/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/datestate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  static const IconData cancel_outlined =
      IconData(0xef28, fontFamily: 'MaterialIcons');
  final storage = const FlutterSecureStorage();
  String? selectedDateTime;
  String? selectedYear;
  String? selectedMonth;
  String? selectedDay;
  String? incomeExpense;
  String? livingExpenses;
  String? fixedExpenses;
  String? specialExpenses;
  String? totalExpenses;
  String? remainingBudget;
  Map<String, double>? ratioOfTotalAmount = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateState = Provider.of<Datestate>(context, listen: false);
      initializeData(dateState.selectedDateTime);
    });
  }

  Future<void> initializeData(String selectedDate) async {
    setState(() {
      isLoading = true; // 데이터 로딩 시작
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    String? incomeExpenseResult;
    String? livingExpensesResult;
    String? fixedExpensesResult;
    String? specialExpensesResult;
    String? totalExpensesResult;

    int totalLivingAmountResult = 0;
    int totalFixedAmountResult = 0;
    int totalSpecialAmountResult = 0;
    int totalAmountResult = 0;
    int totalAmountResultTemp = 0;

    selectedYear = selectedDate.split('-')[0];
    selectedMonth = selectedDate.split('-')[1];
    selectedDay = selectedDate.split('-')[2];
    DateTime startDate = DateTime.parse('$selectedYear-$selectedMonth-01');
    DateTime nextMonthStartDate =
        DateTime(startDate.year, startDate.month + 1, 1);

    // 수입 Income
    await supabase
        .from('daily_record')
        .select('amount')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or('category.eq.월급,category.eq.용돈,category.eq.기타')
        .then((recordAmounts) {
      for (var recordAmount in recordAmounts) {
        totalAmountResult += (recordAmount['amount'] ?? 0) as int;
      }

      String formattedNumber = totalAmountResult.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match match) => '${match[1]},',
          );

      incomeExpenseResult = formattedNumber;
    }).catchError((error) {
      print(error);
    });

    // 생활비 Living expenses
    String getLivingExQuery =
        "category.eq.식비,category.eq.생활용품,category.eq.교통우류비,category.eq.문화생활비,category.eq.의류미용비,category.eq.의료/건강";
    await supabase
        .from('daily_record')
        .select('amount')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or(getLivingExQuery)
        .then((recordAmounts) {
      for (var recordAmount in recordAmounts) {
        totalLivingAmountResult += (recordAmount['amount'] ?? 0) as int;
      }

      String formattedNumber =
          totalLivingAmountResult.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (Match match) => '${match[1]},',
              );

      livingExpensesResult = formattedNumber;
    }).catchError((error) {
      print(error);
    });

    // 고정지출 Fixed expenses
    await supabase
        .from('daily_record')
        .select('amount, category')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or('category.eq.주거비,category.eq.공과금,category.eq.통신비,category.eq.저축,category.eq.보험')
        .then((recordAmounts) {
      if (recordAmounts.isNotEmpty) {
        for (var recordAmount in recordAmounts) {
          totalFixedAmountResult += (recordAmount['amount'] ?? 0) as int;
        }
      }

      String formattedNumber =
          totalFixedAmountResult.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (Match match) => '${match[1]},',
              );
      fixedExpensesResult = formattedNumber;
    }).catchError((error) {
      print(error);
    });

    // 특별지출 Special expenses
    await supabase
        .from('daily_record')
        .select('amount, category')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or('category.eq.특별지출,category.eq.경조비')
        .then((recordAmounts) {
      if (recordAmounts.isNotEmpty) {
        for (var recordAmount in recordAmounts) {
          totalSpecialAmountResult += (recordAmount['amount'] ?? 0) as int;
        }
      }

      String formattedNumber =
          totalSpecialAmountResult.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (Match match) => '${match[1]},',
              );
      specialExpensesResult = formattedNumber;
    }).catchError((error) {
      print(error);
    });

    // 총 지출 Total expenses
    String getTotalExQuery =
        "category.eq.식비,category.eq.생활용품,category.eq.교통우류비,category.eq.문화생활비,category.eq.의류미용비,category.eq.의료/건강,category.eq.경조비,category.eq.기타,category.eq.특별지출,category.eq.주거비,category.eq.공과금,category.eq.통신비,category.eq.저축,category.eq.보험";
    await supabase
        .from('daily_record')
        .select('amount')
        .eq('user_uuid', storedId.toString())
        .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
        .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
        .or(getTotalExQuery)
        .then((recordAmounts) {
      print("recordAmounts : $recordAmounts");
      for (var recordAmount in recordAmounts) {
        totalAmountResultTemp += (recordAmount['amount'] ?? 0) as int;
      }

      String formattedNumber =
          totalAmountResultTemp.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (Match match) => '${match[1]},',
              );

      totalExpensesResult = formattedNumber;
    }).catchError((error) {
      print(error);
    });

    String tempRemainingBudget =
        (totalAmountResult + totalAmountResultTemp).toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (Match match) => '${match[1]},',
            );

    setState(() {
      selectedDateTime = selectedDate;
      selectedYear = selectedDate.split('-')[0];
      selectedMonth = selectedDate.split('-')[1];
      selectedDay = selectedDate.split('-')[2];

      incomeExpense = incomeExpenseResult;
      livingExpenses = livingExpensesResult;
      specialExpenses = specialExpensesResult;
      fixedExpenses = fixedExpensesResult;
      totalExpenses = totalExpensesResult;
      remainingBudget = tempRemainingBudget;

      double forFixed = double.parse(totalFixedAmountResult.toString());
      double forLiving = double.parse(totalLivingAmountResult.toString());
      double forSpecial = double.parse(totalSpecialAmountResult.toString());

      if (forFixed != null && forLiving != null && forSpecial != null) {
        ratioOfTotalAmount!['고정지출'] = forFixed;
        ratioOfTotalAmount!['생활비'] = forLiving;
        ratioOfTotalAmount!['특별지출'] = forSpecial;
      }

      isLoading = false; // 데이터 로딩 완료
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          },
        ),
        title: Text(
          '$selectedMonth 월',
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.08,
          ),
        ),
        centerTitle: true, // 타이틀을 가운데에 정렬
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Setting(),
                ),
              ),
            },
            icon: Icon(
              Icons.settings,
              size: MediaQuery.of(context).size.width * 0.09,
            ),
          ),
        ],
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  // money incomed
                  Expanded(
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
                            Text(
                              '수입',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$incomeExpense 원',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FixedExpense(
                                          whatRecordsIs: 'income',
                                        ),
                                      ),
                                    ),
                                  },
                                  icon: Icon(
                                    Icons.arrow_right,
                                    size: MediaQuery.of(context).size.width *
                                        0.12,
                                    weight: MediaQuery.of(context).size.width *
                                        0.08,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // cost of living
                  Expanded(
                    flex: 2,
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
                            Text(
                              '생활비',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$livingExpenses 원',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FixedExpense(
                                          whatRecordsIs: 'living',
                                        ),
                                      ),
                                    ),
                                  },
                                  icon: Icon(
                                    Icons.arrow_right,
                                    size: MediaQuery.of(context).size.width *
                                        0.12,
                                    weight: MediaQuery.of(context).size.width *
                                        0.08,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // fixed expenses
                  Expanded(
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
                            Text(
                              '고정지출',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$fixedExpenses 원',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FixedExpense(
                                          whatRecordsIs: 'fixed',
                                        ),
                                      ),
                                    ),
                                  },
                                  icon: Icon(
                                    Icons.arrow_right,
                                    size: MediaQuery.of(context).size.width *
                                        0.12,
                                    weight: MediaQuery.of(context).size.width *
                                        0.08,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // special expenditure
                  Expanded(
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
                            Text(
                              '특별지출',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$specialExpenses 원',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FixedExpense(
                                          whatRecordsIs: 'special',
                                          ratioOfTotalAmount:
                                              ratioOfTotalAmount,
                                        ),
                                      ),
                                    ),
                                  },
                                  icon: Icon(
                                    Icons.arrow_right,
                                    size: MediaQuery.of(context).size.width *
                                        0.12,
                                    weight: MediaQuery.of(context).size.width *
                                        0.08,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // total cost
                  Expanded(
                    flex: 2,
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
                            Text(
                              '총 지출',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$totalExpenses 원',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FixedExpense(
                                          whatRecordsIs: 'totalAmount',
                                          ratioOfTotalAmount:
                                              ratioOfTotalAmount,
                                        ),
                                      ),
                                    ),
                                  },
                                  icon: Icon(
                                    Icons.arrow_right,
                                    size: MediaQuery.of(context).size.width *
                                        0.12,
                                    weight: MediaQuery.of(context).size.width *
                                        0.08,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // total cost
                  Expanded(
                    flex: 2,
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
                            Text(
                              '남은 예산',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$remainingBudget 원',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.06,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
