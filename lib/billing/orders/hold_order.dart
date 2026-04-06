import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../view_models/billing_provider.dart';
import '../../res/colors.dart';
import '../../res/components/k_text.dart';

class HoldBill extends StatefulWidget {
  const HoldBill({Key? key}) : super(key: key);

  @override
  State<HoldBill> createState() => _HoldBillState();
}

class _HoldBillState extends State<HoldBill> {
  int selectedRowIndex = -1;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Provider.of<BillingProvider>(context, listen: false)
        .loadHeldBillsFromPrefs();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// 🔥 Close page + give focus back to product search
  void _closeAndFocusProduct(BillingProvider provider) {
    Navigator.pop(context, true);

    // 🔥 IMPORTANT: delay after pop
    Future.delayed(const Duration(milliseconds: 100), () {
      provider.dropdownFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const MyText(
          text: 'Release Bills Details',
          color: AppColors.primary,
        ),
      ),

      // 🔥 Keyboard handling
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode..requestFocus(),
        onKey: (RawKeyEvent event) {
          if (event is! RawKeyDownEvent) return;

          // ✅ ESC → just go back (NO EXIT DIALOG)
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (Navigator.canPop(context)) {
              _closeAndFocusProduct(billingProvider);
            }
          }

          // ⬇ Arrow Down
          else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              if (selectedRowIndex <
                  billingProvider.heldOrders.length - 1) {
                selectedRowIndex++;
              }
            });
          }

          // ⬆ Arrow Up
          else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              if (selectedRowIndex > 0) {
                selectedRowIndex--;
              }
            });
          }

          // ⏎ ENTER → Release bill
          else if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (selectedRowIndex >= 0 &&
                selectedRowIndex < billingProvider.heldOrders.length) {
              billingProvider.releaseHeldBill(selectedRowIndex);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bill released to main billing screen'),
                  backgroundColor: Colors.green,
                ),
              );

              _closeAndFocusProduct(billingProvider);
            }
          }
        },

        child: billingProvider.heldOrders.isEmpty
            ? const Center(child: Text('No hold bills found'))
            : Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor:
                  WidgetStateProperty.all(Colors.grey.shade200),
                  dataRowColor:
                  MaterialStateProperty.resolveWith<Color?>(
                        (states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.shade100;
                      }
                      return null;
                    },
                  ),
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Bill No')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Bill Amount')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: List.generate(
                    billingProvider.heldOrders.length,
                        (index) {
                      final data =
                      billingProvider.heldOrders[index];

                      return DataRow(
                        selected: selectedRowIndex == index,
                        onSelectChanged: (_) async {
                          await billingProvider
                              .releaseHeldBill(index);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Bill released to main billing screen'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          _closeAndFocusProduct(billingProvider);
                        },
                        cells: [
                          DataCell(
                              Text(data.createdTs.toString())),
                          DataCell(Text(data.id.toString())),
                          DataCell(Text(
                            data.customerName.isEmpty
                                ? "-"
                                : data.customerName,
                          )),
                          DataCell(
                              Text("₹${data.orderGrandTotal}")),
                          DataCell(
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: const StadiumBorder(),
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 10),
                              ),
                              onPressed: () async {
                                await billingProvider
                                    .releaseHeldBill(index);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Bill released to main billing screen'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                _closeAndFocusProduct(
                                    billingProvider);
                              },
                              child: const Text(
                                "Release",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
