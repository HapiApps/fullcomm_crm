import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';

class LeadCategories extends StatefulWidget {
  const LeadCategories({super.key});

  @override
  State<LeadCategories> createState() => _LeadCategoriesState();
}

class _LeadCategoriesState extends State<LeadCategories> {
  var isEdit=false.obs;
  var total=0.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllers.notesController.clear();
      check();
    });
  }
  void check(){
    for(var i=0;i<dashController.leadReport.length;i++){
      total.value+=int.parse(dashController.leadReport[i]["customer_count"].toString());
    }
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
            child: SizedBox(
              width:MediaQuery.of(context).size.width*0.7,
              child: Column(
                children: [
                  20.height,
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
                          CustomText(
                            text: "Add, edit and reorder categories used in the dashboard.",
                            colors: Colors.grey,
                            size: 15,
                            isCopy: true,
                          ),
                          10.height,
                        ],
                      ),
                      Row(
                        children: [
                          if(isEdit.value==true)
                          SizedBox(
                            height:40,
                            child: OutlinedButton(
                                onPressed: ()async{
                                  if(isEdit.value==false) {
                                    controllers.productCtr.reset();
                                    utils.snackBar(msg: "Please make changes",
                                        context: context,
                                        color: Colors.red);
                                  }else{
                                    await apiService.updateCategories(context);
                                  }
                                },
                                child: CustomText(text: "Save Changes", isCopy: false,colors: Colors.black,)),
                          ),
                          10.width,
                          SizedBox(
                            height:40,
                            child: ElevatedButton(
                                onPressed: (){
                                  utils.addLeadCategoryDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: colorsConst.primary
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add,color: Colors.white,),
                                    CustomText(text: "Add Category", isCopy: false)
                                  ],
                                )),
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
                  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.09,
                    decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Container(
                              height: 30,
                              width: 30,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Color(0XFFEBF2FF),radius: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset("assets/images/lead.png",width: 20,height: 20,),
                              )),10.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                CustomText(text: "${controllers.allLeadCategoryList.length}", isCopy: false,isBold: true,),
                                CustomText(text: "Total Categories", isCopy: false,colors: Color(0XFF666666)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.09,
                    decoration: customDecoration.baseBackgroundDecoration(
                        color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Container(
                              height: 30,
                              width: 30,
                              decoration: customDecoration.baseBackgroundDecoration(
                                color: Color(0XFFDCFCE7),radius: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset("assets/images/lead3.png",width: 20,height: 20,),
                              )),10.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(text: "${controllers.leadCategoryList.length}", isCopy: false,colors: Colors.green,isBold: true,),
                              CustomText(text: "Active", isCopy: false,colors: Color(0XFF666666)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.09,
                    decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Container(
                              height: 30,
                              width: 30,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Color(0XFFFEF3C7),radius: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset("assets/images/lead4.png",width: 20,height: 20,),
                              )),10.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(text: "${int.parse(controllers.allLeadCategoryList.length.toString())-int.parse(controllers.leadCategoryList.length.toString())}", isCopy: false,colors: Color(0XFFD97706),isBold: true,),
                              CustomText(text: "In-Active", isCopy: false,colors: Color(0XFF666666)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.09,
                    decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 10,borderColor: Colors.grey.shade200
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Container(
                              height: 30,
                              width: 30,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Color(0XFFF1F5F9),radius: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset("assets/images/lead2.png",width: 20,height: 20,),
                              )),10.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                CustomText(text: "$total", isCopy: false,colors: Color(0XFF666666),isBold: true,),
                                CustomText(text: "Total Leads", isCopy: false,colors: Color(0XFF666666)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
                  20.height,
                  Container(
                    height: 60,
                    width:MediaQuery.of(context).size.width*0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, -1), // top shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/images/lead.png",width: 20,height: 20,),
                              ),
                              CustomText(text: "Categories", isCopy: false,isBold: true,),10.width,
                              Container(
                                decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.grey.shade100,radius: 20,
                                ),
                                child:  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomText(text: "${controllers.allLeadCategoryList.length} Categories", isCopy: false,isBold: true,colors: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width:MediaQuery.of(context).size.width*0.2,
                                height: 30,
                                child: CustomSearchTextField(
                                  // focusNode:focusNode,
                                  hintText: "Search Categories... ",
                                  controller: controllers.notesController,
                                  onChanged: (value) {
                                  },
                                  //onChanged: onSearchChanged,
                                ),
                              ),10.width,
                              OutlinedButton(
                                  onPressed: (){
                                    utils.addLeadCategoryDialog(context);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.add,size: 15,color: Colors.black,),
                                      CustomText(text: "Add", isCopy: false,isBold: true,colors: Colors.black,)
                                    ],
                                  )),10.width
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 45,
                    width:MediaQuery.of(context).size.width*0.8,
                    color: colorsConst.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: "ACTIONS", isCopy: false,isBold: true,colors: Colors.white),
                          Row(
                            children: [
                              CustomText(text: "NAME", isCopy: false,isBold: true,colors: Colors.white),
                              Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15,)
                            ],
                          ),
                          Row(
                            children: [
                              CustomText(text: "ORDER", isCopy: false,isBold: true,colors: Colors.white),
                              Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15,)
                            ],
                          ),
                          CustomText(text: "STATUS", isCopy: false,isBold: true,colors: Colors.white),
                          Row(
                            children: [
                              CustomText(text: "LEADS", isCopy: false,isBold: true,colors: Colors.white),
                              Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    width:MediaQuery.of(context).size.width*0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, -1), // top shadow
                        ),
                      ],
                    ),
                    child: ReorderableListView.builder(
                      // shrinkWrap: true,
                      itemCount: controllers.leadCategoryList.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }

                          final item =
                          controllers.leadCategoryList.removeAt(oldIndex);
                          controllers.leadCategoryList.insert(newIndex, item);

                          // Only update display_order
                          for (int i = 0; i < controllers.leadCategoryList.length; i++) {
                            controllers.leadCategoryList[i].displayOrder = i+1;
                          }
                            isEdit.value = true;
                          // print("${controllers.leadCategoryList}.....");
                          controllers.update();
                          },
                      itemBuilder: (context, index) {
                        var data = controllers.leadCategoryList[index];

                        return Padding(
                          key: ValueKey(data.id),
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width:MediaQuery.of(context).size.width*0.8,
                            decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white,radius: 10,borderColor: Colors.grey.shade200,shadowColor: Colors.grey
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: data.value,
                                    isCopy: false,
                                  ),
                                  CustomText(
                                    text: data.displayOrder.toString(),
                                    isCopy: false,isBold: true,
                                    colors: colorsConst.primary,
                                  ),
                                  CustomText(
                                    text: "Active",
                                    isCopy: false,isBold: true,
                                    colors: colorsConst.primary,
                                  ),CustomText(
                                    text: "190",
                                    isCopy: false,isBold: true,
                                    colors: colorsConst.primary,
                                  ),
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
            ),
          ))
        ],
      ),
    );
  }
}
