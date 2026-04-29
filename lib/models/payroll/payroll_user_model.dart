import 'package:flutter/cupertino.dart';

class PayrollUserModel {
  String empId = "";
  String name = "";
  String? code = "";
  String? rank = "";

  String? salary = "";
  String? basicCalc = "";
  String? daCalc = "";
  String? esiCalc = "";
  String? pfCalc = "";
  String? workingDays = "31";

  TextEditingController duty = TextEditingController();
  TextEditingController ot = TextEditingController();
  TextEditingController advance = TextEditingController();
  TextEditingController penalty = TextEditingController();
  TextEditingController uniform = TextEditingController();
  TextEditingController total = TextEditingController();
  TextEditingController deduction = TextEditingController();
  TextEditingController food = TextEditingController();
  TextEditingController bonus2 = TextEditingController();
  String basic = "";
  String da = "";
  String hra = "";
  String esi = "";
  String pf = "";
  String netAmount = "";
  String? active;
  String? esiWagesAmt;
  String? pfWagesAmt;
  final String newE;
  PayrollUserModel({
    required this.empId,
    required this.name,
    this.code,
    this.rank,

    this.salary,
    this.basicCalc,
    this.daCalc,
    this.esiCalc,
    this.pfCalc,
    this.esiWagesAmt,
    this.pfWagesAmt,
    this.workingDays,

    required this.duty,
    required this.ot,
    required this.advance,
    required this.penalty,
    required this.uniform,
    required this.total,
    required this.basic,
    required this.da,
    required this.hra,
    required this.esi,
    required this.pf,
    required this.deduction,
    required this.netAmount,
    required this.food,
    required this.bonus2,
    this.active="1",
    required this.newE,
  });

  factory PayrollUserModel.fromJson(Map<String, dynamic> json) => PayrollUserModel(
    newE: json['new'],
    active: json['active'],
    empId: json["emp_id"],
    name: json["name"],
    code: json["code"],
    rank: json["rank"],

    salary: json["salary"],
    basicCalc: json["basicCalc"],
    daCalc: json["daCalc"],
    esiCalc: json["esiCalc"],
    pfCalc: json["pfCalc"],
    workingDays: json["workingDays"],

    duty: TextEditingController(text: json["duty"]),
    ot: TextEditingController(text: json["ot"]),
    advance: TextEditingController(text: json["advance"]),
    penalty: TextEditingController(text: json["penalty"]),
    uniform: TextEditingController(text: json["uniform"]),
    total: TextEditingController(text: json["total"]),
    deduction: TextEditingController(text: json["deduction"]),
    food: TextEditingController(text: json["food"]),
    bonus2: TextEditingController(text: json["bonus2"]),
    basic: json["basic"],
    da: json["da"],
    hra: json["hra"],
    esi: json["esi"],
    pf: json["pf"],
    netAmount: json["net_amount"],
    esiWagesAmt: json["esi_wages_amt"],
    pfWagesAmt: json["pf_wages_amt"],
  );
  /// ✅ Convert to Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      "emp_id": empId,
      "name": name,

      "salary": salary,
      "basicCalc": basicCalc,
      "daCalc": daCalc,
      "esiCalc": esiCalc,
      "pfCalc": pfCalc,
      "workingDays": workingDays,

      "duty": duty.text,
      "ot": ot.text,
      "advance": advance.text,
      "penalty": penalty.text,
      "uniform": uniform.text,
      "total": total.text,
      "deduction": deduction.text,
      "food": food.text,
      "bonus2": bonus2.text,
      "basic": basic,
      "da": da,
      "hra": hra,
      "esi": esi,
      "pf": pf,
      "esi_wages_amt": esiWagesAmt,
      "pf_wages_amt": pfWagesAmt,
      "net_amount": netAmount,
      "new": newE,
      "active": active,
    };
  }
}