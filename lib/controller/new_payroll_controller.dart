import 'package:flutter/cupertino.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../common/billing_data/local_data.dart';
import '../models/payroll/monthly_unit_payroll.dart';
import '../models/payroll/payroll_user_model.dart';
import '../models/payroll/unit_model.dart';

final pyrlCtr = Get.put(PyrlCtr());

class PyrlCtr extends GetxController {

  void filterAndSort({
    required String searchText,
    required String sortField,
    required String sortOrder
  }) {
    final filtered = unitPayrollList2.where((activity) {
      final matchesSearch = searchText.isEmpty ||
          activity.name.toLowerCase().contains(searchText.toLowerCase());
      return matchesSearch;

    }).toList();
    /// Sorting
    if (sortField == 'rank') {
      filtered.sort((a, b) {
        final comparison =
        a.roleName.toLowerCase().compareTo(b.roleName.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'name') {
      filtered.sort((a, b) {
        final comparison =
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'father') {
      filtered.sort((a, b) {
        final comparison =
        a.fn.toLowerCase().compareTo(b.fn.toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'no') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.phoneNo).compareTo(int.parse(b.phoneNo));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'uan') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.pfNo).compareTo(int.parse(b.pfNo));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'dob') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.dob).compareTo(int.parse(b.dob));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'doj') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.doj).compareTo(int.parse(b.doj));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'esino') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.esiNo).compareTo(int.parse(b.esiNo));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'salwages') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.esiWagesAmt).compareTo(int.parse(b.esiWagesAmt));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'pfwages') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.pfWagesAmt).compareTo(int.parse(b.pfWagesAmt));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'duty') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.duty).compareTo(int.parse(b.duty));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'ot') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.ot).compareTo(int.parse(b.ot));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'basic') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.basic).compareTo(int.parse(b.basic));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'hra') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.hra).compareTo(int.parse(b.hra));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'earn') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.total).compareTo(int.parse(b.total));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'advance') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.advance).compareTo(int.parse(b.advance));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'uniform') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.uniform).compareTo(int.parse(b.uniform));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'penalty') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.penalty).compareTo(int.parse(b.penalty));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'bonus') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.bonus2).compareTo(int.parse(b.bonus2));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'fc') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.food).compareTo(int.parse(b.food));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'esi') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.esi).compareTo(int.parse(b.esi));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'pf') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.pf).compareTo(int.parse(b.pf));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'ded') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.deduction).compareTo(int.parse(b.deduction));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }else if (sortField == 'net') {
      filtered.sort((a, b) {
        final comparison =
        int.parse(a.netAmount).compareTo(int.parse(b.netAmount));
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    unitPayrollList.assignAll(filtered);
  }
  RxList<RolePayrollSetting> settingList=<RolePayrollSetting>[].obs;
  void addSetting(){
    settingList.add(RolePayrollSetting(
          perDay: TextEditingController(),
          leave: TextEditingController(),
          gravity: TextEditingController(),
          adminCharges: TextEditingController(),
          optionSalary: TextEditingController(),
          salary: TextEditingController(),
          basic: TextEditingController(),
          hra: TextEditingController(),
          da: TextEditingController(),
          nH: TextEditingController(),
          sH: TextEditingController(),
          oH: TextEditingController(),
          bonus: TextEditingController(),
          esi: TextEditingController(),
          pf: TextEditingController(),
          tds: TextEditingController(),
          pt: TextEditingController(),
          deduction: TextEditingController(),
          totalAmt: TextEditingController(),
          netPay: TextEditingController(),
          pfWages: TextEditingController(),
          esiWages: TextEditingController(),
          convin: TextEditingController(),
          monthlyWages: true
      ));
    pyrlCtr.editIndex.value=settingList.length-1;
    print("pyrlCtr.editIndex.value ${pyrlCtr.editIndex.value}");
    print("settingList.length ${settingList.length}");
  }
  void sorting({
    required String sortField,
    required String sortOrder
  }) {
    /// Sorting
    // if (sortField == 'type') {
    //   settingList.sort((a, b) {
    //     final comparison =
    //     a.monthlyWages==true?"Monthly Wages":"Daily Wages".toLowerCase().compareTo(b.monthlyWages==true?"Monthly Wages":"Daily Wages".toLowerCase());
    //     return sortOrder == 'asc' ? comparison : -comparison;
    //   });
    // }
    // else
      if (sortField == 'role') {
      settingList.sort((a, b) {
        final comparison =
        a.roleName.toString().toLowerCase().compareTo(b.roleName.toString().toLowerCase());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    else if (sortField == 'salary') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.salary.text) ?? 0;
          final bSalary = int.tryParse(b.salary.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'basic') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.basic.text) ?? 0;
          final bSalary = int.tryParse(b.basic.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'da') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.da.text) ?? 0;
          final bSalary = int.tryParse(b.da.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'hra') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.hra.text) ?? 0;
          final bSalary = int.tryParse(b.hra.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'pf') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.pf.text) ?? 0;
          final bSalary = int.tryParse(b.pf.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'pf') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.esi.text) ?? 0;
          final bSalary = int.tryParse(b.esi.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'bonus') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.bonus.text) ?? 0;
          final bSalary = int.tryParse(b.bonus.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'lwf') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.tds.text) ?? 0;
          final bSalary = int.tryParse(b.tds.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'nh') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.nH.text) ?? 0;
          final bSalary = int.tryParse(b.nH.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'sh') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.sH.text) ?? 0;
          final bSalary = int.tryParse(b.sH.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'oh') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.oH.text) ?? 0;
          final bSalary = int.tryParse(b.oH.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'pt') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.pt.text) ?? 0;
          final bSalary = int.tryParse(b.pt.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'pfwages') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.pfWages.text) ?? 0;
          final bSalary = int.tryParse(b.pfWages.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'esiwages') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.esiWages.text) ?? 0;
          final bSalary = int.tryParse(b.esiWages.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'dedu') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.deduction.text) ?? 0;
          final bSalary = int.tryParse(b.deduction.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'total') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.totalAmt.text) ?? 0;
          final bSalary = int.tryParse(b.totalAmt.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }else if (sortField == 'net') {
        settingList.sort((a, b) {
          final aSalary = int.tryParse(a.netPay.text) ?? 0;
          final bSalary = int.tryParse(b.netPay.text) ?? 0;
          final comparison = aSalary.compareTo(bSalary);
          return sortOrder == 'asc' ? comparison : -comparison;
        });
    }
  }
  var selectedSettingIds = <String>[].obs;
  void selectAllCalls() {
    selectedSettingIds.assignAll(settingList.map((e) => e.id.toString()).toList());
  }
  void unselectAllCalls() {
    selectedSettingIds.clear();
  }
  bool isCheckedRecordCall(String id) {
    return selectedSettingIds.contains(id);
  }
  void toggleRecordSelectionCall(String id) {
    if (selectedSettingIds.contains(id)) {
      selectedSettingIds.remove(id);
    } else {
      selectedSettingIds.add(id);
    }
  }
  var saveMonth,year,end;
TextEditingController noOfWorkingDay =TextEditingController();
var getUnits=true.obs;
var isAdd=false.obs;
var getData=true.obs;
var isStored="".obs;
var monthCount=0.obs;
var editIndex=0.obs;
var lastDate,start;
DateTime selected = DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day);
var startDate="".obs,endDate="".obs,month=DateFormat("MMMM yyyy").format(DateTime.now()).obs;
RxList<units> unitList=<units>[].obs;
dynamic unitName,empName;
RxList<UnitPayroll> unitPayrollList=<UnitPayroll>[].obs;
RxList<UnitPayroll> unitPayrollList2=<UnitPayroll>[].obs;
TextEditingController duty=TextEditingController();
TextEditingController advance=TextEditingController();
TextEditingController penalty=TextEditingController();
TextEditingController uniform=TextEditingController();
TextEditingController total=TextEditingController();
RoundedLoadingButtonController submit=RoundedLoadingButtonController();

List<PayrollUserModel> users=<PayrollUserModel>[].obs;

}
