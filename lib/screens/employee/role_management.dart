import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Role Name",
                              style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                          const CustomText(
                            text: "*",
                            colors: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                      5.height,
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: settingsController.roleController,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        onChanged: (value){
                          if(settingsController.roleController.text.trim().isNotEmpty){
                            setState(() {
                              roleError = null;
                            });
                          }
                        },
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
                      15.height,
                      /// Description
                      Text("Description",
                          style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                      5.height,
                      SizedBox(
                        height: 100,
                        width: 600,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: settingsController.descriptionController,
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
                      5.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Permissions",
                              style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                          const CustomText(
                            text: "*",
                            colors: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                      5.height,
                      DropdownButtonFormField<String>(
                        value: settingsController.permission,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          errorText: permissionError,
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
                        items: settingsController.permissionList.map(
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
                        onChanged: (v) {
                          setState(() {
                            settingsController.permission = v;
                            if(settingsController.permission!=null){
                              permissionError = null;
                            }
                          });
                        },
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
                                roleError = settingsController.roleController.text.trim().isEmpty
                                    ? "Please enter role name"
                                    : null;
                                permissionError = settingsController.permission == null
                                    ? "Please select permission"
                                    : null;
                              });
                              if (roleError == null && permissionError == null) {
                                 await settingsController.insertRoleAPI(context);
                              } else {
                                controllers.productCtr.reset();
                              }
                            },
                            height: 40,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 7,
                            width: 140,
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

  void _showUpdateRoleDialog(String id) {
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
                            "Update Role",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Role Name",
                              style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                          const CustomText(
                            text: "*",
                            colors: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                      5.height,
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: settingsController.updateRoleController,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        onChanged: (value){
                          if(settingsController.updateRoleController.text.trim().isNotEmpty){
                            setState(() {
                              roleError = null;
                            });
                          }
                        },
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
                      15.height,
                      /// Description
                      Text("Description",
                          style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                      5.height,
                      SizedBox(
                        height: 100,
                        width: 600,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: settingsController.upDescriptionController,
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
                      5.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Permissions",
                              style: GoogleFonts.lato(fontSize: 17, color: const Color(0xff737373))),
                          const CustomText(
                            text: "*",
                            colors: Colors.red,
                            size: 25,
                          )
                        ],
                      ),
                      5.height,
                      DropdownButtonFormField<String>(
                        value: settingsController.updatePermission,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          errorText: permissionError,
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
                        items: settingsController.permissionList.map(
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
                        onChanged: (v) {
                          setState(() {
                            settingsController.updatePermission = v;
                            if(settingsController.updatePermission!=null){
                              permissionError = null;
                            }
                          });
                        },
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
                                roleError = settingsController.updateRoleController.text.trim().isEmpty
                                    ? "Please enter role name"
                                    : null;
                                permissionError = settingsController.updatePermission == null
                                    ? "Please select permission"
                                    : null;
                              });
                              if (roleError == null && permissionError == null) {
                                await settingsController.updateRoleAPI(context,id);
                              } else {
                                controllers.productCtr.reset();
                              }
                            },
                            height: 40,
                            isLoading: true,
                            backgroundColor: colorsConst.primary,
                            radius: 7,
                            width: 140,
                            controller: controllers.productCtr,
                            isImage: false,
                            text: "Update Role",
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
          SideBar(
            controllers: controllers,
            colorsConst: colorsConst,
            logo: logo,
            constValue: constValue,
            versionNum: versionNum,
          ),
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
                      child: Obx(()=>CustomText(
                        text: settingsController.rolesCount.value.toString(),
                        colors: Colors.white,
                        size: 13,
                      ),)
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
                        settingsController.searchText.value = value.toString().trim();
                      },
                    ),
                    1.width
                  ],
                ),
                10.height,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),//Actions
                    1: FlexColumnWidth(2),//Role
                    2: FlexColumnWidth(3.5),//Description
                    3: FlexColumnWidth(3.5),//Permissions
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
                                    settingsController.sortRoleField.value = 'name';
                                    settingsController.sortRole();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortRoleField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortRoleOrder.value == 'asc'
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
                                    settingsController.sortRoleField.value = 'description';
                                    settingsController.sortRole();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortRoleField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortRoleOrder.value == 'asc'
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
                                    settingsController.sortRoleField.value = 'permissions';
                                    settingsController.sortRole();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortRoleField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortRoleOrder.value == 'asc'
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
                    final searchText = settingsController.searchText.value.toLowerCase();
                    final filteredList = settingsController.roleList.where((activity) {
                      final matchesSearch = searchText.isEmpty ||
                          (activity.roleName.toString().toLowerCase().contains(searchText));
                      return matchesSearch;
                    }).toList();
                    if (settingsController.isLoadingRoles.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (filteredList.isEmpty) {
                      return const Center(child: Text("No roles found"));
                    }
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final role = filteredList[index];
                        return Table(
                          columnWidths:const {
                            0: FlexColumnWidth(1),//Actions
                            1: FlexColumnWidth(2),//Role
                            2: FlexColumnWidth(3.5),//Description
                            3: FlexColumnWidth(3.5),//Permissions
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
                                              settingsController.updateRoleController.text = role.roleName.toString();
                                              settingsController.upDescriptionController.text = role.description.toString();
                                              settingsController.updatePermission = role.permission.toString();
                                              _showUpdateRoleDialog(role.id.toString());
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
                                                      text: "Are you sure delete this role?",
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
                                                            settingsController.selectedRoleIds.add(role.id.toString());
                                                            settingsController.deleteRoleAPI(context);
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
                                        text: role.roleName.toString(),
                                        size: 14,
                                        colors:colorsConst.textColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text: role.description.toString(),
                                      size: 14,
                                      colors:colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text:role.permission.toString(),
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
