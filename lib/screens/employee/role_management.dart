import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';

class RoleManagement extends StatefulWidget {
  const RoleManagement({super.key});

  @override
  State<RoleManagement> createState() => _RoleManagementState();
}

class _RoleManagementState extends State<RoleManagement> {
  void _showAddRoleDialog() {
    String? roleError;
    String? descriptionError;
    String? permissionError;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 630,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Role",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              "×",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(thickness: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      /// Role Name
                      Text("Role Name",
                          style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                      const SizedBox(height: 5),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: remController.roleController,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                          hintText: "Role Name",
                          errorText: roleError,
                          hintStyle: TextStyle(
                            color: const Color(0xFFCCCCCC),
                            fontSize: 17,
                            fontFamily: GoogleFonts.lato().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorsConst.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Description
                      Text("Description",
                          style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 100,
                        width: 600,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: remController.detailsController,
                          maxLines: 3,
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            hintText: "Description",
                            errorText: descriptionError,
                            hintStyle: GoogleFonts.lato(
                              color: const Color(0xFFCCCCCC),
                              fontSize: 17,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: colorsConst.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text("Permissions",
                          style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        value: remController.permission,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorsConst.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: remController.permissionList
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ).toList(),
                        onChanged: (v) => setState(() => remController.permission = v),
                      ),
                      15.height,

                      /// Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  side: const BorderSide(color: Color(0xff0078D7)),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CustomLoadingButton(
                            callback: () async {
                              setState(() {
                                roleError = remController.roleController.text.trim().isEmpty
                                    ? "Please enter role name"
                                    : null;
                                descriptionError = remController.detailsController.text.trim().isEmpty
                                    ? "Please enter description"
                                    : null;
                                permissionError = remController.location == null
                                    ? "Please select location"
                                    : null;
                              });

                              if (roleError == null &&
                                  descriptionError == null &&
                                  permissionError == null) {
                                /// ✅ Call your API here
                                // await remController.addRoleAPI();
                              } else {
                                controllers.productCtr.reset();
                              }
                            },
                            height: 40,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 7,
                            width: 120,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Save Role",
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          utils.sideBarFunction(context),
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
                          text: "Role Management",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                        ),
                        10.height,
                        CustomText(
                          text: "Define what each user can access",
                          colors: colorsConst.textColor,
                          size: 14,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add,color: Colors.white,),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorsConst.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: (){
                          _showAddRoleDialog();
                        },
                        label: CustomText(
                          text: "Add Role",
                          colors: Colors.white,
                          isBold :true,
                          size: 14,
                        ),),
                    )
                  ],
                ),
                10.height,
                Row(
                  children: [
                    CustomText(
                      text: "Roles",
                      colors: colorsConst.primary,
                      isBold: true,
                      size: 15,
                    ),
                    10.width,
                    CircleAvatar(
                      backgroundColor: colorsConst.primary,
                      radius: 17,
                      child: CustomText(
                        text: "3",
                        colors: Colors.white,
                        size: 13,
                      ),
                    ),
                  ],
                ),
                5.height,
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                5.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSearchTextField(
                      controller: controllers.search,
                      hintText: "Search Role Name",
                      onChanged: (value) {
                        remController.searchText.value = value.toString().trim();
                      },
                    ),
                    remController.selectedReminderIds.isNotEmpty?
                    InkWell(
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: CustomText(
                                text: "Are you sure delete this reminder?",
                                size: 16,
                                isBold: true,
                                colors: colorsConst.textColor,
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: colorsConst.primary),
                                          color: Colors.white),
                                      width: 80,
                                      height: 25,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                            backgroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: CustomText(
                                            text: "Cancel",
                                            colors: colorsConst.primary,
                                            size: 14,
                                          )),
                                    ),
                                    10.width,
                                    CustomLoadingButton(
                                      callback: ()async{
                                        remController.deleteReminderAPI(context);
                                      },
                                      height: 35,
                                      isLoading: true,
                                      backgroundColor: colorsConst.primary,
                                      radius: 2,
                                      width: 80,
                                      controller: controllers.productCtr,
                                      isImage: false,
                                      text: "Delete",
                                      textColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: colorsConst.secondary,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/action_delete.png"),
                            10.width,
                            CustomText(
                              text: "Delete",
                              colors: colorsConst.textColor,
                              size: 14,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ):1.width
                  ],
                ),
                10.height,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),//Actions
                    1: FlexColumnWidth(2),//Role
                    2: FlexColumnWidth(3),//Description
                    3: FlexColumnWidth(2),//Permissions
                  },
                  border: TableBorder(
                    horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                    verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                  ),
                  children: [
                    TableRow(
                        decoration: BoxDecoration(
                            color: colorsConst.primary,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5))),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Actions",//0
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Role",//1
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(remController.sortFieldCallActivity.value=='employeeName' && remController.sortOrderCallActivity.value=='asc'){
                                      remController.sortOrderCallActivity.value='desc';
                                    }else{
                                      remController.sortOrderCallActivity.value='asc';
                                    }
                                    remController.sortFieldCallActivity.value='employeeName';
                                    remController.sortReminders();
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldCallActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderCallActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Description",//2
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(remController.sortFieldCallActivity.value=='employeeName' && remController.sortOrderCallActivity.value=='asc'){
                                      remController.sortOrderCallActivity.value='desc';
                                    }else{
                                      remController.sortOrderCallActivity.value='asc';
                                    }
                                    remController.sortFieldCallActivity.value='employeeName';
                                    remController.sortReminders();
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldCallActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderCallActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Permissions",//3
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(remController.sortFieldCallActivity.value=='employeeName' && remController.sortOrderCallActivity.value=='asc'){
                                      remController.sortOrderCallActivity.value='desc';
                                    }else{
                                      remController.sortOrderCallActivity.value='asc';
                                    }
                                    remController.sortFieldCallActivity.value='employeeName';
                                    remController.sortReminders();
                                  },
                                  child: Obx(() => Image.asset(
                                    controllers.sortFieldCallActivity.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : controllers.sortOrderCallActivity.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ],
                ),
                Expanded(
                  child: Obx(() {
                    final searchText = remController.searchText.value.toLowerCase();
                    final filteredList = remController.reminderList.where((activity) {
                      final matchesSearch = searchText.isEmpty ||
                          (activity.customerName.toString().toLowerCase().contains(searchText)) ||
                          (activity.employeeName.toString().toLowerCase().contains(searchText)) ||
                          (activity.title.toString().toLowerCase().contains(searchText));
                      return matchesSearch;
                    }).toList();
                    if (remController.isLoadingReminders.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (filteredList.isEmpty) {
                      return const Center(child: Text("No reminders found"));
                    }
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final reminder = filteredList[index];
                        return Table(
                          columnWidths:const {
                            0: FlexColumnWidth(3),//Actions
                            1: FlexColumnWidth(2),//Role
                            2: FlexColumnWidth(3),//Description
                            3: FlexColumnWidth(2),//Permissions
                          },
                          border: TableBorder(
                            horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                            verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                            bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                          ),
                          children:[
                            TableRow(
                                decoration: BoxDecoration(
                                  color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                ),
                                children:[
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                            onPressed: (){
                                              remController.updateTitleController.text = reminder.title.toString()=="null"?"":reminder.title.toString();
                                              remController.updateLocation = reminder.location.toString()=="null"?"":reminder.location.toString();
                                              remController.updateDetailsController.text = reminder.details.toString()=="null"?"":reminder.details.toString();
                                              remController.updateStartController.text = reminder.startDt.toString()=="null"?"":reminder.startDt.toString();
                                              remController.updateEndController.text = reminder.endDt.toString()=="null"?"":reminder.endDt.toString();
                                              //_showUpdateReminderDialog(reminder.id.toString());
                                            },
                                            icon:  SvgPicture.asset(
                                              "assets/images/a_edit.svg",
                                              width: 16,
                                              height: 16,
                                            )),
                                        IconButton(
                                            onPressed: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    content: CustomText(
                                                      text: "Are you sure delete this reminder?",
                                                      size: 16,
                                                      isBold: true,
                                                      colors: colorsConst.textColor,
                                                    ),                                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(color: colorsConst.primary),
                                                              color: Colors.white),
                                                          width: 80,
                                                          height: 25,
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.zero,
                                                                ),
                                                                backgroundColor: Colors.white,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: CustomText(
                                                                text: "Cancel",
                                                                colors: colorsConst.primary,
                                                                size: 14,
                                                              )),
                                                        ),
                                                        10.width,
                                                        CustomLoadingButton(
                                                          callback: ()async{
                                                            remController.selectedReminderIds.add(reminder.id.toString());
                                                            remController.deleteReminderAPI(context);
                                                          },
                                                          height: 35,
                                                          isLoading: true,
                                                          backgroundColor: colorsConst.primary,
                                                          radius: 2,
                                                          width: 80,
                                                          controller: controllers.productCtr,
                                                          isImage: false,
                                                          text: "Delete",
                                                          textColor: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: SvgPicture.asset(
                                              "assets/images/a_delete.svg",
                                              width: 16,
                                              height: 16,
                                            ))
                                      ],
                                    ),
                                  ),
                                  Tooltip(
                                    message: "role",
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomText(
                                        textAlign: TextAlign.left,
                                        text:"role",
                                        size: 14,
                                        colors:colorsConst.textColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text: "Meeting",
                                      size: 14,
                                      colors:colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text:"Permissions",
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                ]
                            ),
                          ],
                        );
                      },
                    );
                  }),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
