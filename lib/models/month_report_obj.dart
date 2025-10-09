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
  final String dayDate;
  final String? dayName;
  final double totalCustomers;

  CustomerDayData({
    required this.dayDate,
    this.dayName,
    required this.totalCustomers,
  });

  factory CustomerDayData.fromJson(Map<String, dynamic> json) {
    return CustomerDayData(
      dayDate: json['day_date'] ?? '',
      dayName: json['day_name'],
      totalCustomers: double.tryParse(json['total_customers'].toString()) ?? 0,
    );
  }

  int get dayNum {
    try {
      return DateTime.parse(dayDate).day;
    } catch (e) {
      return 0;
    }
  }
}

