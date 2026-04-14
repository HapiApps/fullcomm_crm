import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:get/get.dart';
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
import '../../controller/controller.dart';
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  final FocusNode name = FocusNode();
  var isEdit=false.obs;
  var total=0.obs;
  var add=false.obs;
  var edit=false.obs;
  var editIndex=100.obs;
  RxList lead=[].obs;
  List<FocusNode> nameFocusList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(productCtr.termsAndConditionsList.isEmpty){
      productCtr.getTermsAndConditions();
    }
    nameFocusList = List.generate(
      productCtr.termsAndConditionsList.length,
          (index) => FocusNode(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lead.value=productCtr.termsAndConditionsList;
      controllers.notesController.clear();
    });
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
                          Row(
                            children: [
                              IconButton(onPressed: (){
                                if(isEdit.value==true||editIndex.value!=100){
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: SizedBox(
                                          width: 300,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomText(
                                                  text: "Confirm",
                                                  size: 18,
                                                  isBold: true, isCopy: false,
                                                ),
                                                10.height,
                                                CustomText(
                                                  text: "Are you sure you want to save changes?",
                                                  size: 14,
                                                  colors: Colors.black54,
                                                  isCopy: false,
                                                ),
                                                20.height,
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        if(editIndex.value!=100){
                                                          editIndex.value=100;
                                                        }else{
                                                          isEdit.value=false;
                                                          productCtr.termsAndConditionsList.assignAll(controllers.allLead);
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: CustomText(
                                                        text: "Cancel",
                                                        size: 14,
                                                        isBold: true,
                                                        colors: Colors.grey,
                                                        isCopy: false,
                                                      ),
                                                    ),
                                                    10.width,
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.blue,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        if(editIndex.value!=100){
                                                          if (controllers.emailMessageCtr.text.trim().isEmpty) {
                                                            utils.snackBar(
                                                              context: context,
                                                              msg: "Please enter lead category",
                                                              color: Colors.red,
                                                            );
                                                            return;
                                                          }else{
                                                            addCategories(context,"update",productCtr.termsAndConditionsList[editIndex.value]["id"],editIndex.value);
                                                          }
                                                        }else{
                                                          await apiService.updateCategories(context);
                                                        }
                                                      },
                                                      child: CustomText(
                                                        text: "Save",
                                                        size: 14,
                                                        isBold: true,
                                                        colors: Colors.white,
                                                        isCopy: false,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }else{
                                  Get.back();
                                }
                              }, icon: Icon(Icons.arrow_back_ios_new,size: 15,)),10.width,
                              CustomText(
                                text: "Terms & Conditions",
                                colors: colorsConst.textColor,
                                size: 20,
                                isCopy: true,
                                isBold: true,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(onPressed: null, icon: Icon(Icons.arrow_back_ios_new,size: 0,)),10.width,
                              CustomText(
                                text: "Add, edit and reorder condition used in the invoice.",
                                colors: Colors.grey,
                                size: 15,
                                isCopy: true,
                              ),
                            ],
                          ),
                          10.height,
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1.5,
                    color: colorsConst.secondary,
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
                              Container(
                                decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.grey.shade100,radius: 20,
                                ),
                                child:  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomText(text: "${productCtr.termsAndConditionsList.length} Conditions", isCopy: false,isBold: true,colors: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if(isEdit.value==true)
                              SizedBox(
                                  height:30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen
                                    ),
                                      onPressed: ()async{
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
                                      child: CustomText(text: "Save Changes", isCopy: false,colors: Colors.black,)),
                                ),
                              10.width,
                              SizedBox(
                                width:MediaQuery.of(context).size.width*0.2,
                                height: 30,
                                child: CustomSearchTextField(
                                  // focusNode:focusNode,
                                  hintText: "Search Categories... ",
                                  controller: controllers.notesController,
                                  onChanged: (value) {
                                    // final suggestions=productCtr.termsAndConditionsList2.where(
                                    //         (user){
                                    //       final customerName = user.value.toString().toLowerCase();
                                    //       final input = value.toString().toLowerCase().trim();
                                    //       return customerName.contains(input);
                                    //     }).toList();
                                    // productCtr.termsAndConditionsList.value=suggestions;
                                  },
                                  //onChanged: onSearchChanged,
                                ),
                              ),10.width,
                              OutlinedButton(
                                  onPressed: (){
                                    add.value=true;
                                    edit.value=false;
                                    editIndex.value=100;
                                    controllers.emailMessageCtr.clear();
                                    FocusScope.of(context).requestFocus(name);
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width:MediaQuery.of(context).size.width*0.55,
                              child:Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                  ),
                                  10.width,
                                  SizedBox(
                                    width: 240,
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
                            width: MediaQuery.of(context).size.width*0.05,
                            child: Row(
                              children: [
                                CustomText(text: "ORDER", isCopy: false,isBold: true,colors: Colors.white),
                                Icon(Icons.arrow_downward_sharp,color: Colors.white,size: 15,)
                              ],
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width*0.05,
                              child: CustomText(text: "ACTIONS", isCopy: false,isBold: true,colors: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.5,
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
                            itemCount: productCtr.termsAndConditionsList.length,
                            onReorder: (oldIndex, newIndex) async {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item =
                              productCtr.termsAndConditionsList.removeAt(oldIndex);
                              productCtr.termsAndConditionsList.insert(newIndex, item);
                              for (int i = 0; i < productCtr.termsAndConditionsList.length; i++) {
                                productCtr.termsAndConditionsList[i]["display_order"] = i + 1;
                              }
                              isEdit.value = true;
                              controllers.update();
                            },
                            itemBuilder: (context, index) {
                              var data = productCtr.termsAndConditionsList[index];

                              return Padding(
                                key: ValueKey(data["id"]),
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                                child: Container(
                                  color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          width:MediaQuery.of(context).size.width*0.55,
                                          child: Obx(()=>editIndex.value==index?
                                          TextField(
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
                                              }else if (controllers.emailMessageCtr.text.length>15) {
                                                utils.snackBar(
                                                  context: context,
                                                  msg: "Category must be 15 chars only",
                                                  color: Colors.red,
                                                );
                                                controllers.productCtr.reset();
                                                return;
                                              }else{
                                                addCategories(context,"update",data["id"],index);
                                              }
                                            },
                                          ):
                                          CustomText(
                                            textAlign: TextAlign.start,
                                            text: "${index+1} . ${data["name"].toString()}",
                                            isCopy: false,
                                          ),)
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.05,
                                        child: CustomText(
                                          text: data["display_order"].toString(),
                                          isCopy: false,isBold: true,
                                          colors: colorsConst.primary,
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.05,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                if(editIndex.value==index){
                                                  if (controllers.emailMessageCtr.text.trim().isEmpty) {
                                                    utils.snackBar(
                                                      context: context,
                                                      msg: "Please enter lead category",
                                                      color: Colors.red,
                                                    );
                                                    controllers.productCtr.reset();
                                                    return;
                                                  }else{
                                                    addCategories(context,"update",data["id"],index);
                                                  }
                                                }else{
                                                  edit.value=true;
                                                  editIndex.value=index;
                                                  controllers.emailMessageCtr.text=data["name"];
                                                  FocusScope.of(context).requestFocus(nameFocusList[editIndex.value]);
                                                }
                                              },
                                              child: editIndex.value==index?Icon(Icons.check):Image.asset("assets/images/lead5.png"),
                                            ),10.width,
                                            PopupMenuButton(
                                              icon: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Image.asset("assets/images/lead8.png"),
                                              ),
                                              onSelected: (value) {
                                                if (value == "copy") {
                                                  add.value=true;
                                                  controllers.emailMessageCtr.text="${data["name"]}(copy)";
                                                } else if (value == "edit") {
                                                  edit.value=true;
                                                  editIndex.value=index;
                                                  controllers.emailMessageCtr.text=data["name"];
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
                                      }else if (controllers.emailMessageCtr.text.length>15) {
                                        utils.snackBar(
                                          context: context,
                                          msg: "Category must be 15 chars only",
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
        "action": "insert_terms",
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
      // Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return addCategories(context,ops,id,index);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode==200) {
        add.value=false;
        edit.value=false;
        editIndex.value=100;
        final responseData = jsonDecode(request.body);
        utils.snackBar(context: context, msg: "Terms And Conditions ${ops=="add"?"added":"updated"} successfully", color: Colors.green);
        productCtr.getTermsAndConditions();
      } else {
        apiService.errorDialog(context, request.body);
      }
    } catch (e) {
      apiService.errorDialog(context, e.toString());
    }
  }
}
