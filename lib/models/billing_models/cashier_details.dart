import 'cashier_amount.dart';

class CashierAmountResponse {
  int responseCode;
  final String message;
  final List<CashierAmountModel>? data;

  CashierAmountResponse({
    required this.responseCode,
    required this.message,
    required this.data,
  });

  factory CashierAmountResponse.fromJson(Map<String, dynamic> json) {
    return CashierAmountResponse(
      responseCode: json['responseCode'] ?? 0,
      message: json['message'] ?? "",
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => CashierAmountModel.fromJson(e))
          .toList()
          : [],
    );
  }
}
