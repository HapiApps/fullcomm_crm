//SELECT id, name, brand, compare_price, discount, product_price FROM product
class ProductObj {
  String? id;
  String? name;
  String? brand;
  String? comparePrice;
  String? discount;
  String? productPrice;

  ProductObj(
      {this.id,
      this.name,
      this.brand,
      this.comparePrice,
      this.discount,
      this.productPrice});

  factory ProductObj.fromJson(Map<String, dynamic> json) => ProductObj(
    id: json["id"]?.toString() ?? '',
    name: json["name"]?.toString() ?? '',
    brand: json["brand"]?.toString() ?? '',
    comparePrice: json["compare_price"]?.toString() ?? '',
    discount: json["discount"]?.toString() ?? '',
    productPrice: json["product_price"]?.toString() ?? '',
  );
}
