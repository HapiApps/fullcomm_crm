double d(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
String s(dynamic value) {
  if (value == null || value == 'null') return '';
  return value.toString();
}

class CustomerMonthData {
  final String monthName;
  final double totalCustomers;

  CustomerMonthData({
    required this.monthName,
    required this.totalCustomers,
  });

  factory CustomerMonthData.fromJson(Map<String, dynamic> json) {
    return CustomerMonthData(
      monthName: s(json['month_name']),
      totalCustomers: d(json['total_customers']),
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
      dayDate: s(json['day_date']),
      dayName: s(json['day_name']),
      totalCustomers: d(json['total_customers']),
    );
  }

  int get dayNum {
    try {
      return DateTime.parse(dayDate).day;
    } catch (_) {
      return 0;
    }
  }
}

