import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // Initialize variables
  static const IconData cancel_outlined =
      IconData(0xef28, fontFamily: 'MaterialIcons');

  // functions starts
  Widget getListSearched(context) => Container(
        width: MediaQuery.of(context).size.width * 0.991,
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: const Text('검색한 리스트'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.01,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Header
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
                      '검색',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.09,
                      ),
                    ),
                    IconButton(
                      onPressed: () => {Navigator.pop(context)},
                      icon: Icon(
                        cancel_outlined,
                        size: MediaQuery.of(context).size.width * 0.09,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // search bar
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '카테고리를 검색하세요',
                        prefixIcon: Icon(Icons.search), // 왼쪽에 아이콘 고정
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // 버튼을 눌렀을 때 실행될 코드
                          print('TextButton pressed!');
                        },
                        child: const Text('검색'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // List is searched
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: ListView(
                  children: List.generate(
                    6, // 반복 횟수
                    (index) => Row(
                      children: [getListSearched(context)],
                    ), // 각 항목을 생성하는 코드
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
