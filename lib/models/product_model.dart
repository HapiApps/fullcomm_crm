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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      availability: json['availability'],
      condition: json['condition'],
      price: double.parse(json['price'].toString()),
      link: json['link'],
      imageLink: json['image_link'],
      brand: json['brand'],
      updatedTs: json['updated_ts'],
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
    };
  }
}