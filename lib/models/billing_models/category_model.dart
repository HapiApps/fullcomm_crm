class Category {
  final String id;
  final String title;
  final List<SubCategory> subcategories;

  Category({
    required this.id,
    required this.title,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var subList = json['subcategories'] as List? ?? [];
    List<SubCategory> subs =
    subList.map((e) => SubCategory.fromJson(e)).toList();

    return Category(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subcategories: subs,
    );
  }
}

class SubCategory {
  final String id;
  final String title;

  SubCategory({
    required this.id,
    required this.title,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'].toString(),
      title: json['title'] ?? '',
    );
  }
}
