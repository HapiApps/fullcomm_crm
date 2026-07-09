class UnitPayroll {
  String id;
  String name;
  String unitName;
  String month;
  String duty;
  String advance;
  String uniform;
  String penalty;
  String total;
  String deduction;
  String netAmount;
  String da;
  String hra;
  String basic;
  String salary;
  String esi;
  String pf;
  String empcd;
  String ifscCode;
  String bankName;
  String bkName;
  String accNo;
  String ot;
  String roleName;
  String empId;
  String pfWages;
  String pfWagesAmt;
  String esiWages;
  String esiWagesAmt;
  String dob;
  String doj;
  String fn;
  String phoneNo;
  String esiNo;
  String pfNo;
  String pt;
  String nH;
  String sH;
  String oH;
  String aC;
  String bonus;
  String op;
  String bonus2;
  String food;
  String? updatedTs;

  UnitPayroll({
    this.id = "",
    this.name = "",
    this.unitName = "",
    this.month = "",
    this.duty = "",
    this.advance = "",
    this.uniform = "",
    this.penalty = "",
    this.total = "",
    this.deduction = "",
    this.netAmount = "",
    this.da = "",
    this.hra = "",
    this.basic = "",
    this.salary = "",
    this.esi = "",
    this.pf = "",
    this.empcd = "",
    this.ifscCode = "",
    this.bankName = "",
    this.bkName = "",
    this.accNo = "",
    this.ot = "",
    this.roleName = "",
    this.empId = "",
    this.pfWages = "",
    this.pfWagesAmt = "",
    this.esiWages = "",
    this.esiWagesAmt = "",
    this.dob = "",
    this.doj = "",
    this.fn = "",
    this.phoneNo = "",
    this.esiNo = "",
    this.pfNo = "",
    this.pt = "",
    this.nH = "",
    this.sH = "",
    this.oH = "",
    this.aC = "",
    this.bonus = "",
    this.op = "",
    this.bonus2 = "",
    this.food = "",
    this.updatedTs = "",
  });

  factory UnitPayroll.fromJson(Map<String, dynamic> json) {
    return UnitPayroll(
      id: json['id']?.toString() ?? "",
      empId: json['emp_id']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      unitName: json['unit_name']?.toString() ?? "",
      month: json['month']?.toString() ?? "",
      salary: json['salary']?.toString() ?? "",
      duty: json['duty']?.toString() ?? "",
      advance: json['advance']?.toString() ?? "",
      uniform: json['uniform']?.toString() ?? "",
      penalty: json['penalty']?.toString() ?? "",
      total: json['total']?.toString() ?? "",
      netAmount: json['net_amount']?.toString() ?? "",
      deduction: json['deduction']?.toString() ?? "",
      da: json['da']?.toString() ?? "",
      hra: json['hra']?.toString() ?? "",
      basic: json['basic']?.toString() ?? "",
      esi: json['esi']?.toString() ?? "",
      pf: json['pf']?.toString() ?? "",
      empcd: json['emp_cd_1']?.toString() ?? "",
      ifscCode: json['ifsc_code']?.toString() ?? "",
      bankName: json['bank_name']?.toString() ?? "",
      bkName: json['bk_name']?.toString() ?? "",
      accNo: json['acc_no']?.toString() ?? "",
      ot: json['ot']?.toString() ?? "",
      roleName: json['role_name']?.toString() ?? "",
      pfWages: json['pf_wages']?.toString() ?? "",
      pfWagesAmt: json['pf_wages_amt']?.toString() ?? "",
      esiWages: json['esi_wages']?.toString() ?? "",
      esiWagesAmt: json['esi_wages_amt']?.toString() ?? "",
      dob: json['dob']?.toString() ?? "",
      doj: json['doj']?.toString() ?? "",
      fn: json['fathername']?.toString() ?? "",
      phoneNo: json['phoneNo']?.toString() ?? "",
      esiNo: json['esi_no']?.toString() ?? "",
      pfNo: json['pf_no']?.toString() ?? "",
      pt: json['pt']?.toString() ?? "",
      nH: json['n_holidays']?.toString() ?? "",
      sH: json['s_holidays']?.toString() ?? "",
      oH: json['o_holidays']?.toString() ?? "",
      aC: json['admin_charges']?.toString() ?? "",
      bonus: json['bonus']?.toString() ?? "",
      op: json['op']?.toString() ?? "",
      bonus2: json['bonus2']?.toString() ?? "",
      food: json['food']?.toString() ?? "",
      updatedTs: json['updated_ts']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "updated_ts": updatedTs,
      "id": id,
      "emp_id": empId,
      "name": name,
      "unit_name": unitName,
      "month": month,
      "salary": salary,
      "duty": duty,
      "advance": advance,
      "uniform": uniform,
      "penalty": penalty,
      "total": total,
      "deduction": deduction,
      "net_amount": netAmount,
      "basic": basic,
      "hra": hra,
      "da": da,
      "esi": esi,
      "pf": pf,
      "bonus2": bonus2,
      "food": food,
      "pt": pt,
      "n_holidays": nH,
      "s_holidays": sH,
      "o_holidays": oH,
      "admin_charges": aC,
      "bonus": bonus,
      "op": op,
    };
  }
}