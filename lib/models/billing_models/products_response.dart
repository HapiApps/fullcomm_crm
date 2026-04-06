class ProductsResponse {
  int? responseCode;
  String? message;
  List<ProductData>? productList;

  ProductsResponse({
    this.responseCode,
    this.message,
    this.productList,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => ProductsResponse(
    responseCode: json["responseCode"],
    message: json["message"],
    productList: json["data"] == null ? [] : List<ProductData>.from(json["data"]!.map((x) => ProductData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "responseCode": responseCode,
    "message": message,
    "data": productList == null ? [] : List<dynamic>.from(productList!.map((x) => x.toJson())),
  };
}
class ProductData {
  String? id;
  String? skuId;
  dynamic hsnCode;
  String? barcode;
  String? catId;
  String? subCatId;
  String? pImg;
  String? pTitle;
  String? brand;
  String? pVariation;
  String? cgst;
  String? sgst;
  String? igst;
  String? pDisc;
  String? unit;
  String? type;
  dynamic pDesc;
  String? isLoose;
  String? reorderLevel;
  String? emergencyLevel;
  String? location;
  String? godownLocation;
  String? batchNo;
  String? mrp;
  String? outPrice;
  String? qtyLeft;
  String? stockQty;
  dynamic pricePerG;
  String? missingQty;
  DateTime? expiryDate;
  String? stockDate;
  String? supplierId;

  String? minimumExpiryDate;
  String? maximumExpiryDate;

  /// 🔥 NEW OFFER FIELDS
  String? buyQty;
  String? getQty;
  String? isFree;

  ProductData({
    this.id,
    this.skuId,
    this.hsnCode,
    this.barcode,
    this.catId,
    this.subCatId,
    this.pImg,
    this.pTitle,
    this.brand,
    this.pVariation,
    this.cgst,
    this.sgst,
    this.igst,
    this.pDisc,
    this.unit,
    this.type,
    this.pDesc,
    this.isLoose,
    this.reorderLevel,
    this.emergencyLevel,
    this.location,
    this.godownLocation,
    this.batchNo,
    this.mrp,
    this.outPrice,
    this.qtyLeft,
    this.stockQty,
    this.pricePerG,
    this.missingQty,
    this.expiryDate,
    this.stockDate,
    this.supplierId,
    this.minimumExpiryDate,
    this.maximumExpiryDate,

    /// NEW
    this.buyQty,
    this.getQty,
    this.isFree,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
    id: json["id"]?.toString(),
    skuId: json["sku_id"],
    hsnCode: json["hsn_code"],
    barcode: json["barcode"],
    catId: json["cat_id"]?.toString(),
    subCatId: json["sub_cat_id"]?.toString(),
    pImg: json["p_img"],
    pTitle: json["p_title"],
    brand: json["brand"],
    pVariation: json["p_variation"],
    cgst: json["cgst"]?.toString(),
    sgst: json["sgst"]?.toString(),
    igst: json["igst"]?.toString(),
    pDisc: json["p_disc"]?.toString(),
    unit: json["unit"],
    type: json["type"],
    pDesc: json["p_desc"],
    isLoose: json["is_loose"]?.toString(),
    reorderLevel: json["reorder_level"]?.toString(),
    emergencyLevel: json["emergency_level"]?.toString(),
    location: json["location"],
    godownLocation: json["godown_location"],
    batchNo: json["batch_no"],
    mrp: json["mrp"]?.toString(),
    outPrice: json["out_price"]?.toString(),
    qtyLeft: json["qty_left"]?.toString(),
    stockQty: json["stockqty"]?.toString(),
    pricePerG: json["per_g"]?.toString(),
    missingQty: json["missing_qty"]?.toString(),
    expiryDate: json["expiry_date"] == null
        ? null
        : DateTime.parse(json["expiry_date"]),
    stockDate: json["stock_date"],
    supplierId: json["supplier_id"],

    minimumExpiryDate: json["minimum_expiry_date"],
    maximumExpiryDate: json["maximum_expiry_date"],

    /// 🔥 NEW PARSING
    buyQty: json["buy_qty"]?.toString(),
    getQty: json["get_qty"]?.toString(),
    isFree: json["is_free"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sku_id": skuId,
    "hsn_code": hsnCode,
    "barcode": barcode,
    "cat_id": catId,
    "sub_cat_id": subCatId,
    "p_img": pImg,
    "p_title": pTitle,
    "brand": brand,
    "p_variation": pVariation,
    "cgst": cgst,
    "sgst": sgst,
    "igst": igst,
    "p_disc": pDisc,
    "unit": unit,
    "type": type,
    "p_desc": pDesc,
    "is_loose": isLoose,
    "reorder_level": reorderLevel,
    "emergency_level": emergencyLevel,
    "location": location,
    "godown_location": godownLocation,
    "batch_no": batchNo,
    "mrp": mrp,
    "out_price": outPrice,
    "qty_left": qtyLeft,
    "stockqty": stockQty,
    "per_g": pricePerG,
    "missing_qty": missingQty,
    "expiry_date": expiryDate?.toIso8601String(),
    "stock_date": stockDate,
    "supplier_id": supplierId,
    "minimum_expiry_date": minimumExpiryDate,
    "maximum_expiry_date": maximumExpiryDate,

    /// 🔥 NEW
    "buy_qty": buyQty,
    "get_qty": getQty,
    "is_free": isFree,
  };
}
