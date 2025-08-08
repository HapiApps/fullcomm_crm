import 'package:flutter/material.dart';

void main() {
  runApp(const MyAppS());
}

class MyAppS extends StatelessWidget {
  const MyAppS({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScrollableTable(),
    );
  }
}

class ScrollableTable extends StatefulWidget {
  const ScrollableTable({super.key});

  @override
  State<ScrollableTable> createState() => _ScrollableTableState();
}

class _ScrollableTableState extends State<ScrollableTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  final List<Map<String, dynamic>> sampleData = List.generate(50, (index) {
    return {
      "name": "Name $index",
      "mobile": "99999$index",
      "city": "City $index",
      "company": "Company $index",
      "source": "Source $index",
      "action": "Action $index",
      "added": "Date $index",
      "rating": "⭐️",
      "expected": "Exp Date $index",
      "enrolled": "Enroll $index"
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fixed Header Scrollable Table")),
      body: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1200),
            child: Column(
              children: [
                /// 🟩 Header Table
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(3),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(2),
                    6: FlexColumnWidth(2),
                    7: FlexColumnWidth(2),
                    8: FlexColumnWidth(3),
                    9: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEEFF1),
                      ),
                      children: const [
                        TableCellHeader("Name"),
                        TableCellHeader("Mobile No."),
                        TableCellHeader("City"),
                        TableCellHeader("Company"),
                        TableCellHeader("Source"),
                        TableCellHeader("Action"),
                        TableCellHeader("Added"),
                        TableCellHeader("Rating"),
                        TableCellHeader("Expected Date"),
                        TableCellHeader("Enrolled Date"),
                      ],
                    )
                  ],
                ),

                // Add a SizedBox or Expanded around ListView
                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _verticalController,
                      itemCount: sampleData.length,
                      itemBuilder: (context, index) {
                        final row = sampleData[index];
                        return SizedBox(
                          width: 1200,
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(3),
                              4: FlexColumnWidth(2),
                              5: FlexColumnWidth(2),
                              6: FlexColumnWidth(2),
                              7: FlexColumnWidth(2),
                              8: FlexColumnWidth(3),
                              9: FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? Colors.white
                                      : const Color(0xFFF5F5F5),
                                ),
                                children: [
                                  TableCellText(row["name"]),
                                  TableCellText(row["mobile"]),
                                  TableCellText(row["city"]),
                                  TableCellText(row["company"]),
                                  TableCellText(row["source"]),
                                  TableCellText(row["action"]),
                                  TableCellText(row["added"]),
                                  TableCellText(row["rating"]),
                                  TableCellText(row["expected"]),
                                  TableCellText(row["enrolled"]),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header widget
class TableCellHeader extends StatelessWidget {
  final String text;
  const TableCellHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }
}

/// Row cell widget
class TableCellText extends StatelessWidget {
  final String text;
  const TableCellText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
