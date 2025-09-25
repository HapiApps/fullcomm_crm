class CommonResponse {
  int? responseCode;
  dynamic result;
  String? responseMsg;

  CommonResponse({
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) => CommonResponse(
    responseCode: json["responseCode"],
    result: json["result"],
    responseMsg: json["responseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "responseCode": responseCode,
    "result": result,
    "responseMsg": responseMsg,
  };
}