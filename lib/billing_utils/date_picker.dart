// import 'package:flutter/material.dart';
// import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
// import 'package:flutter_date_pickers/flutter_date_pickers.dart';
//
// class ModernRangePicker extends StatefulWidget {
//   @override
//   _ModernRangePickerState createState() => _ModernRangePickerState();
// }
//
// class _ModernRangePickerState extends State<ModernRangePicker> {
//   DatePeriod? selectedRange;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         height: 300,
//         width: 300,
//         child: Card(
//           color: const Color(0xffFFFCF9),
//           elevation: 5,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: dp.RangePicker(
//             selectedPeriod: selectedRange ??
//                 dp.DatePeriod(DateTime.now().subtract(Duration(days: 7)), DateTime.now()),
//             onChanged: (range) => setState(() => selectedRange = range),
//             firstDate: DateTime(2023),
//             lastDate: DateTime.now(),
//             datePickerStyles: dp.DatePickerRangeStyles(
//               selectedPeriodStartDecoration: BoxDecoration(
//                 color: Colors.deepPurple,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               selectedPeriodLastDecoration: BoxDecoration(
//                 color: Colors.deepPurple,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               selectedPeriodMiddleDecoration: BoxDecoration(
//                 color: Colors.deepPurple.withOpacity(0.3),
//                 shape: BoxShape.rectangle,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
