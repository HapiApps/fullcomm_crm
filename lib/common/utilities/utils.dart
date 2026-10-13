import 'dart:convert';
import 'package:excel/excel.dart' as excel;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../components/dialog_button.dart';
import '../../components/keyboard_search.dart';
import '../../components/search_custom_dropdown.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/image_controller.dart';
import '../../controller/reminder_controller.dart';
import '../../controller/table_controller.dart';
import '../../main.dart';
import '../../models/all_customers_obj.dart';
import '../../provider/reminder_provider.dart';
import '../../services/api_services.dart';
import '../constant/api.dart';
import '../constant/assets_constant.dart';
import '../constant/colors_constant.dart';
import '../platform/file_save_stub.dart';
import '../platform/pdf_view_stub.dart';
import '../styles/styles.dart';

final Utils utils = Utils._();

class Utils {
  Utils._();
  bool validateWebsite(String value) {
    final regex = RegExp(
      r'^(https?:\/\/)?([\w-]+\.)+[\w-]{2,}(\/.*)?$',
    );

    if (!regex.hasMatch(value.trim())) {
      return false;
    }else{
      return true;
    }
  }

  String formatDob(String? dob) {
    if (dob == null || dob.isEmpty || dob == "null") {
      return "";
    }
    final regex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (regex.hasMatch(dob)) {
      return dob; // Already in correct format
    }

    try {
      DateTime parsedDate = DateTime.parse(dob);
      return "${parsedDate.day.toString().padLeft(2, '0')}-"
          "${parsedDate.month.toString().padLeft(2, '0')}-"
          "${parsedDate.year}";
    } catch (e) {
      return "";
    }
  }

  void showPdfDialog(BuildContext context, String url) {
    showPdfDialogImpl(context, url);
  }

  void sendEmailDialog(
      {required String id,
      required String name,
      required String mobile,
      required String coName}) {
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: [
              Column(
                children: [
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  // Navigator.of(context).pop();
                                  settingsController.showAddTemplateDialog(context);
                                },
                                child: CustomText(
                                  text: "Create Template",
                                  isCopy: false,
                                  colors: colorsConst.third,
                                  size: 18,
                                  isBold: true,
                                )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(assets.b,
                            //         width: 17, height: 17)),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.i,
                            //       width: 15,
                            //       height: 15,
                            //     )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.u,
                            //       width: 19,
                            //       height: 19,
                            //     )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.fileFilter,
                            //       width: 17,
                            //       height: 17,
                            //     )),
                            // IconButton(
                            //     onPressed: (){},
                            //     icon:SvgPicture.asset(assets.textFilter,width: 17,height: 17,)
                            // ),
                            if(controllers.planType.value!="Business Essential")
                            IconButton(
                                onPressed: () async {
                                  // utils.chooseFile(
                                  //     mediaDataV: imageController.empMediaData,
                                  //     fileName: imageController.empFileName,
                                  //     pathName: imageController.photo1);

                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    allowMultiple: true,

                                    /// ALL TYPES
                                    type: FileType.any,

                                    withData: true,
                                  );

                                  if (result != null) {

                                    for (var file in result.files) {
                                      imageController.images.add({
                                        "fileName": file.name,
                                        "bytes": file.bytes,
                                      });
                                    }

                                  } else {
                                  }
                                },
                                icon: SvgPicture.asset(assets.file)),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(
                            //       assets.layer,
                            //       width: 17,
                            //       height: 17,
                            //
                            //     )),
                            // IconButton(
                            //     onPressed: () {},
                            //     icon: SvgPicture.asset(assets.a)),
                          ],
                        ),
                      ),
                      Obx(
                        () => CustomLoadingButton(
                          callback: () {
                            if(controllers.emailToCtr.text.trim().isEmpty){
                              snackBar(context: context, msg: "To is empty!", color: Colors.red);
                              controllers.emailCtr.reset();
                              return;
                            }
                            if(!controllers.emailToCtr.text.trim().isEmail){
                              snackBar(
                                context: context,
                                msg: "Invalid mail!",
                                color: Colors.red,
                              );
                              controllers.emailCtr.reset();
                              return;
                            }
                            if(controllers.emailSubjectCtr.text.trim().isEmpty){
                              snackBar(context: context, msg: "Subject is empty!", color: Colors.red);
                              controllers.emailCtr.reset();
                              return;
                            }
                            if(controllers.emailMessageCtr.text.trim().isEmpty){
                              snackBar(context: context, msg: "Message is empty!", color: Colors.red);
                              controllers.emailCtr.reset();
                              return;
                            }
                            apiService.insertEmailAPI(context, id.toString(),
                                imageController.photo1.value);
                          },
                          controller: controllers.emailCtr,
                          isImage: false,
                          isLoading: true,
                          backgroundColor: colorsConst.primary,
                          radius: 5,
                          width: controllers.emailCount.value == 0 ||
                                  controllers.emailCount.value == 1
                              ? 90
                              : 200,
                          height: 50,
                          text: controllers.emailCount.value == 0
                              ? "Quotation"
                              : controllers.emailCount.value == 1
                                  ? "Reply"
                                  : "Reply & Quotation",
                          textColor: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
            content: SizedBox(
                width: 600,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.clear,
                                size: 18,
                                color: colorsConst.textColor,
                              ))),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                            onPressed: () {
                              if(settingsController.templateList.isEmpty){
                                utils.showToast("No templates found",Colors.red);
                              }else{
                                controllers.isTemplate.value = !controllers.isTemplate.value;
                              }
                            },
                            child: CustomText(
                              text: "Get From Template",
                              colors: colorsConst.third,
                              size: 18,
                              isCopy: false,
                              isBold: true,
                            )),
                      ),
                      Row(
                        children: [
                          CustomText(
                            textAlign: TextAlign.center,
                            text: "To",
                            colors: colorsConst.textColor,
                            size: 15,
                            isCopy: false,
                          ),
                          50.width,
                          SizedBox(
                            width: 500,
                            child: TextField(
                              controller: controllers.emailToCtr,
                              style: TextStyle(
                                  fontSize: 15, color: colorsConst.textColor),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                          width: 600,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                                Row(
                                  children: [
                                    15.height,
                                    CustomText(
                                      text: "Subject",
                                      colors: colorsConst.textColor,
                                      size: 14,
                                      isCopy: false,
                                    ),
                                    20.width,
                                    SizedBox(
                                      width: 500,
                                      height: 50,
                                      child: TextField(
                                        controller: controllers.emailSubjectCtr,
                                        onChanged: (value){
                                          controllers.firstCaps(value, controllers.emailSubjectCtr);
                                        },
                                        maxLines: null,
                                        minLines: 1,
                                        style: TextStyle(
                                          color: colorsConst.textColor,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                                SizedBox(
                                  width: 600,
                                  height: 223,
                                  child: TextField(
                                    textInputAction: TextInputAction.newline,
                                    controller: controllers.emailMessageCtr,
                                    onChanged: (value){
                                      controllers.firstCaps(value, controllers.emailMessageCtr);
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 21,
                                    expands: false,
                                    style: TextStyle(
                                      color: colorsConst.textColor,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Message",
                                      hintStyle: TextStyle(
                                          color: colorsConst.textColor,
                                          fontSize: 14,
                                          fontFamily: "Lato"),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Obx(
                                      () => imageController.images.isEmpty
                                      ? 0.height
                                      : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: imageController.images.length,
                                    itemBuilder: (context, index) {

                                      final item = imageController.images[index];

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff86BAE3FF),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [

                                            Expanded(
                                              child: CustomText(
                                                text: item["fileName"],
                                                isCopy: false,
                                              ),
                                            ),

                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                imageController.images.removeAt(index);
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Obx(() => controllers.isTemplate.value == true
                                      ? Container(
                                  width: 500,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colorsConst.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 500,
                                      child: Table(
                                        defaultColumnWidth: const FixedColumnWidth(120.0),
                                        border: TableBorder.all(
                                          color: Colors.grey.shade300,
                                          style: BorderStyle.solid,
                                          borderRadius: BorderRadius.circular(10),
                                          width: 1,
                                        ),
                                        children: [
                                          // Header Row
                                          TableRow(
                                            children: [
                                              CustomText(
                                                textAlign: TextAlign.center,
                                                text: "\nTemplate Name\n",
                                                colors: colorsConst.textColor,
                                                size: 15,
                                                isBold: true,
                                                isCopy: false,
                                              ),
                                              CustomText(
                                                textAlign: TextAlign.center,
                                                text: "\nSubject\n",
                                                colors: colorsConst.textColor,
                                                size: 15,
                                                isBold: true,
                                                isCopy: false,
                                              ),
                                            ],
                                          ),
                                          // Dynamic Rows
                                          for (var item in settingsController.templateList)
                                            utils.emailRow(
                                                context,
                                                isCheck: controllers.isAdd,
                                                templateName: item.templateName,
                                                msg: item.message,
                                                subject: item.subject,
                                                id: item.id
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ):SizedBox()
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                )),
          );
        });
  }

  Future<void> showDeleteDialog({
    required BuildContext context,
    required String name,
    required bool isDelete,
    required VoidCallback callBack,
    required RoundedLoadingButtonController controller,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: CustomText(
            text: "Are you sure $name?",
            size: 16,
            isCopy: false,
            isBold: true,
            colors: colorsConst.textColor,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomLoadingButton(
                  callback: callBack,
                  height: 35,
                  isLoading: true,
                  backgroundColor: colorsConst.primary,
                  radius: 2,
                  width: 80,
                  controller: controller,
                  isImage: false,
                  text: isDelete?"Delete":"YES",
                  textColor: Colors.white,
                ),
                10.width,
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colorsConst.primary),
                    color: Colors.white,
                  ),
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
                      text: isDelete?"Cancel":"NO",
                      isCopy: false,
                      colors: colorsConst.primary,
                      size: 14,
                    ),
                  ),
                ),
                5.width,
              ],
            ),
          ],
        );
      },
    );
  }

  void showComposeMail(BuildContext context) {
    List<String> toEmails = [];
    List<String> ccEmails = [];
    List<String> nameList = [];
    List<String> idList = [];

    controllers.emailToCtr.clear();
    controllers.emailSubjectCtr.clear();
    controllers.emailMessageCtr.clear();
    imageController.images.clear();
    imageController.photo1.value="";
    final formatProvider = Provider.of<ReminderProvider>(context, listen: false);
    formatProvider.resetFormatting();
    TextEditingController emailAutoController=TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {

            /// 🔹 Email Field Widget
            Widget buildEmailField({
              required String label,
              required List<String> emailList,
            }) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(label,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [

                        /// 🔹 Chips
                        ...emailList.map((email) => Chip(
                          label: Text(email),
                          onDeleted: () {
                            setState(() => emailList.remove(email));
                          },
                        )),

                        /// 🔹 Autocomplete
                        SizedBox(
                          child: Autocomplete<AllCustomersObj>(
                            optionsBuilder: (text)  {
                              final query = text.text.toLowerCase();

                              return controllers.customers.where((c) {
                                final email = (c.email ?? "").toLowerCase().trim();
                                final name = (c.name ?? "").toLowerCase();

                                if (email.isEmpty || email == "null") return false;

                                return email.contains(query) || name.contains(query);
                              });
                            },

                            displayStringForOption: (c) =>
                            '${c.name} - ${c.email} - ${c.category}',

                            /// 🔥 CUSTOM DROPDOWN (IMPORTANT)
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  child: SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);

                                        return InkWell(
                                          onTap: () => onSelected(option),
                                          child: Builder(
                                            builder: (context) {
                                              final isHighlighted =
                                                  AutocompleteHighlightedOption.of(context) == index;

                                              /// 🔥 STORE CURRENT HIGHLIGHTED
                                              if (isHighlighted) {
                                                controllers.highlightedOption = option;
                                              }

                                              return Container(
                                                color: isHighlighted
                                                    ? Colors.grey.shade300
                                                    : null,
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  '${option.name} - ${option.email}',
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },

                            fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                              emailAutoController = controller; // 🔥 store reference
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: emailList.isEmpty ? "Search email" : "Add email",
                                  border: UnderlineInputBorder(),
                                ),

                                /// 🔥 ENTER PRESS → SELECT HIGHLIGHTED
                                onSubmitted: (_) {
                                  if (controllers.highlightedOption != null) {
                                    final c = controllers.highlightedOption!;
                                    final email = c.email ?? "";

                                    if (email.isEmpty) return;

                                    setState(() {
                                      if (!emailList.contains(email)) {
                                        emailList.add(email);
                                        nameList.add(c.name);
                                        idList.add(c.id);
                                      }
                                    });

                                    emailAutoController.clear();
                                  }
                                },
                              );
                            },

                            onSelected: (c) {
                              final email = c.email ?? "";
                              if (email.isEmpty) return;

                              setState(() {
                                if (!emailList.contains(email)) {
                                  emailList.add(email);
                                  nameList.add(c.name);
                                  idList.add(c.id);
                                }
                                emailAutoController.clear();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }


            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: Container(
                width: 650,
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Compose Mail",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      Divider(),

                      /// 🔹 TO
                      buildEmailField(label: "To", emailList: toEmails),
                      SizedBox(height: 10),

                      /// 🔹 CC
                      buildEmailField(label: "Cc", emailList: ccEmails),
                      SizedBox(height: 10),

                      /// 🔹 SUBJECT
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text("Subject",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: controllers.emailSubjectCtr,
                              onChanged: (value){
                                controllers.firstCaps(value, controllers.emailSubjectCtr);
                              },
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      10.height,
                      /// 🔹 ATTACH
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.format_bold,
                              size: 20,
                              color: Colors.black87, // always black
                            ),
                            onPressed: () {
                              setState((){
                                formatProvider.toggleBold();
                              });
                            },
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.format_italic,
                              size: 20,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              setState((){
                                formatProvider.toggleItalic();
                              });
                            },
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.format_underline,
                              size: 20,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              setState((){
                                formatProvider.toggleUnderline();
                              });
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.link, size: 20, color: Colors.black87),
                            onPressed: () {
                              if (controllers.emailMessageCtr.text.trim().isEmpty) {
                                showToast("Message is empty!",Colors.red);
                                return;
                              }
                              setState((){
                                formatProvider.toggleLink();
                              });
                            },
                          ),

                        ],
                      ),
                      10.height,
                      InkWell(
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () async {
                          if (formatProvider.isLink && controllers.emailMessageCtr.text.isNotEmpty) {
                            final text = controllers.emailMessageCtr.text.trim();
                            final url = text.startsWith("http") ? text : "https://$text";
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                        child: IgnorePointer(
                          ignoring: formatProvider.isLink,
                          child: TextFormField(
                            maxLines: 5,
                            // expands: true,
                            readOnly: formatProvider.isLink,
                            style: formatProvider.subjectTextStyle,
                            controller: controllers.emailMessageCtr,
                            onChanged: (value){
                              controllers.firstCaps(value, controllers.emailMessageCtr);
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              hoverColor: Colors.white,
                              contentPadding: EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red, width: 2),
                              ),
                              hintText: "Message",
                            ),
                          ),
                        ),
                      ),
                      14.height,
                      InkWell(
                        onTap: () async {

                          FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                            allowMultiple: true,

                            /// ALL TYPES
                            type: FileType.any,

                            withData: true,
                          );

                          if (result != null) {

                            for (var file in result.files) {
                              imageController.images.add({
                                "fileName": file.name,
                                "bytes": file.bytes,
                              });
                            }

                          } else {
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 18, color: Colors.black),
                            SizedBox(width: 6),
                            Text("Attach Quotation / Supported Files",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      10.height,
                      // Obx(() => imageController.photo1.value.isEmpty
                      //     ? 0.height
                      //     :  Container( padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      //   decoration: BoxDecoration(
                      //     color: Color(0xff86BAE3FF),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Obx(()=>CustomText(text: imageController.empFileName.value,isCopy: false,)),
                      //       SizedBox(width: 10,),
                      //       IconButton( padding: EdgeInsets.zero,
                      //         constraints: const BoxConstraints(),
                      //         onPressed: () {
                      //           imageController.photo1.value = "";
                      //         }, icon: const Icon(Icons.close, size: 10),
                      //       ),
                      //     ],
                      //   ),
                      // ),),
                      Obx(
                            () => imageController.images.isEmpty
                            ? 0.height
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: imageController.images.length,
                          itemBuilder: (context, index) {

                            final item = imageController.images[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff86BAE3FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [

                                  Expanded(
                                    child: CustomText(
                                      text: item["fileName"],
                                      isCopy: false,
                                    ),
                                  ),

                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      imageController.images.removeAt(index);
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      /// 🔹 ACTIONS
                      Divider(color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          10.width,
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: const Text("Discard",
                                    style: TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              8.width,
                              CustomLoadingButton(
                                callback: () {
                                  var inValid=false;
                                  for(var i=0;i<toEmails.length;i++){
                                    if(!isValidEmail(toEmails[i])){
                                      setState((){
                                        inValid=true;
                                      });
                                      break;
                                    }
                                  }
                                  for(var i=0;i<ccEmails.length;i++){
                                    if(!isValidEmail(ccEmails[i])){
                                      setState((){
                                        inValid=true;
                                      });
                                      break;
                                    }
                                  }

                                  if (inValid==true) {
                                    showToast("Invalid mail!", Colors.red);
                                    controllers.emailCtr.reset();
                                    return;
                                  }

                                  if(controllers.emailSubjectCtr.text.trim().isEmpty){
                                    showToast("Subject is empty!",Colors.red);
                                    controllers.emailCtr.reset();
                                    return;
                                  }
                                  if(controllers.emailMessageCtr.text.trim().isEmpty){
                                    showToast("Message is empty!",Colors.red);
                                    controllers.emailCtr.reset();
                                    return;
                                  }
                                  var sendList=[];
                                  sendList.addAll(toEmails);
                                  sendList.addAll(ccEmails);
                                  apiService.insertMultipleEmailAPI(context, sendList, nameList,idList,imageController.photo1.value);
                                },
                                controller: controllers.emailCtr,
                                isImage: false,
                                isLoading: true,
                                backgroundColor: colorsConst.primary,
                                radius: 5,
                                width: controllers.emailCount.value == 0 ||
                                    controllers.emailCount.value == 1
                                    ? 90
                                    : 200,
                                height: 50,
                                text:"Send",
                                textColor: Colors.white,
                              ),
                            ],
                          )
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

  void showToast(String msg,Color color) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9]+([._-]?[a-zA-Z0-9]+)*@gmail\.com$',
    );
    return regex.hasMatch(email);
  }

  makingWebsite({String? web}) async {
    final url = Uri.parse('https://www.$web.com');
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  bool isValidLinkedInId(String input) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,100}$');
    final urlRegex = RegExp(
        r'^(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9_-]{3,100}\/?$');

    return usernameRegex.hasMatch(input) || urlRegex.hasMatch(input);
  }

  bool isValidXId(String id) {
    final cleaned = id.trim();
    final regex = RegExp(r'^@?[a-zA-Z0-9_]{4,15}$');
    return regex.hasMatch(cleaned);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackBar({
    required String msg,
    required Color color,
    required BuildContext context
  }) {
    final messengerState = rootScaffoldMessengerKey.currentState;
    if (messengerState == null) {
      debugPrint("SnackBar skipped — ScaffoldMessengerState not ready: $msg");
      return null;
    }

    var snack = SnackBar(
      width: 500,
      content: Center(child: Text(msg)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      backgroundColor: color,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );

    return messengerState.showSnackBar(snack);
  }

  Widget paginationButton(IconData icon, bool isEnabled, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(icon, color: colorsConst.textColor),
        onPressed: isEnabled ? onPressed : null,
        // onLongPress: (){
        //   _focusNode.requestFocus();
        // },
      ),
    );
  }

  List<Widget> buildPagination(int totalPages, int currentPage,VoidCallback onPressed) {
    const maxVisiblePages = 5;
    List<Widget> pageButtons = [];

    int startPage = (currentPage - (maxVisiblePages ~/ 2)).clamp(1, totalPages);
    int endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);

    if (startPage > 1) {
      pageButtons.add(pageButton(1, currentPage,onPressed));
      if (startPage > 2) {
        pageButtons.add(ellipsis());
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(pageButton(i, currentPage,onPressed));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(ellipsis());
      }
      pageButtons.add(pageButton(totalPages, currentPage,onPressed));
    }

    return pageButtons;
  }

  Widget pageButton(int pageNum, int currentPage,VoidCallback onPressed) {
    bool isCurrent = pageNum == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          controllers.currentProspectPage.value = pageNum;
          onPressed();
        },
        onLongPress: (){
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent ? colorsConst.primary : colorsConst.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            //pageNum.toString().padLeft(2, '0'),
            pageNum.toString(),
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget ellipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text('...', style: TextStyle(fontSize: 18, color: Colors.black)),
    );
  }

  Widget selectHeatingType(
      String text,
      bool isSelected,
      VoidCallback onTap,
      bool isLast,
      RxString count,
      ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CustomText(
            text: text,
            colors: isSelected ? colorsConst.primary : colorsConst.textColor,
            isBold: true,
            size: 15,
            isCopy: false,
          ),
          10.width,
          CircleAvatar(
            backgroundColor:
            isSelected ? colorsConst.primary : colorsConst.secondary,
            radius: 15,
            child: Obx(
                  () => CustomText(
                text: count.value,
                colors: isSelected ? Colors.white : colorsConst.primary,
                size: 15,
                    isCopy: false,
              ),
            ),
          ),
          10.width,
          isLast
              ? 0.height
              : Container(
            width: 1,
            height: 22,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget selectHeatingType2(
      String text,
      bool isSelected,
      VoidCallback onTap,
      Color selectedColor,
      RxString count,
      {double? width=100}
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: customDecoration.baseBackgroundDecoration(
          borderColor: isSelected ? selectedColor : colorsConst.secondary,
          radius: 5,color:selectedColor.withOpacity(0.1)
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: text,
                colors: selectedColor,
                isBold: true,
                size: 17,
                isCopy: false,
              ),
              Obx(() => CustomText(
                    text: count.value,
                    colors: selectedColor,
                    size: 17,
                    isCopy: false,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textFieldNearText(String text, bool isOptional) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: Row(
        children: [
          CustomText(
            text: text,
            textAlign: TextAlign.start,
            colors: colorsConst.headColor,
            size: 15,
            isCopy: true,
          ),
          isOptional == true
              ? const CustomText(
                  text: "*",
                  colors: Colors.red,
                  size: 25,
            isCopy: false,
                )
              : 0.width
        ],
      ),
    );
  }

  String formatDateTime(String dates, String times) {
    try {
      List<String> dateList = dates.split("||");
      List<String> timeList = times.split("||");

      String startRaw = dateList[0].trim();
      String endRaw =
      dateList.length > 1 ? dateList[1].trim() : startRaw;

      String startTime = timeList[0].trim();
      String endTime =
      timeList.length > 1 ? timeList[1].trim() : startTime;

      DateTime now = DateTime.now();

      // 🔥 handle multiple date formats
      DateTime parseDate(String input) {
        try {
          return DateFormat("dd-MM-yyyy hh:mm a").parse(input);
        } catch (_) {
          try {
            return DateFormat("dd.MM.yyyy").parse(input);
          } catch (_) {
            return DateFormat("dd-MM-yyyy").parse(input);
          }
        }
      }

      DateTime start = parseDate(startRaw);
      DateTime end = parseDate(endRaw);

      // 🔥 FIX: support 03.42 PM format
      DateTime parseTime(String time, DateTime baseDate) {
        time = time.replaceAll(".", ":"); // ✅ முக்கிய fix

        final t = DateFormat("hh:mm a").parse(time);

        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          t.hour,
          t.minute,
        );
      }

      String formatDate(DateTime date) {
        if (date.year == now.year) {
          return DateFormat("dd/MM").format(date);
        } else {
          return DateFormat("dd/MM/yyyy").format(date);
        }
      }

      // ✅ SAME DATE → show duration
      if (DateFormat("yyyyMMdd").format(start) ==
          DateFormat("yyyyMMdd").format(end)) {

        DateTime startDateTime = parseTime(startTime, start);
        DateTime endDateTime = parseTime(endTime, end);

        Duration diff = endDateTime.difference(startDateTime);

        // 🔥 negative case handle (optional safety)
        if (diff.isNegative) {
          diff = diff.abs();
        }

        int hours = diff.inHours;
        int minutes = diff.inMinutes % 60;

        String duration = "";
        if (hours > 0) duration += "$hours hr";
        if (minutes > 0) duration += "$minutes min";
        if (duration.isEmpty) duration = "0 min";

        return "${formatDate(start)} $startTime ($duration)";
      }

      // ✅ DIFFERENT DATE → NO duration
      return "${formatDate(start)} $startTime to ${formatDate(end)} $endTime";

    } catch (e) {
      return "";
    }
  }

  void addAppointment(context){
  remController.assignedIds.value="";
  remController.assignedNames.value="";
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      String? titleError;
      String? stDateError;
      String? enDateError;
      String? stTimeError;
      String? enTimeError;
      String? customerError;
      // String? employeeError;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "New Appointment",
                  size: 14,
                  isBold: true,
                  isCopy: true,
                  colors: colorsConst.textColor,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.clear, color: Colors.black),
                )
              ],
            ),

            // ✅ CONTENT (NO SCROLL)
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Appointment Title",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          TextSpan(
                            text: "*",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 480,
                      child: TextField(
                        controller: controllers.meetingTitleCrt,
                        onChanged: (value) {
                          if (value.toString().isNotEmpty) {
                            setState(() => titleError = null);
                          }
                          controllers.firstCaps(value,controllers.meetingTitleCrt);
                        },
                        decoration: InputDecoration(
                          hintText: "Appointment Title",
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorsConst.primary,
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xffE1E5FA)),
                              borderRadius: BorderRadius.circular(5)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color(0xffE1E5FA)),
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                    if (titleError.toString().isNotEmpty)
                      CustomText(
                        text: titleError.toString(),
                        colors: Colors.red,
                        size: 12,
                        isCopy: false,
                      ),
                    5.height,
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Appointment Venue",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 480,
                      child: TextField(
                        controller: controllers.meetingVenueCrt,
                        onChanged: (value) {
                          // if (value.toString().isNotEmpty) {
                          //   setState(() => venueError = null);
                          // }
                          controllers.firstCaps(value,controllers.meetingVenueCrt);
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(5)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: colorsConst.primary,
                                ),
                                borderRadius: BorderRadius.circular(5)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: const Color(0xffE1E5FA)),
                                borderRadius: BorderRadius.circular(5)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: const Color(0xffE1E5FA)),
                                borderRadius: BorderRadius.circular(5)),
                            hintText: "Appointment Venue"
                        ),
                      ),
                    ),
                    10.height,
                    SizedBox(
                      width: 480,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "From Date",
                                      style: TextStyle(color: Colors.black, fontSize: 13),
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() => InkWell(
                                onTap: () {
                                  utils.datePicker(
                                    isFutureDate: true,
                                    context: context,
                                    textEditingController: controllers.dateOfConCtr,
                                    pathVal: controllers.fDate,
                                  );
                                  setState(() => stDateError = null);
                                },
                                child: Container(
                                  height: 40,
                                  width:220,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_outlined, size: 15),
                                      5.width,
                                      CustomText(
                                        text: controllers.fDate.value,
                                        isCopy: false,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              if (stDateError.toString().isNotEmpty)
                              CustomText(
                                  text: stDateError.toString(),
                                  colors: Colors.red,
                                  size: 12,
                                  isCopy: false,
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "From Time",
                                      style: TextStyle(color: Colors.black, fontSize: 13),
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() => InkWell(
                                onTap: () {
                                  utils.timePicker(
                                    context: context,
                                    textEditingController: controllers.dateOfConCtr,
                                    pathVal: controllers.fTime,
                                  );
                                  setState(() => stTimeError = null);
                                },
                                child: Container(
                                  height: 40,
                                  width:220,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 15),
                                      5.width,
                                      CustomText(
                                        text: controllers.fTime.value,
                                        isCopy: false,
                                      ),
                                    ],
                                  ),
                                ),
                              )),

                              if (stTimeError.toString().isNotEmpty)
                                CustomText(
                                  text: stTimeError.toString(),
                                  colors: Colors.red,
                                  size: 12,
                                  isCopy: false,
                                ),
                            ],
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     RichText(
                          //       text: const TextSpan(
                          //         children: [
                          //           TextSpan(
                          //             text: "To Date",
                          //             style: TextStyle(color: Colors.black, fontSize: 13),
                          //           ),
                          //           TextSpan(
                          //             text: "*",
                          //             style: TextStyle(color: Colors.red, fontSize: 13),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     Obx(() => InkWell(
                          //       onTap: () {
                          //         utils.datePicker(
                          //           context: context,
                          //           textEditingController: controllers.dateOfConCtr,
                          //           pathVal: controllers.toDate,
                          //         );
                          //         setState(() => enDateError = null);
                          //       },
                          //       child: Container(
                          //         height: 40,
                          //         width:120,
                          //         padding: const EdgeInsets.symmetric(horizontal: 10),
                          //         decoration: BoxDecoration(
                          //           border: Border.all(color: Colors.grey.shade400),
                          //           borderRadius: BorderRadius.circular(5),
                          //         ),
                          //         child: Row(
                          //           children: [
                          //             const Icon(Icons.calendar_month_outlined, size: 15),
                          //             5.width,
                          //             CustomText(
                          //               text: controllers.toDate.value,
                          //               isCopy: false,
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     )),
                          //     if (enDateError.toString().isNotEmpty)
                          //       CustomText(
                          //         text: enDateError.toString(),
                          //         colors: Colors.red,
                          //         size: 12,
                          //         isCopy: false,
                          //       ),
                          //   ],
                          // ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     RichText(
                          //       text: const TextSpan(
                          //         children: [
                          //           TextSpan(
                          //             text: "To Time",
                          //             style: TextStyle(color: Colors.black, fontSize: 13),
                          //           ),
                          //           TextSpan(
                          //             text: "*",
                          //             style: TextStyle(color: Colors.red, fontSize: 13),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //     Obx(() => InkWell(
                          //       onTap: () {
                          //         utils.timePicker(
                          //           context: context,
                          //           textEditingController: controllers.timeOfConCtr,
                          //           pathVal: controllers.toTime,
                          //         );
                          //         setState(() => enTimeError = null);
                          //       },
                          //       child: Container(
                          //         height: 40,
                          //         width:100,
                          //         padding: const EdgeInsets.symmetric(horizontal: 10),
                          //         decoration: BoxDecoration(
                          //           border: Border.all(color: Colors.grey.shade400),
                          //           borderRadius: BorderRadius.circular(5),
                          //         ),
                          //         child: Row(
                          //           children: [
                          //             const Icon(Icons.access_time, size: 15),
                          //             5.width,
                          //             CustomText(
                          //               text: controllers.toTime.value,
                          //               isCopy: false,
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     )),
                          //
                          //     if (enTimeError.toString().isNotEmpty)
                          //       CustomText(
                          //         text: enTimeError.toString(),
                          //         colors: Colors.red,
                          //         size: 12,
                          //         isCopy: false,
                          //       ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    /// CUSTOMER DROPDOWN
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Lead Name",
                                style: TextStyle(color: Colors.black, fontSize: 13),
                              ),
                              TextSpan(
                                text: "*",
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 480,
                          height: 50,
                          child: KeyboardDropdownField<AllCustomersObj>(
                            items: controllers.customers,
                            hintText: "Lead Name",
                            borderRadius: 5,
                            borderColor: Colors.grey.shade400,
                            labelBuilder: (customer) =>
                            '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                            itemBuilder: (customer) =>
                                Container(
                                  width: 300,
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: CustomText(
                                    text:
                                    '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                                    colors: Colors.black,
                                    size: 14,
                                    isCopy: false,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                            textEditingController: controllers.cusController,
                            onSelected: (value) {
                              setState(() => customerError = null);
                              controllers.selectCustomer(value);
                            },
                            onClear: () {
                              controllers.clearSelectedCustomer();
                            },
                          ),
                        ),
                        if (customerError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              customerError!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                    10.height,
                    Row(
                      children: [
                        CustomText(
                          text: "Employees",
                          size: 13,
                          isCopy: false,
                        ),
                      ],
                    ),2.height,
                    SearchCustomDropdown(
                      text: "",isOptional: false,
                      hintText: remController.assignedIds.value==""?"":remController.assignedNames.value,
                      valueList: controllers.employees,
                      onChanged: (value) {
                        setState((){
                          // employeeError=null;
                        });
                      },
                      width: 480,
                    ),
                    10.height,
                    // if (employeeError != null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 4),
                    //     child: Text(
                    //       employeeError!,
                    //       style: const TextStyle(
                    //           color: Colors.red, fontSize: 13),
                    //     ),
                    //   ),
                    10.height,
                    /// NOTES
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(text: "Notes", size: 13, isCopy: false,),
                        SizedBox(
                          width: 480,
                          // height: 40,
                          child: TextField(
                            controller: controllers.callCommentCont,
                            maxLines: null,
                            onChanged: (value){
                              controllers.firstCaps(value,controllers.callCommentCont);
                            },
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: "Notes",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(5)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorsConst.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(5)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: const Color(0xffE1E5FA)),
                                  borderRadius: BorderRadius.circular(5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: const Color(0xffE1E5FA)),
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            /// ACTIONS
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const CustomText(text: "Cancel",isCopy: false,colors: Colors.grey,),
                  ),

                  const SizedBox(width: 10),

                  CustomLoadingButton(
                    controller: controllers.productCtr,
                    text: "Set",
                    callback: () {

                      if (controllers.meetingTitleCrt.text.isEmpty) {
                        setState(() => titleError = "Enter title");
                        controllers.productCtr.reset();
                        return;
                      }

                      // if (controllers.meetingVenueCrt.text.isEmpty) {
                      //   setState(() => venueError = "Enter venue");
                      //   controllers.productCtr.reset();
                      //   return;
                      // }

                      if (controllers.fDate.value.isEmpty) {
                        setState(() => stDateError = "Select start date");
                        controllers.productCtr.reset();
                        return;
                      }

                      if (controllers.fTime.value.isEmpty) {
                        setState(() => stTimeError = "Select from time");
                        controllers.productCtr.reset();
                        return;
                      }
                      final selectedDate = DateFormat("dd-MM-yyyy") .parse(controllers.fDate.value);
                      final selectedTime = DateFormat("h:mm a") .parse(controllers.fTime.value);
                      final now = DateTime.now();
                      final selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                      final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;

                      if (isToday && selectedDateTime.isBefore(now)) {
                        setState(() {
                          stTimeError = "Please select a future time";
                        });
                        controllers.productCtr.reset();
                        return;
                      }
                      setState(() {
                        stTimeError = null;
                      });

                      // if (controllers.toDate.value.isEmpty) {
                      //   setState(() => enDateError = "Select end date");
                      //   controllers.productCtr.reset();
                      //   return;
                      // }
                      //
                      // if (controllers.toTime.value.isEmpty) {
                      //   setState(() => enTimeError = "Select to time");
                      //   controllers.productCtr.reset();
                      //   return;
                      // }

                      if (controllers.selectedCustomerId.value.isEmpty) {
                        setState(() => customerError = "Select lead name");
                        controllers.productCtr.reset();
                        return;
                      }
                      // if (controllers.selectedEmployeeId.value.isEmpty) {
                      //   setState(() => employeeError = "Select employee name");
                      //   controllers.productCtr.reset();
                      //   return;
                      // }
                      controllers.toDate.value = controllers.fDate.value;
                      final time = DateFormat('h:mm a').parse(controllers.fTime.value);

                      controllers.toTime.value =
                          DateFormat('h:mm a').format(
                            time.add(const Duration(minutes: 30)),
                          );
                      apiService.insertMeetingDetailsAPI(context);
                    }, isLoading: true, backgroundColor: colorsConst.primary, radius: 5, width: 100,
                  ),
                ],
              )
            ],
          );
        },
      );
    },
  );
}

void appointmentStatus(context,String value){
  String? selectedValue=value;
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // 🔥 important
        builder: (context, setState) {
          return AlertDialog(
            title: CustomText(text: "Update Appointment Status",isCopy: false,isBold: true,size: 16,),
            content: SizedBox(
              width: 300,
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                hint: CustomText(text: "Select",isCopy: false,),
                isExpanded: true,
                items: ["Scheduled", "Completed", "Cancelled"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: CustomText(text: e,isCopy: false,),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: CustomText(text:"Cancel",isCopy: false,colors: Colors.grey,),
                  ),10.width,
                  CustomLoadingButton(
                    callback: ()async{
                      apiService.updateAppointmentStatus(context,selectedValue.toString());
                    },
                    height: 35,
                    isLoading: true,
                    backgroundColor: colorsConst.primary,
                    radius: 2,
                    width: 80,
                    controller: controllers.productCtr,
                    isImage: false,
                    text: "Save",
                    textColor: Colors.white,
                  ),
                ],
              )
            ],
          );
        },
      );
    },
  );
}
  Future<void> timePicker({
    BuildContext? context,
    TextEditingController? textEditingController,
    RxString? pathVal,
  }) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context!,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final String formattedTime =
      MaterialLocalizations.of(context).formatTimeOfDay(
        pickedTime,
        alwaysUse24HourFormat: false,
      );

      textEditingController?.text = formattedTime;
      pathVal?.value = formattedTime;
    }
  }

  Future<void> callTimePicker({
    BuildContext? context,
    TextEditingController? textEditingController,
    RxString? pathVal,
  }) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context!,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      String formattedTime =
      MaterialLocalizations.of(context).formatTimeOfDay(
        pickedTime,
        alwaysUse24HourFormat: false,
      );

      // 03:48 PM -> 03.48 PM
      formattedTime = formattedTime.replaceAll(':', '.');

      textEditingController?.text = formattedTime;
      pathVal?.value = formattedTime;
    }
  }

  Future<void> datePicker({
    BuildContext? context,
    TextEditingController? textEditingController,
    required RxString pathVal,
    required bool isFutureDate,
  }) async {

    DateTime dateTime = DateTime.now();

    debugPrint("---- DATE PICKER OPEN ----");
    debugPrint("Controller Text : ${textEditingController?.text}");

    // ---------- Parse Existing Date ----------
    if (pathVal.value!="") {

      try {

        String cleaned = pathVal.value
            .replaceAll("/", "-")
            .replaceAll(".", "-")
            .trim();

        debugPrint("Cleaned Date String : $cleaned");

        List<String> parts = cleaned.split("-");

        debugPrint("Split Parts : $parts");

        if (parts.length == 3) {

          int p1 = int.tryParse(parts[0]) ?? 0;
          int p2 = int.tryParse(parts[1]) ?? 0;
          int p3 = int.tryParse(parts[2]) ?? 0;

          debugPrint("Parsed => p1:$p1  p2:$p2  p3:$p3");

          // Detect format
          if (p1 > 31) {
            // YYYY-MM-DD
            dateTime = DateTime(p1, p2, p3);
            debugPrint("Format Detected : YYYY-MM-DD");

          } else {
            // DD-MM-YYYY
            dateTime = DateTime(p3, p2, p1);
            debugPrint("Format Detected : DD-MM-YYYY");
          }

          debugPrint("Initial DateTime Set : $dateTime");
        }

      } catch (e) {
        debugPrint("Date Parse Error : $e");
        dateTime = DateTime.now();
      }
    }

    debugPrint("Opening DatePicker with Initial Date : $dateTime");

    // ---------- Show Date Picker ----------
    final value = await showDatePicker(
      context: context!,
      initialDate: dateTime,
      firstDate: isFutureDate==true?DateTime.now():DateTime(2026),
      lastDate: isFutureDate==true?DateTime(DateTime.now().year+1,DateTime.now().month,DateTime.now().day,):DateTime.now(),
    );

    debugPrint("Selected Date From Picker : $value");

    // ---------- Set Selected Date ----------
    if (value != null) {

      dateTime = value;

      String formattedDate =
          "${dateTime.day.toString().padLeft(2, "0")}-"
          "${dateTime.month.toString().padLeft(2, "0")}-"
          "${dateTime.year}";

      debugPrint("Formatted Date : $formattedDate");

      textEditingController?.text = formattedDate;
      pathVal?.value = formattedDate;
      if (remController.stDate.value.isNotEmpty &&
          remController.enDate.value.isNotEmpty) {

        DateTime start = DateFormat("dd-MM-yyyy")
            .parse(remController.stDate.value);

        DateTime end = DateFormat("dd-MM-yyyy")
            .parse(remController.enDate.value);

        if (end.isBefore(start)) {
          utils.showToast("End date cannot be before start date", Colors.red);
          remController.enDate.value = "";
          controllers.dateOfConCtr.clear();
          return;
        }
      }
      // debugPrint("Controller Updated Successfully ✅");

    } else {
      debugPrint("User Cancelled Date Picker ❌");
    }
    controllers.prospectDate.value=controllers.empDOB.value;
    debugPrint("---- DATE PICKER END ----");
  }
  Future<void> callDatePicker({
    BuildContext? context,
    TextEditingController? textEditingController,
    required RxString pathVal,
  }) async {

    DateTime dateTime = DateTime.now();

    debugPrint("---- DATE PICKER OPEN ----");
    debugPrint("Controller Text : ${textEditingController?.text}");

    // ---------- Parse Existing Date ----------
    if (pathVal.value!="") {

      try {

        String cleaned = pathVal.value
            .replaceAll("/", "-")
            .replaceAll(".", "-")
            .trim();

        debugPrint("Cleaned Date String : $cleaned");

        List<String> parts = cleaned.split("-");

        debugPrint("Split Parts : $parts");

        if (parts.length == 3) {

          int p1 = int.tryParse(parts[0]) ?? 0;
          int p2 = int.tryParse(parts[1]) ?? 0;
          int p3 = int.tryParse(parts[2]) ?? 0;

          debugPrint("Parsed => p1:$p1  p2:$p2  p3:$p3");

          // Detect format
          if (p1 > 31) {
            // YYYY-MM-DD
            dateTime = DateTime(p1, p2, p3);
            debugPrint("Format Detected : YYYY-MM-DD");

          } else {
            // DD-MM-YYYY
            dateTime = DateTime(p3, p2, p1);
            debugPrint("Format Detected : DD-MM-YYYY");
          }

          debugPrint("Initial DateTime Set : $dateTime");
        }

      } catch (e) {
        debugPrint("Date Parse Error : $e");
        dateTime = DateTime.now();
      }
    }

    debugPrint("Opening DatePicker with Initial Date : $dateTime");

    // ---------- Show Date Picker ----------
    final value = await showDatePicker(
      context: context!,
      initialDate: dateTime,
      firstDate: DateTime(DateTime.now().year - 1, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            disabledColor: Colors.grey.shade100,
          ),
          child: child!,
        );
      },
    );

    debugPrint("Selected Date From Picker : $value");

    // ---------- Set Selected Date ----------
    if (value != null) {

      dateTime = value;

      String formattedDate =
          "${dateTime.day.toString().padLeft(2, "0")}-"
          "${dateTime.month.toString().padLeft(2, "0")}-"
          "${dateTime.year}";

      debugPrint("Formatted Date : $formattedDate");

      textEditingController?.text = formattedDate;
      pathVal.value = formattedDate;

      // debugPrint("Controller Updated Successfully ✅");

    } else {
      debugPrint("User Cancelled Date Picker ❌");
    }

    debugPrint("---- DATE PICKER END ----");
  }


  Future<void> chooseFile({RxList? mediaDataV, RxString? fileName, RxString? pathName}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg', 'ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx'],
    );
    if (result != null) {
      fileName?.value = result.files.single.name;
      debugPrint("file name ${result.files.single.name}");
      mediaDataV?.value = result.files.single.bytes!.toList();
      pathName?.value = base64.encode(result.files.single.bytes!.toList());
    } else {
      debugPrint('No file selected');
    }
  }
  TableRow emailRow(BuildContext context,
      {RxBool? isCheck, String? templateName, String? subject, String? msg, String? id}) {
    return TableRow(
        decoration: BoxDecoration(color: colorsConst.secondary),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.width,
              SizedBox(
                width: 15,
                height: 15,
                child: Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  side: MaterialStateBorderSide.resolveWith(
                    (states) =>
                        BorderSide(width: 1.0, color: colorsConst.textColor),
                  ),
                  checkColor: Colors.white,
                  activeColor: colorsConst.third,
                  value: isCheck?.value,
                  onChanged: (value) {
                    controllers.isTemplate.value = false;
                    controllers.emailSubjectCtr.text = subject.toString().replaceAll('\n', ' ');
                    controllers.emailMessageCtr.text = msg.toString();
                    controllers.emailQuotationCtr.text = templateName.toString();
                  },
                ),
              ),10.width,
              InkWell(
                onTap: (){
                  // Navigator.of(context).pop();
                  settingsController.addNameController.text = templateName.toString();
                  settingsController.addSubjectController.text = subject.toString();
                  settingsController.addMessageController.text = msg.toString();
                  settingsController.showAddTemplateDialog(context, isEdit: true,id: id.toString());
                },
                child: SvgPicture.asset(
                  "assets/images/a_edit.svg",
                ),
              ),
              20.width,
              Container(
                alignment: Alignment.center,
                height: 50,
                child: CustomText(
                  textAlign: TextAlign.center,
                  text: templateName.toString(),
                  colors: colorsConst.textColor,
                  size: 13,
                  isCopy: false,
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            height: 50,
            child: CustomText(
              textAlign: TextAlign.center,
              text: subject.toString(),
              colors: colorsConst.textColor,
              isCopy: false,
              size: 13,
            ),
          ),
        ]);
  }

  Future<void> pickAndReadExcelFile(BuildContext context, String leadStatus) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) {
      controllers.customerCtr.reset();
      return;
    }
    parseExcelFile(result.files.single.bytes!, context, leadStatus);
  }

  List<Map<String, dynamic>> customerData = [];
  List<Map<String, dynamic>> mCustomerData = [];

  void parseExcelFile(
      Uint8List bytes,
      BuildContext context,
      String leadStatus,
      ) async
  {
    print(bytes.length);
    print(bytes.take(20).toList());

    customerData = [];
    controllers.customerCtr.start();

    try {
      final excelD = SpreadsheetDecoder.decodeBytes(bytes);

      for (var tableName in excelD.tables.keys) {
        var rows = excelD.tables[tableName]!.rows;

        debugPrint("rows $rows");

        if (rows.length < 6) {
          Navigator.of(context).pop();
          apiService.errorDialog(
            context,
            "Excel format is invalid. Needs min 6 rows (3 empty, system, display, billing_data).",
          );
          return;
        }

        const expectedKeys = [
          "name",
          "phone_no",
          "email",
          "city",
          "owner",
          "designation",
          "department",
          "company_name",
          "source",
          "source_details",
          "lead_status",
          "prospect_enrollment_date",
          "expected_convertion_date",
          "details_of_service_required",
          "discussion_point",
          "product_discussion",
          "rating",
          "status_update",
          "status",
          "num_of_headcount",
          "expected_billing_value",
          "arpu_value",
          "expected_billing_value",
        ];

        // Row 4 = system keys
        List<String> systemKeys = rows[3]
            .map((c) => c?.toString().trim() ?? "")
            .toList();

        if (systemKeys.every((e) => e.isEmpty)) {
          Navigator.of(context).pop();
          apiService.errorDialog(
            context,
            "Excel format invalid. Row 4 (system fields) cannot be empty.",
          );
          return;
        }

        final missing =
        expectedKeys.where((key) => !systemKeys.contains(key)).toList();

        if (missing.isNotEmpty) {
          Navigator.of(context).pop();
          apiService.errorDialog(
            context,
            "Please enter correct system fields. Missing or incorrect: ${missing.join(', ')}",
          );
          return;
        }

        // Row 5 = display names
        List<String> displayNames = rows[4]
            .map((c) => c?.toString().trim() ?? "")
            .toList();

        if (displayNames.every((e) => e.isEmpty)) {
          Navigator.of(context).pop();
          apiService.errorDialog(
            context,
            "Excel format invalid. Row 5 (display headings) cannot be empty.",
          );
          return;
        }

        // Field mappings
        List<Map<String, String>> fieldMappings = [];

        for (int i = 0; i < systemKeys.length; i++) {
          if (systemKeys[i].isNotEmpty) {
            fieldMappings.add({
              "cos_id": controllers.storage.read("cos_id").toString(),
              "system_field": systemKeys[i],
              "display_name":
              (i < displayNames.length && displayNames[i].isNotEmpty)
                  ? displayNames[i]
                  : systemKeys[i],
              "created_by": controllers.storage.read("id").toString(),
            });
          }
        }

        // Billing rows
        for (int i = 5; i < rows.length; i++) {
          var row = rows[i];

          bool isRowEmpty = row.every(
                (cell) => cell == null || cell.toString().trim().isEmpty,
          );

          if (isRowEmpty) continue;

          Map<String, dynamic> formattedData = {};
          List<Map<String, String>> additionalFields = [];

          for (int j = 0; j < systemKeys.length; j++) {
            String key = systemKeys[j];

            String value = "";

            if (j < row.length) {
              value = row[j]?.toString().trim() ?? "";
            }

            if (key.isNotEmpty) {
              formattedData[key] = value;
            } else {
              additionalFields.add({
                "field_name":
                (j < displayNames.length) ? displayNames[j] : "",
                "field_value": value,
              });
            }
          }

          formattedData["user_id"] =
              controllers.storage.read("id").toString();

          formattedData["cos_id"] =
              controllers.storage.read("cos_id").toString();

          formattedData["lead_status"] = leadStatus == "0"
              ? "0"
              : (formattedData["lead_status"] ?? leadStatus);

          formattedData["additional_fields"] = additionalFields;

          customerData.add(formattedData);
        }

        Map<String, dynamic> finalPayload = {
          "field_mappings": fieldMappings,
          "cusList": customerData,
        };

        debugPrint("Payload: ${jsonEncode(finalPayload)}");

        await apiService.insertCustomersAPI(
          context,
          customerData,
          fieldMappings,
          bytes,
          "CRMSheet",
        );
      }
    } catch (e, s) {
      debugPrint("Excel Decode Error: $e");
      debugPrint("$s");

      Navigator.of(context).pop();

      apiService.errorDialog(
        context,
        "Invalid Excel file. Please upload a valid .xlsx file.",
      );
    }
  }

  Future<void> downloadSampleExcel() async {
    try {
      final data = await rootBundle.load("assets/easycrm_data_upload_template.xlsx");
      await saveBytes("easycrm_data_upload_template.xlsx", data.buffer.asUint8List());
    } catch (e) {
      debugPrint("Download Error: $e");
    }
  }

  Future<void> showImportDialogThirumal(BuildContext context,String leadStatus) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(5),
          backgroundColor: colorsConst.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: 350,
            height: 500,
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    colors: colorsConst.third,
                    text: "Your uploaded Excel file should have columns matching the required fields exactly as listed below to ensure correct billing_data insertion:",
                    isBold: true,
                    isCopy: true,
                    size: 15,
                    textAlign: TextAlign.start,
                  ),
                  10.height,
                  CustomText(
                    text: "Column Names:",
                    colors: colorsConst.textColor,
                    size: 15,
                    isBold: true,
                    isCopy: true,
                  ),
                  5.height,
                  dialogText("NAME OF THE ACCOUNT MANAGER"),
                  dialogText("NAME OF THE CUSTOMER"),
                  dialogText("KEY CONTACT PERSON"),
                  dialogText("CONTACT NUMBER"),
                  dialogText("EMAIL ID"),
                  dialogText("SITE LOCATION DETAILS"),
                  dialogText("SOURCE OF PROSPECT (either BNI or social)"),
                  dialogText("LEAD / PROSPECT"),
                  dialogText("PROSPECT SOURCE DETAILS"),
                  dialogText("PROSPECT ENROLLMENT DATE"),
                  dialogText("EXPECTED CONVERSION DATE"),
                  dialogText("DETAILS OF SERVICES REQUIRED"),
                  dialogText("PROSPECT GRADING"),
                  dialogText("STATUS UPDATE"),
                  dialogText("TOTAL NUMBER OF HEAD COUNT"),
                  dialogText("EXPECTED MONTHLY BILLING VALUE"),
                  dialogText("ARPU VALUE"),
                  dialogText("CURRENT STATUS"),
                  10.height,
                  CustomText(
                    text: "File format:",
                    colors: colorsConst.textColor,
                    size: 15,
                    isBold: true,
                    isCopy: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 5, 5, 5),
                    child: CustomText(
                      textAlign: TextAlign.start,
                      text: '.xlsx, .xls',
                      colors: colorsConst.textColor,
                      size: 14,
                      isCopy: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: colorsConst.third,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: colorsConst.third))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const CustomText(
                      text: "Cancel",
                      colors: Colors.white,
                      isBold: true,
                      size: 15,
                      isCopy: false,
                    ),
                  ),
                ),
                10.width,
                CustomLoadingButton(
                  callback: () {
                    thiPickAndReadExcelFile(context,leadStatus);
                  },
                  isLoading: true,
                  backgroundColor: colorsConst.secondary,
                  radius: 5,
                  width: 120,
                  controller: controllers.customerCtr,
                  text: "Import",
                  isImage: false,
                  textColor: colorsConst.textColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget dialogText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 2, 5, 2),
      child: CustomText(
        textAlign: TextAlign.start,
        text: text,
        colors: colorsConst.textColor,
        size: 13,
        isCopy: false,
      ),
    );
  }

  Future<void> thiPickAndReadExcelFile(BuildContext context, String leadStatus) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    thiParseExcelFile(result.files.single.bytes!, context, leadStatus);
  }

  List<Map<String, dynamic>> thiCustomerData = [];
  List<Map<String, dynamic>> thiMCustomerData = [];

  void thiParseExcelFile(Uint8List bytes, BuildContext context, String leadStatus) async {
    thiCustomerData = [];
    var excelD = excel.Excel.decodeBytes(bytes);

    Map<String, String> keyMapping = {
      "SITE LOCATION DETAILS": "city",
      "LEAD / PROSPECT": "lead_status",
      "CURRENT STATUS": "status",
      "NAME OF THE CUSTOMER": "company_name",
      "DETAILS OF SERVICES REQUIRED": "details_of_service_required",
      "NAME OF THE ACCOUNT MANAGER": "owner",
      "PROSPECT ENROLLMENT DATE": "prospect_enrollment_date",
      "EXPECTED CONVERSION DATE": "expected_convertion_date",
      "STATUS UPDATE": "status_update",
      "TOTAL NUMBER OF HEAD COUNT": "num_of_headcount",
      "EXPECTED MONTHLY BILLING VALUE": "expected_billing_value",
      "ARPU VALUE": "arpu_value",
      "KEY CONTACT PERSON": "name",
      "EMAIL ID": "email",
      "CONTACT NUMBER": "phone_no",
      "SOURCE OF PROSPECT (either BNI or social)": "source",
      "PROSPECT SOURCE DETAILS": "source_details",
      "PROSPECT GRADING": "rating"
    };

    for (var table in excelD.tables.keys) {
      var rows = excelD.tables[table]!.rows;

      List<String> headers = rows.first.map((cell) => (cell?.value.toString().trim().toUpperCase()) ?? "").toList();

      List<String> missingColumns = [];

      for (var key in keyMapping.keys) {
        if (!headers.contains(key.toUpperCase().trim())) {
          missingColumns.add(key);
        }
      }

      debugPrint("missingColumns: $missingColumns");

      if (missingColumns.isNotEmpty) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorsConst.primary,
            title: CustomText(
              text: "Missing Columns",
              colors: colorsConst.textColor,
              size: 18,
              isCopy: true,
              isBold: true,
            ),
            content: CustomText(
              text: "The following columns are missing:\n\n${missingColumns.join(", ")}",
              colors: colorsConst.textColor,
              isCopy: true,
              size: 16,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: CustomText(
                  text: "OK",
                  colors: colorsConst.textColor,
                  size: 16,
                  isCopy: false,
                ),
              ),
            ],
          ),
        );
        return;
      }

      for (var i = 1; i < rows.length; i++) {
        var row = rows[i];
        Map<String, dynamic> rowData = {};
        Map<String, dynamic> formattedData = {};
        bool isRowEmpty = row.every((cell) =>
        cell == null || cell.value == null || cell.value.toString().trim().isEmpty);

        if (isRowEmpty) continue;

        for (var j = 0; j < headers.length; j++) {
          String header = headers[j];
          rowData[header] = row[j]?.value;
        }

        rowData.forEach((key, value) {
          String matchedKey = keyMapping.keys.firstWhere(
                (mappedKey) => mappedKey.toUpperCase().trim() == key.toUpperCase().trim(),
            orElse: () => "",
          );
          if (matchedKey.isNotEmpty) {
            String mappedField = keyMapping[matchedKey]!;
            if (mappedField == "rating") {
              formattedData[mappedField] = value != null && value.toString().isNotEmpty ? value : "WARM";
            }else if (mappedField == "lead_status") {
              formattedData[mappedField] = leadStatus!="0" ? value : "0";
            } else {
              formattedData[mappedField] = value;
            }
          }
        });

        if (rowData.containsKey("CONTACT NUMBER")) {
          formattedData["whatsapp_no"] = rowData["CONTACT NUMBER"];
        }

        // Add extra fields
        formattedData["user_id"] = controllers.storage.read("id");
        formattedData["cos_id"] = controllers.storage.read("cos_id");
        formattedData["door_no"] = "";
        formattedData["area"] = "";
        formattedData["country"] = "India";
        formattedData["state"] = "Tamil Nadu";
        formattedData["pincode"] = "";
        formattedData["product_discussion"] = "";
        formattedData["discussion_point"] = "";
        formattedData["points"] = "";
        formattedData["department"] = "";
        formattedData["designation"] = "";
        if (!formattedData.containsKey("source")) {
          formattedData["source"] = "";
        }

        if ((formattedData["phone_no"] != null && formattedData["phone_no"].toString().isNotEmpty) ||
            (formattedData["name"] != null && formattedData["name"].toString().isNotEmpty)) {
          thiCustomerData.add(formattedData);
        } else {
          if (formattedData["email"] != null && formattedData["email"].toString().isNotEmpty) {
            thiCustomerData.add(formattedData);
          } else {
            thiMCustomerData.add(formattedData);
          }
        }
      }
    }

    debugPrint("mCustomerData ${thiMCustomerData.length}");
    debugPrint("customerData ${thiCustomerData.length}");

    if (thiCustomerData.isEmpty) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colorsConst.primary,
          content: CustomText(
            text: "Some entries under KEY CONTACT PERSON and CONTACT NUMBER are empty in your Excel sheet. Please check and re-upload.",
            colors: colorsConst.textColor,
            size: 16,
            isCopy: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(
                text: "OK",
                colors: colorsConst.textColor,
                size: 16,
                isCopy: false,
              ),
            ),
          ],
        ),
      );
      return;
    } else {
      await apiService.insertThirumalCustomersAPI(context, thiCustomerData);
    }
  }

  Future<void> showImportDialog(BuildContext context,String leadStatus) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: SizedBox(
            width: 350,
            height: 340,
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "File format: .xlsx, .xls",
                    colors: colorsConst.textColor,
                    size: 17,
                    isBold: true,
                    isCopy: true,
                  ),
                  10.height,
                  SizedBox(
                    width: 340,
                    child: Text(
                      "In this CRM template, \n\n1. Place your column names on Row 5. This will appear in EasyCRM as Heading.\n\n2. Place your billing_data from Row 6. \n\n3. Pick the CRM internal field designators from Row 4 and place it over correct heading on Row 5.\n\n4. Save the sheet and upload to EasyCRM and start managing your Leads and Customers.",
                      style: TextStyle(
                        color: colorsConst.textColor,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  10.height,
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          backgroundColor: colorsConst.third,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(color: colorsConst.third))),
                      onPressed: () {
                       // if(controllers.serverSheet.value.isEmpty){
                          debugPrint("Local Download");
                          downloadSampleExcel();
                       //  }else{
                       //    debugPrint("Network Download");
                       //    downloadSheetFromNetwork(controllers.serverSheet.value, "easycrm_data_upload_template.xlsx");
                        // }
                      },
                      child: const CustomText(
                        text: "Download Sample Excel Sheet",
                        colors: Colors.white,
                        isBold: true,
                        size: 15,
                        isCopy: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: colorsConst.third,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: colorsConst.third))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const CustomText(
                      text: "Cancel",
                      colors: Colors.white,
                      isBold: true,
                      isCopy :false,
                      size: 15,
                    ),
                  ),
                ),
                10.width,
                CustomLoadingButton(
                  callback: () {
                    pickAndReadExcelFile(context,leadStatus);
                    controllers.customerCtr.reset();
                  },
                  isLoading: true,
                  backgroundColor: colorsConst.secondary,
                  radius: 5,
                  width: 120,
                  controller: controllers.customerCtr,
                  text: "Import",
                  isImage: false,
                  textColor: colorsConst.primary,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void updateDialog(){
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder:(context){
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.white,
              title:  Text(
                "Update Available?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:colorsConst.textColor,
                  fontFamily: "Lato",
                ),
              ),
              content: SizedBox(
                //height: 300,
                width: 300,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(()=>Text(
                      "A new version of CRM is available! \nCurrent:$versionNum -> Latest:${controllers.serverVersion}",
                      style: TextStyle(
                          fontSize:15,
                          fontWeight: FontWeight.w500,
                          color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                    ),
                    10.height,
                        Text(
                          "Update now to enjoy the latest \nfeatures and improvements.",
                          style: TextStyle(
                              fontSize:15,
                              fontWeight: FontWeight.w500,
                              color:colorsConst.textColor
                          ),
                          textAlign: TextAlign.start,
                        ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DialogButton(
                            text: "IGNORE",
                            width: 90,
                            onPress: (){
                              SystemNavigator.pop();
                            }),
                        DialogButton(
                            text: "LATER",
                            width: 90,
                            onPress: (){
                              Navigator.pop(Get.context!);
                            }),
                        DialogButton(
                            text: "UPDATE",
                            width: 90,
                            onPress: (){
                              // utils.makingWebsite(web: "https://play.google.com/store/apps/details?id=com.hapiapps.anpace6");
                              utils.makingWebsite(web: controllers.currentApk.value);
                            }),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void showCallDialog(context,String text,VoidCallback callBack,bool isLead){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String customerError = "";
        String dateError = "";
        String timeError = "";

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                width: 600,
                constraints: const BoxConstraints(maxHeight: 510),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: text,
                            size: 16,
                            isBold: true,
                            isCopy: false,
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.clear),
                          )
                        ],
                      ),
                      Divider(color: Colors.grey.shade200,),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// CUSTOMER
                            if(isLead==false)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Lead Name ",
                                        style: TextStyle(color: Colors.black, fontSize: 13),
                                      ),
                                      TextSpan(
                                        text: "*",
                                        style: TextStyle(color: Colors.red, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                5.height,
                                SizedBox(
                                  height: 45,
                                  child: KeyboardDropdownField<AllCustomersObj>(
                                    items: controllers.customers,
                                    borderRadius: 5,
                                    borderColor: Colors.grey.shade400,
                                    hintText: "Customers",
                                    labelText: "",

                                    labelBuilder: (customer) =>
                                    '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',

                                    itemBuilder: (customer) {
                                      return Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: CustomText(
                                          text:
                                          '${customer.name}${customer.companyName.toString().isEmpty ? "" : ", ${customer.companyName}"} ${customer.name.toString().isEmpty ? "" : "-"} ${customer.phoneNo} - ${customer.category}',
                                          size: 14,
                                          isCopy: false,
                                        ),
                                      );
                                    },

                                    textEditingController: controllers.cusController,

                                    onSelected: (value) {
                                      controllers.selectCustomer(value);
                                      setState(() => customerError = "");
                                    },

                                    onClear: () {
                                      controllers.clearSelectedCustomer();
                                      setState(() => customerError = "Please select lead");
                                    },
                                  ),
                                ),
                                if (customerError.isNotEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: CustomText(
                                      text: customerError,
                                      colors: Colors.red,
                                      size: 12,
                                      isCopy: false,
                                    ),
                                  ),
                              ],
                            ),
                            10.height,

                            /// DATE & TIME
                            Row(
                              children: [

                                /// DATE
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Date ",
                                              style: TextStyle(color: Colors.black, fontSize: 13),
                                            ),
                                            TextSpan(
                                              text: "*",
                                              style: TextStyle(color: Colors.red, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      5.height,

                                      Obx(() => InkWell(
                                        onTap: () async {
                                          await utils.callDatePicker(
                                            context: context,
                                            textEditingController: controllers.dateOfConCtr,
                                            pathVal: controllers.empDOB,
                                          );
                                          setState(() => dateError = "");
                                        },
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_month_outlined, size: 15),
                                              5.width,
                                              CustomText(
                                                text: controllers.empDOB.value,
                                                isCopy: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),

                                      if (dateError.isNotEmpty)
                                        CustomText(
                                          text: dateError,
                                          colors: Colors.red,
                                          size: 12,
                                          isCopy: false,
                                        ),
                                    ],
                                  ),
                                ),

                                10.width,

                                /// TIME
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Time ",
                                              style: TextStyle(color: Colors.black, fontSize: 13),
                                            ),
                                            TextSpan(
                                              text: "*",
                                              style: TextStyle(color: Colors.red, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      5.height,

                                      Obx(() => InkWell(
                                        onTap: () async {
                                          await utils.callTimePicker(
                                            context: context,
                                            textEditingController: controllers.timeOfConCtr,
                                            pathVal: controllers.callTime,
                                          );
                                          setState(() => timeError = "");
                                        },
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.access_time, size: 15),
                                              5.width,
                                              CustomText(
                                                text: controllers.callTime.value,
                                                isCopy: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),

                                      if (timeError.isNotEmpty)
                                        CustomText(
                                          text: timeError,
                                          colors: Colors.red,
                                          size: 12,
                                          isCopy: false,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            10.height,

                            /// CALL TYPE
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "In/Out",
                                    style: TextStyle(color: Colors.black, fontSize: 13),
                                  ),
                                  TextSpan(
                                    text: "*",
                                    style: TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),

                            Wrap(
                              spacing: 10,
                              children: controllers.callTypeList.map<Widget>((type) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: type,
                                      groupValue: controllers.callType,
                                      onChanged: (v) {
                                        setState(() {
                                          controllers.callType = v!;
                                        });
                                      },
                                    ),
                                    CustomText(text: type, isCopy: false),
                                  ],
                                );
                              }).toList(),
                            ),

                            10.height,

                            /// STATUS
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Status ",
                                    style: TextStyle(color: Colors.black, fontSize: 13),
                                  ),
                                  TextSpan(
                                    text: "*",
                                    style: TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),

                            Obx(() => Wrap(
                              spacing: 10,
                              runSpacing: 5,
                              children: controllers.hCallStatusList.map<Widget>((item) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<String>(
                                      value: item["value"],
                                      groupValue: controllers.callStatus,
                                      onChanged: (v) {
                                        setState(() {
                                          controllers.callStatus = v!;
                                        });
                                      },
                                    ),
                                    CustomText(text: item["value"], isCopy: false),
                                  ],
                                );
                              }).toList(),
                            )),

                            10.height,

                            /// NOTES
                            CustomText(text: "Notes", isCopy: false),
                            5.height,

                            Container(
                              constraints: const BoxConstraints(
                                minHeight: 80,
                                maxHeight: 200,
                              ),
                              child: TextField(
                                controller: controllers.callCommentCont,
                                maxLines: null,
                                onChanged: (value){
                                  controllers.firstCaps(value, controllers.callCommentCont);
                                },
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: CustomText(
                              text: "Cancel",
                              colors: colorsConst.primary,
                              isCopy: false,
                            ),
                          ),
                          10.width,
                          ElevatedButton(
                            onPressed: (){
                              bool isValid = true;

                              if (isLead==false&&controllers.selectedCustomerId.value.isEmpty) {
                                customerError = "Please select lead";
                                isValid = false;
                              }

                              if (controllers.empDOB.value.isEmpty) {
                                dateError = "Please select date";
                                isValid = false;
                              }

                              if (controllers.callTime.value.isEmpty) {
                                timeError = "Please select time";
                                isValid = false;
                              }

                              setState(() {});

                              if (!isValid) return;

                              callBack();
                            },
                            child: const Text("Save"),
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
      },
    );
  }

  void showFilterDialog(BuildContext context) {
    List<String> items = [
      "Today",
      "Yesterday",
      "Last 7 Days",
      "Last 30 Days",
      // "All"
    ];
    final storage = controllers.storage.read("selectedSortBy");
    RxString selectedValue = "Today".obs;
    selectedValue.value=storage ?? "Today";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // backgroundColor: Color(0xFFE5E7EB),
          backgroundColor: Color(0xFFF1F5F9),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,height: 30,decoration: customDecoration.baseBackgroundDecoration(
                  color: colorsConst.primary,radius: 5
              ),
                child: Icon(Icons.calendar_today_outlined,color: Colors.white,size: 15,),
              ),10.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: "Default Date Range", isCopy: false,isBold: true,),
                  CustomText(text: "Set the default time filter for dashboard records", isCopy: false),
                ],
              ),10.width,
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 25,height: 25,decoration: customDecoration.baseBackgroundDecoration(
                    color: Colors.transparent,radius: 5,borderColor: Colors.grey.shade500
                ),
                  child: Center(child: Icon(Icons.clear,color: Colors.grey.shade500,size: 15,)),
                ),
              ),
            ],
          ),
          content: Obx(() => SizedBox(
            height: 350,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: items.asMap().entries.map((entry) {
                    int index = entry.key;
                    String value = entry.value;

                    Color iconColor;
                    Color iconBg;
                    IconData icon;

                    if (index == 0) {
                      iconColor = Colors.orange;
                      iconBg = Colors.orange.shade50;
                      icon = Icons.sunny;
                    } else if (index == 1) {
                      iconColor = Colors.purple;
                      iconBg = Colors.purple.shade50;
                      icon = Icons.refresh;
                    } else if (index == 2) {
                      iconColor = Colors.blue;
                      iconBg = Colors.blue.shade50;
                      icon = Icons.calendar_today_outlined;
                    } else if (index == 3) {
                      iconColor = Colors.green;
                      iconBg = Colors.green.shade50;
                      icon = Icons.calendar_today_outlined;
                    } else {
                      iconColor = Colors.pink;
                      iconBg = Colors.pink.shade50;
                      icon = Icons.calendar_today_outlined;
                    }

                    bool isSelected = selectedValue.value == value;

                    return InkWell(
                      onTap: () {
                        selectedValue.value = value;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [

                            /// ICON
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(icon, color: iconColor, size: 18),
                            ),

                            const SizedBox(width: 12),

                            /// TEXTS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text:value,size: 14,isBold: true,isCopy: false,
                                  ),
                                  const SizedBox(height: 2),
                              CustomText(
                                text:
                                    _getDescription(index),
                                    size: 12,
                                      colors: Colors.grey.shade600,isCopy: false,
                                  ),
                                ],
                              ),
                            ),

                            /// CHECK ICON
                              Icon(
                                Icons.check_circle,
                                color: isSelected?Colors.blue:Colors.grey,
                                size: 15,
                              )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          )),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const CustomText(text: "Cancel", isCopy: false,colors: Colors.black,),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorsConst.primary
              ),
              onPressed: () {
                controllers.storage.write("selectedSortBy", selectedValue.value);
                dashController.selectedSortBy.value = selectedValue.value;
                remController.loadSavedFilters();
                Navigator.pop(context, selectedValue.value);
              },
              child: CustomText(text:"Apply",colors: Colors.white,isCopy: false,),
            ),
          ],
        );
      },
    )
        .then((selected) {
      if (selected != null) {
        debugPrint("Selected filter: $selected");
        // Use the selected filter here
      }
    });
  }

  String _getDescription(int index) {
    switch (index) {
      case 0:
        return "Records from the current calendar day only";
      case 1:
        return "Records from the previous calendar day";
      case 2:
        return "Records from the past week including today";
      case 3:
        return "Records from the past month";
      default:
        return "Show all records";
    }
  }

  void expiredDateDialog(String date){
    showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder:(context){
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.white,
              title:  Row(
                children: [
                  Image.asset("assets/images/warning.png",height: 30,width: 30,),
                  Text(
                    "App Expired",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:colorsConst.textColor,
                      fontFamily: "Lato",
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                //height: 300,
                width: 330,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "This app version expired on ",
                      style: TextStyle(
                          fontSize:17,
                          fontWeight: FontWeight.w500,
                          color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                    5.height,
                    Text(
                      date,
                      style: TextStyle(
                        fontSize:17,
                        fontWeight: FontWeight.w500,
                        color:colorsConst.textColor,
                        fontFamily: "Lato",
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void showAddColumnDialog(BuildContext context) {
    TextEditingController columnNameController = TextEditingController();
    var errorText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context,setState){
          return AlertDialog(
            title: CustomText(
              text:'Add Column Name',
              colors: colorsConst.primary,
              isBold: true,
              isCopy: true,
            ),
            content: SizedBox(
              width: 300,
              height: 100,
              child: TextField(
                controller: columnNameController,
                autofocus: true,
                onEditingComplete: (){
                  if(columnNameController.text.isEmpty){
                    setState((){
                      errorText = "Please enter name";
                    });
                    return;
                  }
                  //Navigator.of(context).pop();
                  tableController.addColumnNameAPI(context, columnNameController.text);
                },
                decoration: customStyle.inputDecoration(
                    text: "Enter name here",
                    image: "",
                    isIcon: false,
                    isLogin: false,
                    errorText: errorText,
                    onPressed: (){}),
                onChanged: (value){
                  controllers.firstCaps(value, columnNameController);
                  setState(() {
                    errorText = null;
                  });
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  if(columnNameController.text.isEmpty){
                    setState((){
                      errorText = "Please enter name";
                    });
                    return;
                  }
                  //Navigator.of(context).pop();
                  tableController.addColumnNameAPI(context, columnNameController.text);

                },
              ),
            ],
          );
        });
      },
    );}
}
