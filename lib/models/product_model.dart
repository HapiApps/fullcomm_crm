import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class ProductModel {
  int? id;
  String? skuId;
  String? hsnCode;
  String? cat;
  String? subCat;
  String? title;
  String? brand;
  String? mrp;
  String? outPrice;
  TextEditingController qty; // ✅ controller
  TextEditingController amount; // ✅ controller
  double? gst;
  String? createdTs;
  String? updatedTs;
  RxBool isSelect;

  ProductModel({
    this.id,
    this.skuId,
    this.hsnCode,
    this.cat,
    this.subCat,
    this.title,
    this.brand,
    this.mrp,
    this.outPrice,
    TextEditingController? qty,
    TextEditingController? amount,
    this.gst,
    this.createdTs,
    this.updatedTs,
    RxBool? isSelect,
  })  : qty = qty ?? TextEditingController(),amount = amount ?? TextEditingController(),
        isSelect = isSelect ?? false.obs;

  /// 🔥 FROM JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      skuId: json['sku_id']?.toString() ?? "",
      hsnCode: json['hsn_code']?.toString() ?? "",
      cat: json['category']?.toString() ?? "",
      subCat: json['sub_category']?.toString() ?? "",
      title: json['p_title']?.toString() ?? "",
      brand: json['brand']?.toString() ?? "",
      mrp: json['mrp']?.toString() ?? "",
      outPrice: json['out_price']?.toString() ?? "",
      gst: double.tryParse(json['gst']?.toString() ?? "0") ?? 0,
      createdTs: json['created_ts']?.toString() ?? "",
      updatedTs: json['updated_ts']?.toString() ?? "",
      isSelect: false.obs,

      /// ✅ IMPORTANT FIX
      qty: TextEditingController(text: json['qty']?.toString() ?? "",),
      amount: TextEditingController(text: json['amount']?.toString() ?? "",),
    );
  }

  /// 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku_id": skuId,
      "hsn_code": hsnCode,
      "category": cat,
      "sub_category": subCat,
      "mrp": mrp,
      "out_price": outPrice,
      "p_title": title,
      "brand": brand,
      "gst": gst,

      /// ✅ controller → value
      "qty": qty.text,
      "amount": amount.text,

      "created_ts": createdTs,
      "updated_ts": updatedTs,
      "isSelect": isSelect.value,
    };
  }
}

class BillingRow {
  ProductModel? product;
  int qty;
  double price;
  double amount;

  BillingRow({
    this.product,
    this.qty = 1,
    this.price = 0,
    this.amount = 0,
  });
  Map<String, dynamic> toJson() {
    return {
      "product_id": product?.id,
      "name": product?.title,
      "qty": qty,
      "price": price,
      "amount": amount,
    };
  }

}