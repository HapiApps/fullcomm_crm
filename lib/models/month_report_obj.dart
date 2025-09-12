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
