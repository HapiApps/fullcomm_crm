import 'package:get/get.dart';

class ProductModel {
  int? id;
  String? skuId;
  String? hsnCode;
  String? cat;
  String? subCat;
  String? title;
  String? brand;
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
    this.gst,
    this.createdTs,
    RxBool? isSelect,
  }) : isSelect = isSelect ?? false.obs;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      skuId: json['sku_id']?.toString() ?? "",
      hsnCode: json['hsn_code'] ?? "",
      cat: json['category'],
      subCat: json['sub_category'],
      title: json['p_title'] ?? "",
      brand: json['brand']?.toString() ?? "",
      gst: double.tryParse(json['gst']?.toString() ?? "0"),
      createdTs: json['created_ts'] ?? "",
      isSelect: false.obs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku_id": skuId,
      "hsn_code": hsnCode,
      "category": cat,
      "sub_category": subCat,
      "p_title": title,
      "brand": brand,
      "gst": gst,
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