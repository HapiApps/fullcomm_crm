class CashierAmountModel {
  String pMethodId;
  String totalAmount;

  CashierAmountModel({
    required this.pMethodId,
    required this.totalAmount,
  });

  factory CashierAmountModel.fromJson(Map<String, dynamic> json) {
    return CashierAmountModel(
      pMethodId: json['p_method_id']!.toString(),
      totalAmount: json['total_amount']!.toString(),
    );
  }
}
