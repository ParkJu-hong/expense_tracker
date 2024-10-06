import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io'; // For platform check (iOS/Android)

Future<String> createExcelFile(
    String seletedStartDate, String seletedEndDate) async {
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

  // String selectedYear = selectedDate.split('-')[0];
  // String selectedMonth = selectedDate.split('-')[1];

  // DateTime startDate = DateTime.parse('$selectedYear-$selectedMonth-01');
  // DateTime nextMonthStartDate =
  //     DateTime(startDate.year, startDate.month + 1, 1);

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
      .gte('date', seletedStartDate) // 시작일 (1일)
      .lt('date', seletedEndDate) // 다음 월의 첫날 이전
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
      .gte('date', seletedStartDate) // 시작일 (1일)
      .lt('date', seletedEndDate) // 다음 월의 첫날 이전.or(getLivingExQuery)
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
      .gte('date', seletedStartDate) // 시작일 (1일)
      .lt('date',
          seletedEndDate) // 다음 월의 첫날 이전.or('category.eq.주거비,category.eq.공과금,category.eq.통신비,category.eq.저축,category.eq.보험')
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
      .gte('date', seletedStartDate) // 시작일 (1일)
      .lt('date', seletedEndDate) // 다음 월의 첫날 이전
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
  return filePath;
}

Future<void> sendEmailWithAttachmentExcel(
    String filePath,
    String seletedStartDate,
    String seletedEndDate,
    BuildContext context) async {
  final Email email = Email(
    body: '$seletedStartDate ~ $seletedEndDate 의 가계부 엑셀 파일을 첨부합니다.',
    subject: '가계부 $seletedStartDate ~ $seletedEndDate 의 가계부 엑셀 데이터',
    recipients: ['bejejupark@gmail.com'], // 이메일 수신자
    attachmentPaths: [filePath], // 엑셀 파일 경로
    isHTML: false,
  );

  try {
    await FlutterEmailSender.send(email);
  } on PlatformException catch (e) {
    if (e.code == 'not_available') {
      // 이메일 클라이언트를 찾을 수 없을 때 사용자에게 안내 메시지 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('이메일 클라이언트 없음'),
          content: const Text(
              '기본 메일 앱을 사용할 수 없기 때문에 앱에서 바로 문의를 전송하기 어려운 상황입니다.\n\n아래 이메일로 연락주시면 친절하게 답변해드릴게요 :)\n\nbejejupark@gmail.com'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 다른 에러 처리
      print('Error: ${e.toString()}');
    }
  }
}

Future<void> sendEmailFeedback(BuildContext context) async {
  String body = await _getEmailBody();

  final Email email = Email(
    body: body,
    subject: '[가계뿌 문의]',
    recipients: ['bejejupark@gmail.com'], // 이메일 수신자
    attachmentPaths: [], // 엑셀 파일 경로
    isHTML: false,
  );

  try {
    await FlutterEmailSender.send(email);
  } on PlatformException catch (e) {
    if (e.code == 'not_available') {
      // 이메일 클라이언트를 찾을 수 없을 때 사용자에게 안내 메시지 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('이메일 클라이언트 없음'),
          content: const Text(
              '기본 메일 앱을 사용할 수 없기 때문에 앱에서 바로 문의를 전송하기 어려운 상황입니다.\n\n아래 이메일로 연락주시면 친절하게 답변해드릴게요 :)\n\nbejejupark@gmail.com'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 다른 에러 처리
      print('Error: ${e.toString()}');
    }
  }
}

Future<String> _getEmailBody() async {
  Map<String, dynamic> appInfo = await _getAppInfo();
  Map<String, dynamic> deviceInfo = await _getDeviceInfo();

  String body = "";

  body += "==============\n";
  body += "아래 내용을 함께 보내주시면 큰 도움이 됩니다 🧅\n";

  appInfo.forEach((key, value) {
    body += "$key: $value\n";
  });

  deviceInfo.forEach((key, value) {
    body += "$key: $value\n";
  });

  body += "==============\n";

  return body;
}

Future<Map<String, dynamic>> _getAppInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();

  return {
    "App Name": packageInfo.appName,
    "Package Name": packageInfo.packageName,
    "Version": packageInfo.version,
    "Build Number": packageInfo.buildNumber,
  };
}

Future<Map<String, dynamic>> _getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return {
      "Operating System": "Android",
      "Model": androidInfo.model,
      "Manufacturer": androidInfo.manufacturer,
      "Android Version": androidInfo.version.release,
      "SDK": androidInfo.version.sdkInt,
    };
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return {
      "Operating System": "iOS",
      "Model": iosInfo.utsname.machine,
      "System Version": iosInfo.systemVersion,
      "Name": iosInfo.name,
    };
  }

  return {
    "Operating System": "Unknown",
  };
}
