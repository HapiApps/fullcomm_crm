class CustomerMonthData {
  final String monthName;
  final double totalCustomers;

  CustomerMonthData({
    required this.monthName,
    required this.totalCustomers,
  });

  factory CustomerMonthData.fromJson(Map<String, dynamic> json) {
    return CustomerMonthData(
      monthName: json['month_name'],
      totalCustomers: double.tryParse(json['total_customers'].toString()) ?? 0,
    );
  }
}

class CustomerDayData {
  final int dayNum;
  final String? dayName;
  final double totalCustomers;

  CustomerDayData({
    required this.dayNum,
    this.dayName,
    required this.totalCustomers,
  });

  factory CustomerDayData.fromJson(Map<String, dynamic> json) {
    return CustomerDayData(
      dayNum: int.tryParse(json['day_num'].toString()) ?? 0,
      dayName: json['day_name'],
      totalCustomers: double.tryParse(json['total_customers'].toString()) ?? 0,
    );
  }
}
