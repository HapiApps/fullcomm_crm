class Order {
  final String id;
  final String orderId;
  final String customerName;
  final String createdTs;
  final String totalAmt;
  final String createdBy;
  // final int cosId;
  // final List<Product> products;

  Order({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.totalAmt,
    required this.createdBy,
    required this.createdTs,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? "",
      orderId: json['invoice_no']?.toString() ?? "",
      customerName: json['name'] ?? "",
      createdTs: json['created_ts'] ?? "",
      totalAmt: json['o_total']?.toString() ?? "",
      createdBy: json['created_by']?.toString() ?? "",    );
  }
}

// class Product {
//   final int productId;
//   final String name;
//   final int qty;
//   final double price;
//   final double amount;
//
//   Product({
//     required this.productId,
//     required this.name,
//     required this.qty,
//     required this.price,
//     required this.amount,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       productId: json['product_id'] ?? 0,
//       name: json['name'] ?? '',
//       qty: json['qty'] ?? 0,
//       price: (json['price'] ?? 0).toDouble(),
//       amount: (json['amount'] ?? 0).toDouble(),
//     );
//   }
// }