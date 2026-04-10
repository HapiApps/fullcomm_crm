import 'package:fullcomm_crm/models/billing_models/products_response.dart';
import '../../controller/controller.dart';

class BillingItem {
  String id;
  ProductData product;
  String productTitle;
  double variation; // Grams for loose items
  String variationUnit;
  int quantity;
  int scanCount = 1;// Quantity for non-loose items
  String? outPrice;
  String p_out_price;
  String p_mrp;

  BillingItem({
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

  factory BillingItem.fromJson(Map<String, dynamic> json) {
    return BillingItem(
      id: json['id']?.toString() ?? '',
      product: ProductData.fromJson(json['product']),
      productTitle: json['productTitle']?.toString() ?? '',
      variation: (json['variation'] as num?)?.toDouble() ?? 0.0,
      variationUnit: json['variationUnit']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      outPrice: json['outPrice']?.toString(),
      p_out_price: json['p_out_price']?.toString() ?? '0',
      p_mrp: json['p_mrp']?.toString() ?? '0',
    );
  }

  // ------------------------------------------------------------
  // 🔥 OFFER ENGINE (ADDED ONLY THIS SECTION)
  // ------------------------------------------------------------

  int _safeInt(String? value) {
    return int.tryParse(value ?? '') ?? 0;
  }

  bool get hasOffer {
    return product.isLoose == '0' &&
        product.isFree == "1" &&
        _safeInt(product.buyQty) > 0 &&
        _safeInt(product.getQty) > 0;
  }

  int get buyQty => _safeInt(product.buyQty);
  int get freeQty => _safeInt(product.getQty);

  int calculateFreeQuantity() {
    if (!hasOffer) return 0;

    int groupSize = buyQty + freeQty;
    int fullGroups = quantity ~/ groupSize;

    return fullGroups * freeQty;
  }

  int calculateChargeableQuantity() {
    if (!hasOffer) return quantity;

    int groupSize = buyQty + freeQty;
    int fullGroups = quantity ~/ groupSize;
    int remainder = quantity % groupSize;

    int chargeableFromGroups = fullGroups * buyQty;
    int chargeableFromRemainder =
    remainder > buyQty ? buyQty : remainder;

    return chargeableFromGroups + chargeableFromRemainder;
  }

  // ------------------------------------------------------------


  BillingItem copyWith({
    String? id,
    ProductData? product,
    String? productTitle,
    double? variation,
    int? quantity,
    String? variationUnit,
    String? p_out_price,
    String? p_mrp,
  }) {
    return BillingItem(
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
    final double safeVariation = variation;
    final int safeQty = quantity;

    if (product.isLoose == '1') {
      final double pricePerG =
          double.tryParse(product.pricePerG?.toString() ?? '') ?? 0.0;

      return safeVariation * pricePerG;
    } else {
      final double price =
          double.tryParse(product.outPrice?.toString() ?? '') ?? 0.0;

      // 🔥 APPLY OFFER HERE
      int finalQty =
      hasOffer ? calculateChargeableQuantity() : safeQty;

      return price * finalQty;
    }
  }


  double calculateBillSubtotal() {
    if (product.isLoose == '1') {
      return variation * safeDouble(product.pricePerG);
    } else {
      // 🔥 Apply offer if available
      if (hasOffer) {
        int chargeableQty = calculateChargeableQuantity();
        return chargeableQty * safeDouble(product.outPrice);
      }

      return quantity * safeDouble(product.outPrice);
    }
  }



  /// Calculate MRP Subtotal
  double calculateMrpSubtotal() {
    double mrp = double.tryParse(product.mrp?.toString() ?? "0") ?? 0;
    double safeVariation = variation;
    int safeQuantity = quantity;

    if (product.isLoose == '1') {
      double mrpPerGram = mrp / 1000;
      double mrpTotal = safeVariation * mrpPerGram;
      return double.parse(mrpTotal.toStringAsFixed(2));
    } else {
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


  /// Calculates Discount :
  double calculateDiscount() {
    double mrp = double.tryParse(product.mrp?.toString() ?? "0") ?? 0;
    double outPrice =
        double.tryParse(product.outPrice?.toString() ?? "0") ?? 0;

    int safeQuantity = quantity;
    double safeVariation = variation;

    if (mrp <= outPrice) return 0;

    double discountPerUnit = mrp - outPrice;

    // 🔥 LOOSE PRODUCT
    if (product.isLoose == '1') {
      double qtyInKg =
      safeVariation > 1 ? safeVariation / 1000 : safeVariation;

      double discount = qtyInKg * discountPerUnit;
      return double.parse(discount.toStringAsFixed(2));
    }

    // 🔥 PACKED PRODUCT WITH OFFER
    if (hasOffer) {
      int freeItems = calculateFreeQuantity();
      double discount = freeItems * outPrice;
      return double.parse(discount.toStringAsFixed(2));
    }

    // 🔥 NORMAL PACKED
    double discount = safeQuantity * discountPerUnit;
    return double.parse(discount.toStringAsFixed(2));
  }


  Map<String, dynamic> toJson() {
    return {
      "cos_id": controllers.storage.read("cos_id"),
      'id': id,
      'is_loose': product.isLoose.toString(),
      'batch_no': product.batchNo.toString(),
      'p_title': productTitle,
      'qty': product.isLoose == '0'
          ? quantity
          : double.parse(variation.toString()),
      'free_qty': calculateFreeQuantity(), // 🔥 added
      'p_discount': calculateDiscount().toString(),
      'product_img': product.pImg.toString(),
      'out_price': calculateSubtotal().toString(),
      'p_out_price': product.outPrice.toString(),
      'p_mrp': product.mrp.toString(),
      'unit': product.isLoose == '0'
          ? variationUnit
          : "Loose",
      'product': product.toJson(),
      'productTitle': productTitle,
      'variation': variation,
      'variationUnit': product.isLoose == '0'
          ? variationUnit
          : variation,
      'quantity': quantity,
    };
  }
}


