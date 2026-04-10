import 'package:fullcomm_crm/models/billing_models/products_response.dart';
class BillingItemBeforeCombo {
  String id;
  ProductData product;
  String productTitle;
  double variation; // Grams for loose items
  String variationUnit;
  int quantity; // Quantity for non-loose items
  String? outPrice;
  String p_out_price;
  String p_mrp;

  BillingItemBeforeCombo({
    required this.id,
    required this.product,
    required this.productTitle,
    required this.variation,
    required this.variationUnit,
    required this.quantity,
    this.outPrice,
    required this.p_out_price,
    required this.p_mrp,
  });


  /// Convert Map → BillingItem
  factory BillingItemBeforeCombo.fromJson(Map<String, dynamic> json) {
    return BillingItemBeforeCombo(
      id: json['id']?.toString() ?? '',
      product: ProductData.fromJson(json['product']),
      productTitle: json['productTitle']?.toString() ?? '',
      variation: (json['variation'] as num?)?.toDouble() ?? 0.0,
      variationUnit: json['variationUnit']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,

      // 🔥 FIX IS HERE
      outPrice: json['outPrice']?.toString(),
      p_out_price: json['p_out_price']?.toString() ?? '0',
      p_mrp: json['p_mrp']?.toString() ?? '0',
    );
  }


  BillingItemBeforeCombo copyWith({
    String? id,
    ProductData? product,
    String? productTitle,
    double? variation,
    int? quantity,
    String? variationUnit,
    String? p_out_price,
    String? p_mrp,
  }) {
    return BillingItemBeforeCombo(
      id: id ?? this.id,
      product: product ?? this.product,
      productTitle: productTitle ?? this.productTitle,
      variation: variation ?? this.variation,
      quantity: quantity ?? this.quantity,
      variationUnit: variationUnit ?? this.variationUnit,
      p_out_price: p_out_price ?? this.p_out_price,
      p_mrp: p_mrp ?? this.p_mrp,
    );
  }
  /// Calculate Mrp per product (for one product) :
  double mrpPerProduct() {
    double value;

    if (product.isLoose == '1') {
      // value = (double.parse(product.mrp.toString()) /
      //     double.parse(product.qtyLeft.toString())) *
      //     variation;

      value = (
          double.parse(product.mrp.toString()));
    } else {
      value = double.parse(product.mrp.toString());
    }

    return double.parse(value.toStringAsFixed(5));
  }

  double outPricePerProduct() {
    if (product.isLoose == '1') {
      // Loose product
      final pricePerG =
      double.tryParse(product.pricePerG?.toString() ?? '');

      return (pricePerG ?? 0.0) * 1000;
    } else {
      // Regular product
      final outPrice =
      double.tryParse(product.outPrice?.toString() ?? '');

      return outPrice ?? 0.0;
    }
  }


  /// Calculate Out price per product (for one product) :
  // double calculateOutPrice() {
  //   if (product.isLoose == '1') {
  //     return double.parse((double.parse(product.pricePerG) * 1000).toStringAsFixed(2));
  //   } else {
  //     return double.parse(double.parse(product.outPrice.toString()).toStringAsFixed(2));
  //   }
  // }

  double safeDouble(value) {
    if (value == null) return 0.0;
    if (value.toString().trim().isEmpty) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Calculate Subtotal :
  double calculateSubtotal() {
    final double safeVariation = variation ?? 0;
    final int safeQty = quantity ?? 0;

    if (product.isLoose == '1') {
      final double pricePerG =
          double.tryParse(product.pricePerG?.toString() ?? '') ?? 0.0;

      print("Loose Calc → variation:$safeVariation price:$pricePerG");

      return safeVariation * pricePerG;
    } else {
      final double price =
          double.tryParse(product.outPrice?.toString() ?? '') ?? 0.0;

      print("Normal Calc → qty:$safeQty price:$price");

      return price * safeQty;
    }
  }


  double calculateBillSubtotal() {
    if (product.isLoose == '1') {
      return variation * safeDouble(product.pricePerG);
    } else {
      return quantity * safeDouble(product.outPrice);
    }
  }



  /// Calculate MRP Subtotal
  double calculateMrpSubtotal() {
    double mrp = double.tryParse(product.mrp?.toString() ?? "0") ?? 0;
    double safeVariation = variation ?? 0; // grams
    int safeQuantity = quantity ?? 0;

    /// 🟢 LOOSE PRODUCT
    if (product.isLoose == '1') {
      // MRP per gram
      double mrpPerGram = mrp / 1000;

      // variation is in grams
      double mrpTotal = safeVariation * mrpPerGram;

      return double.parse(mrpTotal.toStringAsFixed(2));
    }

    /// 🟢 PACKED PRODUCT
    else {
      double mrpTotal = mrp * safeQuantity;
      return double.parse(mrpTotal.toStringAsFixed(2));
    }
  }


  double calculateOutPrice() {
    if (product.isLoose == '1') {
      final price = double.tryParse(product.pricePerG.toString()) ?? 0.0;
      return double.parse((price * 1000).toStringAsFixed(2));
    } else {
      final price = double.tryParse(product.outPrice.toString()) ?? 0.0;
      return double.parse(price.toStringAsFixed(2));
    }
  }


  /// Calculates the Sub discount :
  double calculateDiscount() {
    // 🔐 Safe parsing
    double mrp = double.tryParse(product.mrp?.toString() ?? "0") ?? 0;
    double outPrice = double.tryParse(product.outPrice?.toString() ?? "0") ?? 0;

    int safeQuantity = quantity ?? 0;      // packed items count
    double safeVariation = variation ?? 0; // loose qty (grams / kg)

    // ❌ No discount
    if (mrp <= outPrice) return 0;

    double discountPerKg = mrp - outPrice;

    /// 🟢 LOOSE PRODUCT
    if (product.isLoose == '1') {
      double qtyInKg;

      // 👉 grams na
      if (safeVariation > 1) {
        qtyInKg = safeVariation / 1000;
      }
      // 👉 kg na
      else {
        qtyInKg = safeVariation;
      }

      double discount = qtyInKg * discountPerKg;
      return double.parse(discount.toStringAsFixed(2));
    }

    /// 🟢 PACKED PRODUCT (ELSE)
    else {
      double discount = safeQuantity * discountPerKg;
      return double.parse(discount.toStringAsFixed(2));
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_loose': product.isLoose.toString(),
      'batch_no': product.batchNo.toString(),
      'p_title': productTitle,
      'qty': product.isLoose == '0'
          ? quantity
          : double.parse(variation.toString()),
      'p_discount': (calculateMrpSubtotal() - calculateSubtotal()).toString(),
      'product_img': product.pImg.toString(),
      'out_price': calculateSubtotal().toString(),
      'p_out_price':product.outPrice.toString() ,
      'p_mrp':product.mrp.toString() ,
      'unit':  product.isLoose == '0' ? variationUnit : "Loose",
      // 'available_stock': availableStock.toString(), // ✅ Added here
      'product': product.toJson(),
      'productTitle': productTitle,
      'variation': variation,
      'variationUnit': product.isLoose == '0' ? variationUnit : variation,
      'quantity': quantity,
    };
  }

}
