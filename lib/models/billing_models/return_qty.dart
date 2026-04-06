class StockProduct {
  final int productId;
  final String batchNo;
  final String loose; // '0' or '1'
  final int quantity;

  StockProduct({
    required this.productId,
    required this.batchNo,
    required this.quantity,
    required this.loose,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "batch_no": batchNo,
      "quantity": quantity,
      "loose": loose,
    };
  }

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      productId: int.parse(json['product_id'].toString()),
      batchNo: json['batch_no'].toString(),
      quantity: int.parse(json['quantity'].toString()),
      loose: json['loose'].toString(),
    );
  }
}
