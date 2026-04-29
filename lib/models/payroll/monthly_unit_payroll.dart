class UnitPayroll {
  final String? id;
  final String? name;
  final String? unitName;
  final String? month;
  final String? duty;
  final String? advance;
  final String? uniform;
  final String? penalty;
  final String? total;
  final String? deduction;
  final String? netAmount;
  final String? da;
  final String? hra;
  final String? basic;
  final String? salary;
  final String? esi;
  final String? pf;
  final String? empcd;
  final String? ifscCode;
  final String? bankName;
  final String? bkName;
  final String? accNo;
  final String? ot;
  final String? roleName;
  final String? empId;
  final String? pfWages;
  final String? pfWagesAmt;
  final String? esiWages;
  final String? esiWagesAmt;
  final String? dob;
  final String? doj;
  final String? fn;
  final String? phoneNo;
  final String? esiNo;
  final String? pfNo;
  final String? pt;
  final String? nH;
  final String? sH;
  final String? oH;
  final String? aC;
  final String? bonus;
  final String? op;
  final String? bonus2;
  final String? food;

  UnitPayroll({
    this.id,
    this.esi,
    this.pf,
    this.salary,
    this.name,
    this.unitName,
    this.month,
    this.duty,
    this.advance,
    this.uniform,
    this.penalty,
    this.total,
    this.deduction,
    this.netAmount,
    this.da,
    this.hra,
    this.basic,
    this.empcd,
    this.ifscCode,
    this.bankName,
    this.bkName,
    this.accNo,
    this.ot,
    this.roleName,
    this.empId,
    this.pfWages,
    this.pfWagesAmt,
    this.esiWages,
    this.esiWagesAmt,
    this.dob,
    this.doj,
    this.fn,
    this.phoneNo,
    this.esiNo,
    this.pfNo,
    this.pt,
    this.sH,
    this.nH,
    this.oH,
    this.aC,
    this.bonus,
    this.op,
    this.bonus2,
    this.food,
  });

  factory UnitPayroll.fromJson(Map<String, dynamic> json) {
    return UnitPayroll(
      dob: json['dob'],
      doj: json['doj'],
      fn: json['fathername'],
      phoneNo: json['phoneNo'],
      pfWages: json['pf_wages'],
      pfWagesAmt: json['pf_wages_amt'],
      esiWages: json['esi_wages'],
      esiWagesAmt: json['esi_wages_amt'],
      id: json['id'],
      empId: json['emp_id'],
      name: json['name'],
      unitName: json['unit_name'],
      month: json['month'],
      salary: json['salary'],
      duty: json['duty'],
      advance: json['advance'],
      uniform: json['uniform'],
      penalty: json['penalty'],
      total: json['total'],
      netAmount: json['net_amount'],
      deduction: json['deduction'],
      da: json['da'],
      hra: json['hra'],
      basic: json['basic'],
      esi: json['esi'],
      pf: json['pf'],
      empcd: json['emp_cd_1'],
      ifscCode: json['ifsc_code'],
      bankName: json['bank_name'],
      bkName: json['bk_name'],
      accNo: json['acc_no'],
      ot: json['ot'],
      roleName: json['role_name'],
      esiNo: json['esi_no'],
      pfNo: json['pf_no'],
      pt: json['pt'],
      nH: json['n_holidays'],
      sH: json['s_holidays'],
      oH: json['o_holidays'],
      aC: json['admin_charges'],
      op: json['op'],
      bonus: json['bonus'],
      bonus2: json['bonus2'],
      food: json['food'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "unit_name": unitName,
      "month": month,
      "duty": duty.toString(),
      "advance": advance.toString(),
      "uniform": uniform.toString(),
      "penalty": penalty.toString(),
      "total": total.toString(),
      "deduction": deduction.toString(),
      "netAmount": netAmount.toString(),
      "basic": basic.toString(),
      "hra": hra.toString(),
      "da": da.toString(),
      "bonus2": bonus2.toString(),
      "food": food.toString(),
    };
  }
}
