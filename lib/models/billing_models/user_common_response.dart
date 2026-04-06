class CommonUserResponse {
  final bool status;
  final int responseCode;
  final String message;
  final String? customerId; // NEW FIELD

  CommonUserResponse({
    required this.status,
    required this.responseCode,
    required this.message,
    this.customerId,
  });

  factory CommonUserResponse.fromJson(Map<String, dynamic> json) {
    return CommonUserResponse(
      status: json['status'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      message: json['message'] ?? "",
      customerId: json['customerId']?.toString(), // READ customerId safely
    );
  }
}
