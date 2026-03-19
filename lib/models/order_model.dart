class Order {
  final int id;
  final int orderId;
  final int customerId;
  final String customerName;
  final String createdTs;
  final double totalAmt;
  final int createdBy;
  final int cosId;
  final List<Product> products;

  Order({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerId,
    required this.totalAmt,
    required this.createdBy,
    required this.cosId,
    required this.products,
    required this.createdTs,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? "",
      createdTs: json['created_ts'] ?? "",
      totalAmt: (json['total_amt'] ?? 0).toDouble(),
      createdBy: json['created_by'] ?? 0,
      cosId: json['cos_id'] ?? 0,
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

class Product {
  final int productId;
  final String name;
  final int qty;
  final double price;
  final double amount;

  Product({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.amount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      qty: json['qty'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}