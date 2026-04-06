import 'billing_product.dart';

class Order {
  String? id; // Bill No
  String? createdTs; // Date
  String customerMobile;
  String customerId;
  String customerName;
  String customerAddress;
  String cashier;
  String paymentMethod;
  String paymentId;
  String orderGrandTotal;
  String orderSubTotal;
  String receivedAmt;
  String payBackAmt;
  String savings;
  int billStatus;
  int creditDays;
  String salesmanId;
  String split_pay;
  String version;
  List<BillingItem> products;

  Order({
    this.id,
    this.createdTs,
    required this.orderGrandTotal,
    required this.orderSubTotal,
    required this.customerMobile,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.cashier,
    required this.paymentMethod,
    required this.paymentId,
    required this.receivedAmt,
    required this.payBackAmt,
    required this.products,
    required this.billStatus,
    required this.creditDays,
    required this.salesmanId,
    required this.savings,
    required this.split_pay,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTs': createdTs,
      'mobile': customerMobile,
      'customer_id': customerId,
      'customer_name': customerName,
      'address': customerAddress,
      'cashier': cashier,
      'payment_method': paymentMethod,
      'payment_id': paymentId,
      'o_total': orderGrandTotal,
      'subtotal': orderSubTotal,
      'received_amt': receivedAmt,
      'pay_back_amt': payBackAmt,
      'bill_status': billStatus,
      'credit_days': creditDays,
      'salesman_id': salesmanId,
      'savings': savings,
      'split_pay': split_pay,
      'version': version,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      createdTs: json['createdTs'],
      customerMobile: json['mobile'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerAddress: json['address'] ?? '',
      cashier: json['cashier'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentId: json['payment_id'] ?? '',
      orderGrandTotal: json['o_total'] ?? '0.0',
      orderSubTotal: json['subtotal'] ?? '0.0',
      receivedAmt: json['received_amt'] ?? '0.0',
      payBackAmt: json['pay_back_amt'] ?? '0.0',
      billStatus: json['bill_status'] ?? 0,
      creditDays: json['credit_days'] ?? 0,
      salesmanId: json['salesman_id'] ?? '',
      savings: json['savings'] ?? '0.0',
      split_pay: json['split_pay'] ?? '0.0',
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => BillingItem.fromJson(e))
          .toList() ??
          [],
      version:json['version'] ?? '0',
    );
  }

}

