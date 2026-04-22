class Order {
  final String id;
  final String orderId;
  final String customerName;
  final String createdTs;
  final String totalAmt;
  final String createdBy;
  final String status;
  final String address;
  final String mobile;
  final String subtotal;
  final String companyName;
  final List<Product> products;

  Order({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.totalAmt,
    required this.createdBy,
    required this.createdTs,
    required this.status,
    required this.address,
    required this.mobile,
    required this.subtotal,
    required this.products,
    required this.companyName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? "",
      orderId: json['invoice_no']?.toString() ?? "",
      customerName: json['name'] ?? "",
      companyName: json['company_name'] ?? "",
      createdTs: json['created_ts'] ?? "",
      totalAmt: json['o_total']?.toString() ?? "",
      subtotal: json['subtotal']?.toString() ?? "",
      mobile: json['mobile']?.toString() ?? "",
      address: json['address']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      createdBy: json['created_by']?.toString() ?? "",

      /// ✅ SAFE LIST PARSE
      products: json['products'] != null
          ? List<Product>.from(
          (json['products'] as List)
              .map((e) => Product.fromJson(e)))
          : [],
    );
  }
}

class Product {
  final String name;
  final int qty;
  final double price;
  final double mrp;
  final double amount;

  Product({
    required this.name,
    required this.qty,
    required this.price,
    required this.mrp,
    required this.amount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      qty: int.tryParse(json['qty']?.toString() ?? "0") ?? 0,
      mrp: double.tryParse(json['mrp']?.toString() ?? "0") ?? 0,
      price: double.tryParse(json['price']?.toString() ?? "0") ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? "0") ?? 0,
    );
  }
}

class Quotations {
  final int id;
  final String invoicePdf;
  final String name;
  final String company;
  final String quotationNo;
  final String number;
  final String createdTs;
  final String status;
  final String validityDate;
  final String email;
  String? dropValue;
  final int totalAmt;
  final int cusId;
  final int totalProduct;
  final int totalItem;
  final String subTotal;
  final String dis;
  final String gst;
  final String amount;
  final String price;
  final String mrp;
  final String qty;
  final String pName;
  final String pId;

  Quotations({
    required this.id,
    required this.totalAmt,
    required this.invoicePdf,
    required this.quotationNo,
    required this.name,
    required this.number,
    required this.createdTs,
    required this.status,
    required this.cusId,
    required this.totalProduct,
    required this.totalItem,
    required this.company,
    required this.email,
    required this.subTotal,
    required this.validityDate,
    required this.dis,
    required this.gst,
    required this.amount,
    required this.price,
    required this.mrp,
    required this.qty,
    required this.pName,
    required this.pId,
    this.dropValue,
  });

  factory Quotations.fromJson(Map<String, dynamic> json) {
    return Quotations(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      cusId: int.tryParse(json['cus_id']?.toString() ?? "0") ?? 0,
      quotationNo: json['q_no'] ?? '',
      invoicePdf: json['invoice_pdf'] ?? '',
      name: json['name'] ?? '',
      company: json['company_name'] ?? '',
      number: json['number'] ?? '',
      status: json['status'] ?? '',
      createdTs: json['created_ts'] ?? '',
      validityDate: json['validity_date'] ?? '',
      email: json['email'] ?? '',
      pId: json['p_id'] ?? '',
      pName: json['productname'] ?? '',
      qty: json['qty'] ?? '',
      mrp: json['mrp'] ?? '',
      price: json['price'] ?? '',
      amount: json['amount'] ?? '',
      gst: json['gst'] ?? '',
      dis: json['dis'] ?? '',
      subTotal: json['subTotal'] ?? '',
      dropValue: 'Confirm Order',
      totalAmt: int.tryParse(json['total_amt']?.toString() ?? "0") ?? 0,
      totalProduct: int.tryParse(json['total_product']?.toString() ?? "0") ?? 0,
      totalItem: int.tryParse(json['total_item']?.toString() ?? "0") ?? 0
    );
  }
}