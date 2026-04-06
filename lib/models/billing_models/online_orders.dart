class OrderStatusResponse {
  int? responseCode;
  String? message;
  OrderStatusCountModel? data;

  OrderStatusResponse({
    this.responseCode,
    this.message,
    this.data,
  });

  OrderStatusResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    message = json['message'];
    data = json['data'] != null
        ? OrderStatusCountModel.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['responseCode'] = responseCode;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }

    return data;
  }
}

class OrderStatusCountModel {
  int? totalOrders;
  int? orderPlaced;
  int? processing;
  int? packed;
  int? deliveryPersonAssigned;
  int? outForDelivery;
  int? completed;
  int? cancelled;

  OrderStatusCountModel({
    this.totalOrders,
    this.orderPlaced,
    this.processing,
    this.packed,
    this.deliveryPersonAssigned,
    this.outForDelivery,
    this.completed,
    this.cancelled,
  });

  OrderStatusCountModel.fromJson(Map<String, dynamic> json) {
    totalOrders = json['total_orders'];
    orderPlaced = json['order_placed'];
    processing = json['processing'];
    packed = json['packed'];
    deliveryPersonAssigned = json['delivery_person_assigned'];
    outForDelivery = json['out_for_delivery'];
    completed = json['completed'];
    cancelled = json['cancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['total_orders'] = totalOrders;
    data['order_placed'] = orderPlaced;
    data['processing'] = processing;
    data['packed'] = packed;
    data['delivery_person_assigned'] = deliveryPersonAssigned;
    data['out_for_delivery'] = outForDelivery;
    data['completed'] = completed;
    data['cancelled'] = cancelled;

    return data;
  }
}