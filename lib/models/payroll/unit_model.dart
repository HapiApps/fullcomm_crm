import 'package:flutter/material.dart';
class units {
  // Existing fields...
  String? unit_name;
  String? unit_id;
  String? leader_name;
  String? leader_id;
  String? address_id;
  String? unit_code;
  String? selfie_req;
  String? home_unit;
  String? shifts;
  String? address_line_1;
  String? address_line_2;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? lat;
  String? lng;
  String? added_by;
  String? password;
  String? mobile_number;
  String? active;
  String? id;
  String? emp_names;
  String? leaderNumber;
  String? unit_emps;
  String? landmark;
  String? gstNumber;
  String? panNumber;
  String? workOrderNumber;
  String? email;
  String? basicDa;
  String? hra;
  String? allowance;
  String? bonus;
  String? nHolidays;
  String? sHolidays;
  String? oHolidays;
  String? esi;
  String? pf;
  String? tds;
  String? pt;
  String? netAmt;
  String? deduction;
  String? totalAmt;
  String? salary;
  String? roleId;
  String? pfWages;
  String? esiWages;
  String? workingDays;
  String? updatedTs;
  String? teamId;
  String? teamName;
  String? totalCount;
  String? lastChatTime;

  // New payroll fields as List<String>
  List<String>? payrollRoleIds;
  List<String>? payrollSalaries;
  List<String>? payrollBasic;
  List<String>? payrollHra;
  List<String>? payrollAllowance;
  List<String>? payrollBonus;
  List<String>? payrollNHolidays;
  List<String>? payrollSHolidays;
  List<String>? payrollOHolidays;
  List<String>? payrollEsi;
  List<String>? payrollPf;
  List<String>? payrollTds;
  List<String>? payrollPt;
  List<String>? payrollNetAmt;
  List<String>? payrollDeduction;
  List<String>? payrollTotalAmt;
  List<String>? payrollPfWages;
  List<String>? payrollEsiWages;
  List<String>? payrollWorkingDays;
  List<String>? payrollIds;
  List<String>? payrollRIds;
  List<String>? payrollWeekOff;
  List<String>? payrollAdminCharges;
  List<String>? payrollGravity;
  List<String>? payrollConvin;
  List<String>? payrollLeave;
  List<String>? payrollOSalary;
  List<String>? payrollPerDay;
  List<String>? monthlyWages;

  units({
    this.pfWages,
    this.esiWages,
    this.salary,
    this.totalAmt,
    this.deduction,
    this.netAmt,
    this.pt,
    this.tds,
    this.pf,
    this.esi,
    this.oHolidays,
    this.sHolidays,
    this.nHolidays,
    this.bonus,
    this.allowance,
    this.hra,
    this.basicDa,
    this.email,
    this.gstNumber,
    this.panNumber,
    this.workOrderNumber,
    this.unit_name,
    this.unit_id,
    this.leader_name,
    this.leader_id,
    this.address_id,
    this.unit_code,
    this.selfie_req,
    this.shifts,
    this.address_line_1,
    this.address_line_2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.lat,
    this.lng,
    this.added_by,
    this.password,
    this.home_unit,
    this.mobile_number,
    this.id,
    this.emp_names,
    this.leaderNumber,
    this.unit_emps,
    this.landmark,
    this.active,
    this.workingDays,
    this.updatedTs,
    this.roleId,
    // Payroll
    this.payrollRoleIds,
    this.payrollSalaries,
    this.payrollBasic,
    this.payrollHra,
    this.payrollAllowance,
    this.payrollBonus,
    this.payrollNHolidays,
    this.payrollSHolidays,
    this.payrollOHolidays,
    this.payrollEsi,
    this.payrollPf,
    this.payrollTds,
    this.payrollPt,
    this.payrollNetAmt,
    this.payrollDeduction,
    this.payrollTotalAmt,
    this.payrollPfWages,
    this.payrollEsiWages,
    this.payrollWorkingDays,
    this.payrollIds,
    this.payrollRIds,
    this.payrollWeekOff,
    this.payrollAdminCharges,
    this.payrollGravity,
    this.payrollConvin,
    this.payrollLeave,
    this.payrollOSalary,
    this.payrollPerDay,
    this.monthlyWages,
    this.teamId,
    this.teamName,
    this.totalCount,
    this.lastChatTime,
  });

  factory units.fromJson(Map<String, dynamic> json) {
    List<String>? splitString(String? value) {
      return value != null ? value.split(',') : null;
    }

    return units(
      updatedTs: json["updated_ts"],
      roleId: json["role_id"],
      pfWages: json["pf_wages"],
      esiWages: json["esi_wages"],
      workingDays: json["working_days"],
      totalAmt: json["total_amt"],
      deduction: json["deduction"],
      netAmt: json["net_amt"],
      pt: json["pt"],
      tds: json["tds"],
      pf: json["pf"],
      esi: json["esi"],
      oHolidays: json["o_holidays"],
      sHolidays: json["s_holidays"],
      nHolidays: json["n_holidays"],
      bonus: json["bonus"],
      allowance: json["allowance"],
      hra: json["hra"],
      basicDa: json["basic_da"],
      salary: json["salary"],
      email: json["email"],
      workOrderNumber: json["work_order_number"],
      panNumber: json["pan_number"],
      gstNumber: json["gst_number"],
      landmark: json["land_mark"],
      unit_emps: json["unit_emps"],
      emp_names: json["emp_names"],
      id: json["id"],
      unit_name: json["unit_name"],
      unit_id: json["unit_id"],
      leader_name: json["leader_name"],
      leader_id: json["leader_id"],
      address_id: json["address_id"],
      unit_code: json["unit_code"],
      selfie_req: json["selfie_req"],
      shifts: json["shifts"],
      address_line_1: json["address_line_1"],
      address_line_2: json["address_line_2"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      pincode: json["pincode"],
      lat: json["lat"],
      lng: json["lng"],
      added_by: json["added_by"],
      password: json["password"],
      home_unit: json["home_unit"],
      mobile_number: json["mobile_number"],
      active: json["active"],
      leaderNumber: json["leader_mobile_number"],

      // Payroll fields
      payrollIds: splitString(json["payroll_ids"]),
      payrollRIds: splitString(json["payroll_roleids"]),
      payrollRoleIds: splitString(json["payroll_role_ids"]),
      payrollSalaries: splitString(json["payroll_salaries"]),
      payrollBasic: splitString(json["payroll_basic"]),
      payrollHra: splitString(json["payroll_hra"]),
      payrollAllowance: splitString(json["payroll_allowance"]),
      payrollBonus: splitString(json["payroll_bonus"]),
      payrollNHolidays: splitString(json["payroll_n_holidays"]),
      payrollSHolidays: splitString(json["payroll_s_holidays"]),
      payrollOHolidays: splitString(json["payroll_o_holidays"]),
      payrollEsi: splitString(json["payroll_esi"]),
      payrollPf: splitString(json["payroll_pf"]),
      payrollTds: splitString(json["payroll_tds"]),
      payrollPt: splitString(json["payroll_pt"]),
      payrollNetAmt: splitString(json["payroll_net_amt"]),
      payrollDeduction: splitString(json["payroll_deduction"]),
      payrollTotalAmt: splitString(json["payroll_total_amt"]),
      payrollPfWages: splitString(json["payroll_pf_wages"]),
      payrollEsiWages: splitString(json["payroll_esi_wages"]),
      payrollWorkingDays: splitString(json["payroll_working_days"]),
      payrollWeekOff: splitString(json["payroll_week_off"]),
      payrollAdminCharges: splitString(json["payroll_admin_charges"]),
      payrollGravity: splitString(json["payroll_gravity"]),
      payrollConvin: splitString(json["payroll_convin"]),
      payrollLeave: splitString(json["payroll_leave"]),
      payrollOSalary: splitString(json["payroll_optional_salary"]),
      payrollPerDay: splitString(json["payroll_per_day"]),
      monthlyWages: splitString(json["payroll_monthlyWages"]),
      teamId: json["team_id"],
      teamName: json["team_name"],
      totalCount: json["total_count"],
      lastChatTime: json["last_chat_time"],
    );
  }
}

class RolePayrollSetting {
  String? id;
  String? roleId;
  String? roleName;
  dynamic role;
  String? workingDays;
  String? active;
  String? newE;
  bool monthlyWages;
  bool? weekOff;
  bool? saturday;
  bool? sunday;

  // Payroll fields (using TextEditingController for text inputs)
  TextEditingController salary = TextEditingController();
  TextEditingController perDay = TextEditingController();
  TextEditingController leave = TextEditingController();
  TextEditingController optionSalary = TextEditingController();
  TextEditingController adminCharges = TextEditingController();
  TextEditingController convin = TextEditingController();
  TextEditingController gravity = TextEditingController();
  TextEditingController basic = TextEditingController();
  TextEditingController hra = TextEditingController();
  TextEditingController da = TextEditingController();
  TextEditingController nH = TextEditingController(); // Normal Hours
  TextEditingController sH = TextEditingController(); // Sunday Hours
  TextEditingController oH = TextEditingController(); // Overtime Hours
  TextEditingController bonus = TextEditingController();
  TextEditingController esi = TextEditingController();
  TextEditingController pf = TextEditingController();
  TextEditingController tds = TextEditingController();
  TextEditingController pt = TextEditingController();
  TextEditingController deduction = TextEditingController();
  TextEditingController totalAmt = TextEditingController();
  TextEditingController netPay = TextEditingController();
  TextEditingController pfWages = TextEditingController();
  TextEditingController esiWages = TextEditingController();

  RolePayrollSetting({
    this.id,
    this.role,
    this.roleId,
    this.roleName,
    this.workingDays="31",
    this.active = "1",
    this.newE="0",
    required this.monthlyWages,
    TextEditingController? salary,
    TextEditingController? perDay,
    TextEditingController? leave,
    TextEditingController? gravity,
    TextEditingController? optionSalary,
    TextEditingController? adminCharges,
    TextEditingController? convin,
    TextEditingController? basic,
    TextEditingController? hra,
    TextEditingController? da,
    TextEditingController? nH,
    TextEditingController? sH,
    TextEditingController? oH,
    TextEditingController? bonus,
    TextEditingController? esi,
    TextEditingController? pf,
    TextEditingController? tds,
    TextEditingController? pt,
    TextEditingController? deduction,
    TextEditingController? totalAmt,
    TextEditingController? netPay,
    TextEditingController? pfWages,
    TextEditingController? esiWages,
    bool? weekOff=false,
    bool? saturday=false,
    bool? sunday=false,
  }) {
    // Initialize controllers if passed
    this.salary = salary ?? this.salary;
    this.perDay = perDay ?? this.perDay;
    this.leave = leave ?? this.leave;
    this.gravity = gravity ?? this.gravity;
    this.optionSalary = optionSalary ?? this.optionSalary;
    this.adminCharges = adminCharges ?? this.adminCharges;
    this.convin = convin ?? this.convin;
    this.basic = basic ?? this.basic;
    this.hra = hra ?? this.hra;
    this.da = da ?? this.da;
    this.nH = nH ?? this.nH;
    this.sH = sH ?? this.sH;
    this.oH = oH ?? this.oH;
    this.bonus = bonus ?? this.bonus;
    this.esi = esi ?? this.esi;
    this.pf = pf ?? this.pf;
    this.tds = tds ?? this.tds;
    this.pt = pt ?? this.pt;
    this.deduction = deduction ?? this.deduction;
    this.totalAmt = totalAmt ?? this.totalAmt;
    this.netPay = netPay ?? this.netPay;
    this.pfWages = pfWages ?? this.pfWages;
    this.esiWages = esiWages ?? this.esiWages;
    this.weekOff = weekOff ?? this.weekOff;
    this.saturday = saturday ?? this.saturday;
    this.sunday = sunday ?? this.sunday;
    monthlyWages = monthlyWages;
  }

  /// ✅ Factory: from JSON
  factory RolePayrollSetting.fromJson(Map<String, dynamic> json) {
    return RolePayrollSetting(
      id: json["id"]?.toString(),
      roleId: json["roleId"]?.toString(),
      roleName: json["roleName"]?.toString(),
      role: json["role"],
      workingDays: json["working_days"]?.toString(),
      active: json["active"]?.toString() ?? "1",
      newE: json["new"]?.toString(),
      salary: TextEditingController(text: json["salary"]?.toString() ?? ""),
      adminCharges: TextEditingController(text: json["admin_charges"]?.toString() ?? ""),
      optionSalary: TextEditingController(text: json["optional_salary"]?.toString() ?? ""),
      convin: TextEditingController(text: json["convin"]?.toString() ?? ""),
      leave: TextEditingController(text: json["leave"]?.toString() ?? ""),
      gravity: TextEditingController(text: json["gravity"]?.toString() ?? ""),
      perDay: TextEditingController(text: json["per_day"]?.toString() ?? ""),
      basic: TextEditingController(text: json["basic"]?.toString() ?? ""),
      hra: TextEditingController(text: json["hra"]?.toString() ?? ""),
      da: TextEditingController(text: json["da"]?.toString() ?? ""),
      nH: TextEditingController(text: json["nh"]?.toString() ?? ""),
      sH: TextEditingController(text: json["sh"]?.toString() ?? ""),
      oH: TextEditingController(text: json["oh"]?.toString() ?? ""),
      bonus: TextEditingController(text: json["bonus"]?.toString() ?? ""),
      esi: TextEditingController(text: json["esi"]?.toString() ?? ""),
      pf: TextEditingController(text: json["pf"]?.toString() ?? ""),
      tds: TextEditingController(text: json["tds"]?.toString() ?? ""),
      pt: TextEditingController(text: json["pt"]?.toString() ?? ""),
      deduction: TextEditingController(text: json["deduction"]?.toString() ?? ""),
      totalAmt: TextEditingController(text: json["total_amt"]?.toString() ?? ""),
      netPay: TextEditingController(text: json["net_pay"]?.toString() ?? ""),
      pfWages: TextEditingController(text: json["pf_wages"]?.toString() ?? ""),
      esiWages: TextEditingController(text: json["esi_wages"]?.toString() ?? ""),
      weekOff: json["week_off"]!,
      sunday: json["sunday"]!,
      saturday: json["saturday"]!,
      monthlyWages: json["monthlyWages"]!,
    );
  }

  /// ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "role_id": roleId,
      "role_name": roleName,
      "role": role,
      "working_days": workingDays,
      "active": active,
      "new": newE,
      "salary": salary.text,
      "per_day": perDay.text,
      "gravity": gravity.text,
      "leave": leave.text,
      "optional_salary": optionSalary.text,
      "admin_charges": adminCharges.text,
      "convin": convin.text,
      "basic_da": basic.text,
      "hra": hra.text,
      "allowance": da.text,
      "n_holidays": nH.text,
      "s_holidays": sH.text,
      "o_holidays": oH.text,
      "bonus": bonus.text,
      "esi": esi.text,
      "pf": pf.text,
      "tds": tds.text,
      "pt": pt.text,
      "deduction": deduction.text,
      "total_amt": totalAmt.text,
      "net_amt": netPay.text,
      "pf_wages": pfWages.text,
      "esi_wages": esiWages.text,
      "newE": newE,
      "active": active,
      "week_off": "${weekOff==false?"0":"1"}||${sunday==false?"0":"1"}||${saturday==false?"0":"1"}",
      "monthlyWages": monthlyWages==false?"0":"1"
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
