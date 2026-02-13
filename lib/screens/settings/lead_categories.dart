import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';

class LeadCategories extends StatefulWidget {
  const LeadCategories({super.key});

  @override
  State<LeadCategories> createState() => _LeadCategoriesState();
}

class _LeadCategoriesState extends State<LeadCategories> {
  var isEdit=false.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Lead Categories",
                          colors: colorsConst.textColor,
                          size: 20,
                          isCopy: true,
                          isBold: true,
                        ),
                        10.height,
                      ],
                    ),
                    Row(
                      children: [
                        CustomLoadingButton(
                          callback: ()  {
                            utils.addLeadCategoryDialog(context);
                          },
                          height: 30,
                          isLoading: false,
                          backgroundColor: colorsConst.primary,
                          radius: 5,
                          width: 120,
                          isImage: false,
                          text: "Add Category",
                          textColor: Colors.white,
                        ),10.width,
                        if(isEdit.value==true)
                        CustomLoadingButton(
                          callback: () async {
                            if(isEdit.value==false) {
                              controllers.productCtr.reset();
                              utils.snackBar(msg: "Please make changes",
                                  context: context,
                                  color: Colors.red);
                            }else{
                              isEdit.value=false;
                              await apiService.updateCategories(context);
                            }
                          },
                          height: 40,
                          isLoading: true,
                          backgroundColor: colorsConst.primary,
                          radius: 7,
                          width: 120,
                          controller: controllers.productCtr,
                          isImage: false,
                          text: "Save Category",
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                20.height,
            SizedBox(
              width: MediaQuery.of(context).size.width*0.5,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controllers.leadCategoryList.length,
                onReorder: (oldIndex, newIndex) {

                  isEdit.value = true;

                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }

                  // 🔥 Step 1: Move item (IMPORTANT)
                  final item = controllers.leadCategoryList.removeAt(oldIndex);
                  controllers.leadCategoryList.insert(newIndex, item);

                  // 🔥 Step 2: Update lead_status = index
                  for (int i = 0; i < controllers.leadCategoryList.length; i++) {
                    controllers.leadCategoryList[i]["lead_status"] = i.toString();
                  }

                  controllers.update();
                },
                itemBuilder: (context, index) {
                  var data = controllers.leadCategoryList[index];

                  return Padding(
                    key: ValueKey(data["id"]),
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.5,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: customDecoration.baseBackgroundDecoration(
                        color: Colors.white,
                        borderColor: Colors.grey.shade200,
                        radius: 5,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: data["value"],
                              isCopy: false,
                            ),
                            // CustomText(
                            //   text: data["lead_status"].toString(),
                            //   isCopy: false,
                            //   size: 25,
                            //   colors: colorsConst.primary,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ],
            ),
          ))
        ],
      ),
    );
  }
}
