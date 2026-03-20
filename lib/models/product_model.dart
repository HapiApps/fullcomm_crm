import 'package:get/get.dart';

class ProductModel {
  int? id;
  String? skuId;
  String? hsnCode;
  String? barcode;
  int? catId;
  int? subCatId;
  String? pImg;
  String? title;
  String? brand;
  String? variation;
  int? isLoose;
  int? returnValidity;
  double? gst;
  double? cgst;
  double? sgst;
  double? igst;
  double? discount;
  String? unit;
  String? type;
  String? description;
  int? reorderLevel;
  int? emergencyLevel;
  String? location;
  String? godownLocation;
  String? createdTs;
  String? updatedTs;
  int? active;

  RxBool isSelect;

  ProductModel({
    this.id,
    this.skuId,
    this.hsnCode,
    this.barcode,
    this.catId,
    this.subCatId,
    this.pImg,
    this.title,
    this.brand,
    this.variation,
    this.isLoose,
    this.returnValidity,
    this.gst,
    this.cgst,
    this.sgst,
    this.igst,
    this.discount,
    this.unit,
    this.type,
    this.description,
    this.reorderLevel,
    this.emergencyLevel,
    this.location,
    this.godownLocation,
    this.createdTs,
    this.updatedTs,
    this.active,
    RxBool? isSelect,
  }) : isSelect = isSelect ?? false.obs;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      skuId: json['sku_id']?.toString() ?? "",
      hsnCode: json['hsn_code'] ?? "",
      barcode: json['barcode'] ?? "",
      catId: json['cat_id'],
      subCatId: json['sub_cat_id'],
      pImg: json['p_img']?.toString() ?? "",
      title: json['p_title'] ?? "",
      brand: json['brand']?.toString() ?? "",
      variation: json['p_variation']?.toString() ?? "",
      isLoose: json['is_loose'],
      returnValidity: json['return_validity'],
      gst: double.tryParse(json['gst']?.toString() ?? "0"),
      cgst: double.tryParse(json['cgst']?.toString() ?? "0"),
      sgst: double.tryParse(json['sgst']?.toString() ?? "0"),
      igst: double.tryParse(json['igst']?.toString() ?? "0"),
      discount: double.tryParse(json['p_disc']?.toString() ?? "0"),
      unit: json['unit'] ?? "",
      type: json['type']?.toString() ?? "",
      description: json['p_desc']?.toString() ?? "",
      reorderLevel: json['reorder_level'],
      emergencyLevel: json['emergency_level'],
      location: json['location']?.toString() ?? "",
      godownLocation: json['godown_location']?.toString() ?? "",
      createdTs: json['created_ts'] ?? "",
      updatedTs: json['updated_ts'] ?? "",
      active: json['active'],
      isSelect: false.obs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku_id": skuId,
      "hsn_code": hsnCode,
      "barcode": barcode,
      "cat_id": catId,
      "sub_cat_id": subCatId,
      "p_img": pImg,
      "p_title": title,
      "brand": brand,
      "p_variation": variation,
      "is_loose": isLoose,
      "return_validity": returnValidity,
      "gst": gst,
      "cgst": cgst,
      "sgst": sgst,
      "igst": igst,
      "p_disc": discount,
      "unit": unit,
      "type": type,
      "p_desc": description,
      "reorder_level": reorderLevel,
      "emergency_level": emergencyLevel,
      "location": location,
      "godown_location": godownLocation,
      "created_ts": createdTs,
      "updated_ts": updatedTs,
      "active": active,
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