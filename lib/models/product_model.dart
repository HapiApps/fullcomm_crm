import 'package:get/get.dart';

class ProductModel {
  int? id;
  String? title;
  String? description;
  String? availability;
  String? condition;
  double? price;
  String? link;
  String? imageLink;
  String? brand;
  String? updatedTs;
  RxBool isSelect;

  ProductModel({
    this.id,
    this.title,
    this.description,
    this.availability,
    this.condition,
    this.price,
    this.link,
    this.imageLink,
    this.brand,
    this.updatedTs,
    RxBool? isSelect,
  }) : isSelect = isSelect ?? false.obs;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      availability: json['availability'],
      condition: json['condition'],
      price: double.tryParse(json['price'].toString()),
      link: json['link'],
      imageLink: json['image_link'],
      brand: json['brand'],
      updatedTs: json['updated_ts'],
      isSelect: false.obs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "availability": availability,
      "condition": condition,
      "price": price,
      "link": link,
      "image_link": imageLink,
      "brand": brand,
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