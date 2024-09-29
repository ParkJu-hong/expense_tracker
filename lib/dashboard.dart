import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Initialize variables
  // static const IconData settings =
  //     IconData(0xe57f, fontFamily: 'MaterialIcons');
  static const IconData cancel_outlined =
      IconData(0xef28, fontFamily: 'MaterialIcons');
  // static const IconData arrow_right =
  //     IconData(0xe09e, fontFamily: 'MaterialIcons', matchTextDirection: true);
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
                      IconButton(
                          onPressed: () => {},
                          icon: Icon(
                            Icons.settings,
                            size: MediaQuery.of(context).size.width * 0.09,
                          )),
                      Text(
                        '9월',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05),
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
            ),
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
                      const Text(
                        '수입',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Text('38,000원'),
                          IconButton(
                            onPressed: () => {},
                            icon: Icon(
                              Icons.arrow_right,
                              size: MediaQuery.of(context).size.width * 0.09,
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
                      const Text(
                        '생활비',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Text('38,000원'),
                          IconButton(
                              onPressed: () => {},
                              icon: Icon(
                                Icons.arrow_right,
                                size: MediaQuery.of(context).size.width * 0.09,
                              )),
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
                      const Text(
                        '고정지출',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Text('38,000원'),
                          IconButton(
                              onPressed: () => {},
                              icon: Icon(
                                Icons.arrow_right,
                                size: MediaQuery.of(context).size.width * 0.09,
                              )),
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
                      const Text(
                        '특별지출',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Text('38,000원'),
                          IconButton(
                              onPressed: () => {},
                              icon: Icon(
                                Icons.arrow_right,
                                size: MediaQuery.of(context).size.width * 0.09,
                              )),
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
                      const Text(
                        '총 지출',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Text('38,000원'),
                          IconButton(
                            onPressed: () => {},
                            icon: Icon(
                              Icons.arrow_right,
                              size: MediaQuery.of(context).size.width * 0.09,
                            ),
                          ),
                        ],
                      ),
                    ],
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
