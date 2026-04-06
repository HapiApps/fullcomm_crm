// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/place_order.dart';
// import '../../res/colors.dart';
// import '../../res/components/esc_wrapper.dart';
// import '../../res/components/k_text.dart';
// import '../../view_models/billing_provider.dart';
//
// class HoldBillsScreen extends StatefulWidget {
//   @override
//   State<HoldBillsScreen> createState() => _HoldBillsScreenState();
// }
//
// class _HoldBillsScreenState extends State<HoldBillsScreen> {
//   int selectedIndex = 0;
//
//   final FocusNode _keyboardFocus = FocusNode(); // FIX 1: Persistent focus node
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// Automatically request focus so keyboard works immediately
//     Future.delayed(Duration(milliseconds: 200), () {
//       if (mounted) _keyboardFocus.requestFocus();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final billingProvider = Provider.of<BillingProvider>(context);
//
//     return EscBackWrapper(
//       child: RawKeyboardListener(     // FIX 2: Move listener OUTSIDE Scaffold
//         autofocus: true,
//         focusNode: _keyboardFocus,
//
//         onKey: (RawKeyEvent event) {
//           if (event is RawKeyDownEvent) {
//             // ESC → let EscBackWrapper handle it
//             if (event.logicalKey == LogicalKeyboardKey.escape) return;
//
//             // ARROW DOWN
//             if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//               setState(() {
//                 if (selectedIndex < billingProvider.heldOrders.length - 1) {
//                   selectedIndex++;
//                 }
//               });
//             }
//
//             // ARROW UP
//             if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//               setState(() {
//                 if (selectedIndex > 0) selectedIndex--;
//               });
//             }
//
//             // ENTER → Release selected bill
//             if (event.logicalKey == LogicalKeyboardKey.enter) {
//               final data = billingProvider.heldOrders[selectedIndex];
//               _releaseBill(context, selectedIndex, data);
//             }
//           }
//         },
//
//         child: Scaffold(
//           appBar: AppBar(
//             title: const MyText(
//               text: 'Release Bills Details',
//               color: AppColors.primary,
//             ),
//           ),
//
//           body: billingProvider.heldOrders.isEmpty
//               ? const Center(child: Text('No hold bills found'))
//               : Padding(
//             padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                       minWidth: MediaQuery.of(context).size.width),
//                   child: DataTable(
//                     showCheckboxColumn: false,
//                     headingRowColor:
//                     MaterialStateProperty.all(Colors.grey.shade200),
//                     columnSpacing: 30,
//
//                     columns: const [
//                       DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(label: Text('Bill No', style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(label: Text('Bill Amount', style: TextStyle(fontWeight: FontWeight.bold))),
//                       DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
//                     ],
//
//                     rows: List.generate(
//                       billingProvider.heldOrders.length,
//                           (index) {
//                         final data = billingProvider.heldOrders[index];
//                         final isSelected = selectedIndex == index;
//
//                         return DataRow(
//                           color: MaterialStateProperty.all(
//                             isSelected ? Colors.blue.shade100 : Colors.white,
//                           ),
//
//                           onSelectChanged: (_) {
//                             setState(() => selectedIndex = index);
//                             print("DEBUG products1 = ${data.products}");
//                             print("DEBUG count1 = ${data.products?.length}");
//                             _showBillDetails(context, data);
//                           },
//
//                           cells: [
//                             DataCell(Text(data.createdTs.toString())),
//                             DataCell(Text(data.id.toString())),
//                             DataCell(Text(data.customerName.isEmpty ? "-" : data.customerName)),
//                             DataCell(Text("₹${data.orderGrandTotal}")),
//                             DataCell(
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primary,
//                                   shape: const StadiumBorder(),
//                                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                                 ),
//                                 onPressed: () =>
//                                     _releaseBill(context, index, data),
//                                 child: const Text("Release",
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12)),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ------------ FUNCTIONS ----------------
//
//   void _showBillDetails(BuildContext context, Order order) {
//     print("DEBUG products = ${order.products}");
//     print("DEBUG count = ${order.products?.length}");
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Products"),
//         content: SizedBox(
//           width: 700,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: MyText(text: "Product", color: Colors.black, fontWeight: FontWeight.bold)),
//                   DataColumn(label: MyText(text: "Qty", color: Colors.black, fontWeight: FontWeight.bold)),
//                   DataColumn(label: MyText(text: "Price", color: Colors.black, fontWeight: FontWeight.bold)),
//                 ],
//                 rows: List.generate(order.products.length, (i) {
//                   final item = order.products[i];
//
//                   return DataRow(
//                     cells: [
//                       DataCell(Text(item.product.pTitle ?? '')),
//
//                       DataCell(Text(
//                         (item.variation ?? item.quantity ?? 0).toString(),
//                       )),
//
//                       DataCell(Text("₹${item.calculateSubtotal()}")),
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _releaseBill(BuildContext context, int index, dynamic data) async {
//     final billingProvider = Provider.of<BillingProvider>(context, listen: false);
//
//     await billingProvider.releaseHeldBill(index);
//
//     Navigator.pop(context, true);
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Bill released to main billing screen'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
// }
