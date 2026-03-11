import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/constant/assets_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/utilities/jwt_storage.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
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
  final FocusNode name = FocusNode();
  var isEdit=false.obs;
  var total=0.obs;
  var add=false.obs;
  var edit=false.obs;
  var editIndex=100.obs;
  RxList<LeadStatusModel> allLead=<LeadStatusModel>[].obs;
  RxList<LeadStatusModel> lead=<LeadStatusModel>[].obs;
  List<FocusNode> nameFocusList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(controllers.allLeadCategoryList.isEmpty){
      apiService.getAllLeadCategories();
    }
    nameFocusList = List.generate(
      controllers.allLeadCategoryList.length,
          (index) => FocusNode(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allLead.value=controllers.allLeadCategoryList;
      lead.value=controllers.leadCategoryList;
      controllers.notesController.clear();
      check();
    });
  }
  void check(){
    for(var i=0;i<controllers.allLeadCategoryList.length;i++){
      total.value+=int.parse(controllers.allLeadCategoryList[i].totalLead.toString());
    }
  }
  @override
  void dispose() {
    name.dispose();
    super.dispose();
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
                  10.height,
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
                                  if(controllers.leadCategoryList.length!=10){
                                    add.value=true;
                                    edit.value=false;
                                    editIndex.value=100;
                                    controllers.emailMessageCtr.clear();
                                    FocusScope.of(context).requestFocus(name);
                                  }else{
                                    utils.snackBar(context: context, msg: "Maximum 10 lead categories allowed.", color: Colors.red);
                                  }
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
                  10.height,
                  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.12,
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
                    width: MediaQuery.of(context).size.width*0.12,
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
                    width: MediaQuery.of(context).size.width*0.12,
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
                    width: MediaQuery.of(context).size.width*0.12,
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
                  10.height,
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
                                padding: const EdgeInsets.all(10.0),
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
                                    final suggestions=allLead.where(
                                            (user){
                                          final customerName = user.value.toString().toLowerCase();
                                          final input = value.toString().toLowerCase().trim();
                                          return customerName.contains(input);
                                        }).toList();
                                    controllers.allLeadCategoryList.value=suggestions;
                                  },
                                  //onChanged: onSearchChanged,
                                ),
                              ),10.width,
                              OutlinedButton(
                                  onPressed: (){
                                    if(controllers.leadCategoryList.length!=10){
                                      add.value=true;
                                      edit.value=false;
                                      editIndex.value=100;
                                      controllers.emailMessageCtr.clear();
                                      FocusScope.of(context).requestFocus(name);
                                    }else{
                                      utils.snackBar(context: context, msg: "Maximum 10 lead categories allowed.", color: Colors.red);
                                    }
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
                    height: 40,
                    width:MediaQuery.of(context).size.width*0.8,
                    color: colorsConst.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                              child:Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                  ),
                                  10.width,
                                  SizedBox(
                                    width: 140,
                                    child: Row(
                                      children: [
                                        CustomText(text: "NAME", isCopy: false,isBold: true,colors: Colors.white),
                                        Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15,)
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                CustomText(text: "ORDER", isCopy: false,isBold: true,colors: Colors.white),
                                Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15,)
                              ],
                            ),
                          ),
                          SizedBox(
                              width: 100,
                              child: CustomText(text: "STATUS", isCopy: false,isBold: true,colors: Colors.white)),
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                CustomText(text: "LEADS", isCopy: false,isBold: true,colors: Colors.white),
                                Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15)
                              ],
                            ),
                          ),
                          SizedBox(
                              width: 100,
                              child: CustomText(text: "ACTIONS", isCopy: false,isBold: true,colors: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.6,
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
                    child: Column(
                      children: [
                        Expanded(
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false, // default icon hide
                            // shrinkWrap: true,
                            itemCount: controllers.allLeadCategoryList.length,
                            // onReorder: (oldIndex, newIndex) async {
                            //   if (newIndex > oldIndex) {
                            //     newIndex -= 1;
                            //   }
                            //
                            //   final item =
                            //   controllers.allLeadCategoryList.removeAt(oldIndex);
                            //   controllers.allLeadCategoryList.insert(newIndex, item);
                            //
                            //   // Only update display_order
                            //   for (int i = 0; i < controllers.allLeadCategoryList.length; i++) {
                            //     controllers.allLeadCategoryList[i].displayOrder = i+1;
                            //   }
                            //   isEdit.value = true;
                            //   // print("${controllers.leadCategoryList}.....");
                            //   controllers.update();
                            // },
                            onReorder: (oldIndex, newIndex) async {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }

                              final item =
                              controllers.allLeadCategoryList.removeAt(oldIndex);
                              controllers.allLeadCategoryList.insert(newIndex, item);

                              // update display_order in allLeadCategoryList
                              for (int i = 0; i < controllers.allLeadCategoryList.length; i++) {
                                controllers.allLeadCategoryList[i].displayOrder = i + 1;
                                //
                                // // update same id in leadCategoryList
                                // int index = controllers.leadCategoryList.indexWhere(
                                //         (e) => e.id == controllers.allLeadCategoryList[i].id);
                                //
                                // if (index != -1) {
                                //   controllers.leadCategoryList[index].displayOrder = i + 1;
                                // }
                              }

                              isEdit.value = true;
                              controllers.update();
                            },
                            itemBuilder: (context, index) {
                              var data = controllers.allLeadCategoryList[index];

                              return Padding(
                                key: ValueKey(data.id),
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                                child: Container(
                                  color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width:50,
                                              child: data.active=="1"?ReorderableDragStartListener(
                                                index: index,
                                                child: const Icon(Icons.menu),
                                              ):0.width,
                                            ),
                                            10.width,
                                            SizedBox(
                                              width:140,
                                              child: Obx(()=>editIndex.value==index?
                                              SizedBox(
                                                width:140,
                                                child: TextField(
                                                  focusNode: nameFocusList[editIndex.value],
                                                  controller: controllers.emailMessageCtr,
                                                  decoration: InputDecoration(
                                                    border: UnderlineInputBorder(),
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 14,
                                                    ),
                                                  ),
                                                  onEditingComplete: (){
                                                    if (controllers.emailMessageCtr.text.trim().isEmpty) {
                                                      utils.snackBar(
                                                        context: context,
                                                        msg: "Please enter lead category",
                                                        color: Colors.red,
                                                      );
                                                      controllers.productCtr.reset();
                                                      return;
                                                    }else{
                                                      addCategories(context,"update",data.id,index);
                                                    }
                                                  },
                                                ),
                                              ):Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: data.value,
                                                    isCopy: false,
                                                  ),
                                                ],
                                              ),)
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: CustomText(
                                          text: data.displayOrder.toString(),
                                          isCopy: false,isBold: true,
                                          colors: colorsConst.primary,
                                        ),
                                      ),
                                      InkWell(
                                        // onTap: (){
                                        //   controllers.manageLead(context,data.id,data.active=="1"?2:1);
                                        // },
                                        child: Container(
                                          decoration: customDecoration.baseBackgroundDecoration(
                                              color: data.active.toString()=="1"?Colors.green.shade100:Colors.orangeAccent.shade100,radius: 10
                                          ),
                                          height: 20,
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.circle,size: 8,color: data.active.toString()=="1"?Colors.green:Colors.orangeAccent.shade100,),5.width,
                                              CustomText(
                                                  text: data.active.toString()=="1"?"Active":"In Active",
                                                  isCopy: false,
                                                  colors: data.active.toString()=="1"?Colors.green:Colors.orangeAccent
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: CustomText(
                                          text: data.totalLead.toString(),
                                          isCopy: false,isBold: true,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                edit.value=true;
                                                editIndex.value=index;
                                                controllers.emailMessageCtr.text=data.value;
                                                FocusScope.of(context).requestFocus(nameFocusList[editIndex.value]);
                                              },
                                              child: Image.asset("assets/images/lead5.png"),
                                            ),10.width,
                                            PopupMenuButton(
                                              icon: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Image.asset("assets/images/lead8.png"),
                                              ),
                                              onSelected: (value) {
                                                if (value == "copy") {
                                                  add.value=true;
                                                  controllers.emailMessageCtr.text="${data.value}(copy)";
                                                } else if (value == "edit") {
                                                  edit.value=true;
                                                  editIndex.value=index;
                                                  controllers.emailMessageCtr.text=data.value;
                                                  FocusScope.of(context).requestFocus(nameFocusList[editIndex.value]);
                                                }else if (value == "status") {
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: "edit",
                                                  child: Row(
                                                    children: [
                                                      Image.asset("assets/images/lead5.png"),10.width,
                                                      const Text("Edit Name"),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: "copy",
                                                  child: Row(
                                                    children: [
                                                      Image.asset("assets/images/lead6.png"),10.width,
                                                      Text("Duplicate"),
                                                    ],
                                                  ),
                                                ),
                                                // PopupMenuItem(
                                                //   value: "status",
                                                //   child: Row(
                                                //     children: [
                                                //       Image.asset("assets/images/lead7.png"),10.width,
                                                //       Text("Toggle Status"),
                                                //     ],
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if(add.value==true)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTextField(
                                focusNode: name,
                                width: MediaQuery.of(context).size.width*0.4,
                                text: "",isOptional:false,
                                hintText: "Category Name",
                                controller: controllers.emailMessageCtr,
                                onChanged: (value){
                                  if (value.toString().isNotEmpty) {
                                    String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.emailMessageCtr.value = controllers.emailMessageCtr.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                },
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.textInput,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height:30,
                                    child: CustomLoadingButton(callback: (){
                                      if (controllers.emailMessageCtr.text.trim().isEmpty) {
                                        utils.snackBar(
                                          context: context,
                                          msg: "Please enter lead category",
                                          color: Colors.red,
                                        );
                                        controllers.productCtr.reset();
                                        return;
                                      }else{
                                        addCategories(context,"add","",100);
                                      }
                                    }, isLoading: true, controller: controllers.productCtr,text: "Save",
                                        backgroundColor: colorsConst.primary, radius: 5, width: 100),
                                  ),10.width,
                                  SizedBox(
                                    width: 80,
                                    height:30,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        add.value=false;
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                                    ),
                                  ),

                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                  5.height,
                  Row(
                    children: [
                      Icon(Icons.error,color: Colors.grey,size: 15,),5.width,
                      CustomText(text: "Drag the", isCopy: false,colors: Colors.grey),5.width,
                      Icon(Icons.menu,color: Colors.grey,size: 15),5.width,
                      CustomText(text: "handle to reorder. Right-click for more options.", isCopy: false,colors: Colors.grey)
                    ],
                  )
              ],
              ),
            ),
          ))
        ],
      ),
    );
  }
  Future addCategories(BuildContext context,String ops,String id,int index) async {
    try {
      Map data = {
        "action": "insert_category",
        "ops": ops,
        "id": id,
        "value": controllers.emailMessageCtr.text.trim(),
        "cos_id": controllers.storage.read("cos_id"),
        "created_by": controllers.storage.read("id"),
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      debugPrint(data.toString());
      debugPrint(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return addCategories(context,ops,id,index);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        add.value=false;
        edit.value=false;
        editIndex.value=100;
        final responseData = jsonDecode(request.body);
        utils.snackBar(context: context, msg: "Category ${ops=="add"?"added":"updated"} successfully", color: Colors.green);
        apiService.getAllLeadCategories();
        if(ops=="add"){
          controllers.leadCategoryList.add(LeadStatusModel(
              leadStatus: (responseData['data']['lead_status']).toString(),
              value: controllers.emailMessageCtr.text.trim(),
              id: (responseData['data']['id']).toString(),
              active: (responseData['data']['active']).toString(),
              totalLead: (responseData['data']['total_lead']).toString(),
              icon1: "",
              icon2: "",
              displayOrder: int.parse(responseData['data']['display_order'].toString()),
            ));
        }else{
          int index = controllers.leadCategoryList.indexWhere((e) => e.id == id);
          if (index != -1) {
            controllers.leadCategoryList[index] =LeadStatusModel(
              leadStatus: (responseData['data']['lead_status']).toString(),
              value: controllers.emailMessageCtr.text.trim(),
              id: (responseData['data']['id']).toString(),
              active: (responseData['data']['active']).toString(),
              totalLead: (responseData['data']['total_lead']).toString(),
              icon1: "",
              icon2: "",
              displayOrder: int.parse(responseData['data']['display_order'].toString()));
          }
        }
        // controllers.leadCategoryList
        //     .sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        // controllers.productCtr.reset();
      } else {
        apiService.errorDialog(context, request.body);
      }
    } catch (e) {
      apiService.errorDialog(context, e.toString());
    }
  }
}
