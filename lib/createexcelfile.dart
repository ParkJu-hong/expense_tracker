import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void createExcelFile(String selectedDate) async {
  // 엑셀 문서 생성
  final xlsio.Workbook workbook = xlsio.Workbook();
  final xlsio.Worksheet sheet = workbook.worksheets[0];

  // 열 너비 설정 (칼럼 너비)
  sheet.getRangeByName('A1').columnWidth = 15; // 날짜
  sheet.getRangeByName('B1').columnWidth = 20; // 카테고리
  sheet.getRangeByName('C1').columnWidth = 30; // 정보
  sheet.getRangeByName('D1').columnWidth = 15; // 금액

  // 헤더 추가
  sheet.getRangeByName('A1').setText('날짜');
  sheet.getRangeByName('B1').setText('카테고리');
  sheet.getRangeByName('C1').setText('정보');
  sheet.getRangeByName('D1').setText('금액');

  // fetch starts
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedId = prefs.getString('uuid');
  final supabase = Supabase.instance.client;

  String selectedYear = selectedDate.split('-')[0];
  String selectedMonth = selectedDate.split('-')[1];

  DateTime startDate = DateTime.parse('$selectedYear-$selectedMonth-01');
  DateTime nextMonthStartDate =
      DateTime(startDate.year, startDate.month + 1, 1);

  // 샘플 데이터
  List<Map<String, dynamic>>? incomeData = [];

  List<Map<String, dynamic>>? expenseData = [];

  List<Map<String, dynamic>>? fixedExpenseData = [];

  List<Map<String, dynamic>>? specialExpenseData = [];

  // 수입 Income
  await supabase
      .from('daily_record')
      .select('amount, category, info, date')
      .eq('user_uuid', storedId.toString())
      .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
      .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
      .or('category.eq.월급,category.eq.용돈,category.eq.기타')
      .then((recordAmounts) {
    incomeData = recordAmounts;
  }).catchError((error) {
    print(error);
  });

  // 생활비 Living expenses
  String getLivingExQuery =
      "category.eq.식비,category.eq.생활용품,category.eq.교통우류비,category.eq.문화생활비,category.eq.의류미용비,category.eq.의료/건강";
  await supabase
      .from('daily_record')
      .select('amount, category, info, date')
      .eq('user_uuid', storedId.toString())
      .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
      .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
      .or(getLivingExQuery)
      .then((recordAmounts) {
    expenseData = recordAmounts;
  }).catchError((error) {
    print(error);
  });

  // 고정지출 Fixed expenses
  await supabase
      .from('daily_record')
      .select('amount, category, info, date')
      .eq('user_uuid', storedId.toString())
      .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
      .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
      .or('category.eq.주거비,category.eq.공과금,category.eq.통신비,category.eq.저축,category.eq.보험')
      .then((recordAmounts) {
    fixedExpenseData = recordAmounts;
  }).catchError((error) {
    print(error);
  });

  // 특별지출 Special expenses
  await supabase
      .from('daily_record')
      .select('amount, category, info, date')
      .eq('user_uuid', storedId.toString())
      .gte('date', '$selectedYear-$selectedMonth-01') // 시작일 (1일)
      .lt('date', nextMonthStartDate.toIso8601String()) // 다음 월의 첫날 이전
      .or('category.eq.특별지출,category.eq.경조비')
      .then((recordAmounts) {
    specialExpenseData = recordAmounts;
  }).catchError((error) {
    print(error);
  });

  // fetch ends

  // 데이터를 엑셀에 추가
  int row = 2; // 첫번째 데이터 행
  List<Map<String, dynamic>> allData = [
    ...?incomeData,
    ...?expenseData,
    ...?fixedExpenseData,
    ...?specialExpenseData,
  ];

  print("allData test");
  print(allData);

  for (var data in allData) {
    sheet.getRangeByIndex(row, 1).setText(data['date']); // 날짜
    sheet.getRangeByIndex(row, 2).setText(data['category']); // 카테고리
    sheet.getRangeByIndex(row, 3).setText(data['info']); // 정보
    sheet
        .getRangeByIndex(row, 4)
        .setNumber(data['amount'].toDouble()); // 금액을 double로 변환
    row++;
  }

  // 스타일 지정 (헤더)
  final xlsio.Style headerStyle = workbook.styles.add('HeaderStyle');
  headerStyle.backColor = '#4CAF50'; // 배경색
  headerStyle.bold = true; // 굵은 글씨
  headerStyle.fontColor = '#FFFFFF'; // 글자색
  headerStyle.hAlign = xlsio.HAlignType.center;

  sheet.getRangeByName('A1:D1').cellStyle = headerStyle;
  // 파일 저장 경로 설정
  Directory? directory;

  // 문서 디렉토리 가져오기 (iOS 및 Android)
  directory = await getApplicationDocumentsDirectory();
  print("directory test : $directory");

  // 파일 경로 설정
  String filePath = '${directory.path}/output.xlsx';

  // 파일 저장
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);

  print('엑셀 파일이 저장되었습니다: $filePath');

  /* PC
  // 파일 저장 경로 설정 (바탕화면)
  Directory? directory;

  if (Platform.isWindows) {
    final userName = Platform.environment['USERPROFILE'];
    directory = Directory('C:\\Users\\$userName\\Desktop');
  } else if (Platform.isMacOS) {
    final userName = Platform.environment['USER'];
    directory = Directory('/Users/$userName/Desktop');
  } else if (Platform.isLinux) {
    final userName = Platform.environment['USER'];
    directory = Directory('/home/$userName/Desktop');
  }
  final userName = Platform.environment['USER'];
  print("userName test : $userName");
  directory = Directory('/Users/bagjuhong/Desktop');
  print("directory test : $directory");

  // 파일을 저장할 경로를 설정합니다 (예: 데스크탑).
  String filePath = '${directory.path}/output.xlsx';

  // 파일 저장
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  // 파일 쓰기
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);

  print('엑셀 파일이 저장되었습니다: $filePath');
  */
}
