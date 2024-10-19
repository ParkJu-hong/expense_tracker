import 'package:expense_tracker/setting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetData extends StatefulWidget {
  const ResetData({super.key});

  @override
  State<ResetData> createState() => _ResetDataState();
}

class _ResetDataState extends State<ResetData> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> deleteDataByUuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('uuid');
    final supabase = Supabase.instance.client;

    try {
      await supabase
          .from('daily_record')
          .delete()
          .eq('user_uuid', storedId.toString());

      // 성공적으로 삭제한 경우 처리 (알림 등 추가 가능)
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
      ),
      body: Container(
        alignment: Alignment.center,
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
        child: TextButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('정말 모든 데이터를 초기화 하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    await deleteDataByUuid(); // 데이터를 삭제하고
                    Navigator.pop(context);
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => const Setting(),
                    //     ));
                  },
                  child: const Text('삭제합니다.'),
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
          child: Column(
            children: [
              Icon(
                Icons.delete_forever_outlined,
                size: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text("데이터 초기화"),
            ],
          ),
        ),
      ),
    );
  }
}
