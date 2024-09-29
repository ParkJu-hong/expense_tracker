import 'package:expense_tracker/home.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/minuscategory.dart';
import 'package:intl/intl.dart';

class MinusData extends StatefulWidget {
  const MinusData({super.key});

  @override
  State<MinusData> createState() => _MinusDataState();
}

class _MinusDataState extends State<MinusData> {
  final List<Map<String, IconData>> minusCategory = MinusCategory().MinusIcons;
  final TextEditingController _controller = TextEditingController();
  int selectedIconIndex = 0;
  int iconIndex = 4;

  String formatNumber(String s) {
    if (s.isEmpty) return '';
    final number = int.parse(s);
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final text = _controller.text;
      _controller.value = _controller.value.copyWith(
        text: formatNumber(text.replaceAll(',', '')), // 콤마 제거 후 다시 포맷
        selection: TextSelection.collapsed(
          offset: formatNumber(text.replaceAll(',', '')).length,
        ),
      );
    });
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              textAlign: TextAlign.right,
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ex) 10,000',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 0; i <= 2; i++)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedIconIndex == i
                              ? Colors.amber
                              : Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => {
                          setState(() {
                            selectedIconIndex = i;
                          })
                        },
                        child: Column(
                          children: [
                            Icon(minusCategory[i].values.first),
                            Text(minusCategory[i].keys.first),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '내역',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                    onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          ),
                        },
                    child: const Text('완료'))
              ],
            ),
          )
        ],
      ),
    );
  }
}
