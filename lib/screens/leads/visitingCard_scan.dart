import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';

import '../../common/utilities/ocr_web_helper.dart';
import '../../components/custom_sidebar.dart';

class VisitingCardPage extends StatefulWidget {
  @override
  State<VisitingCardPage> createState() => _VisitingCardPageState();
}

class _VisitingCardPageState extends State<VisitingCardPage> {
  Uint8List? imageBytes;

  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final jobController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final locationController = TextEditingController();

  bool isLoading = false;

  /// IMAGE PICK + OCR
  Future<void> pickImageAndScan() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files!.first;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      imageBytes = reader.result as Uint8List;

      // base64 convert
      reader.readAsDataUrl(file);
      await reader.onLoad.first;
      final base64Image = reader.result as String;

      setState(() => isLoading = true);

      try {
        /// OCR call
        final ocrText = await readTextFromImage(base64Image);

        print("OCR RESULT = $ocrText");

        /// parse text → fields
        final card = parseOCRText(ocrText);

        nameController.text = card.name;
        companyController.text = card.company;
        jobController.text = card.jobTitle;
        phoneController.text = card.phone;
        emailController.text = card.email;
        websiteController.text = card.website;
        locationController.text = card.location;
      } catch (e) {
        print("OCR ERROR: $e");
      }

      setState(() => isLoading = false);
    });
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width: screenWidth - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          Get.back();
                        }, icon: Icon(Icons.arrow_back_ios,size: 15,)),
                        CustomText(text: "Visiting Card Scan", isCopy: false,isBold: true,size: 20,),
                      ],
                    ),
                    Divider(color: Colors.grey.shade400,),
                    /// IMAGE PREVIEW
                    if (imageBytes != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 15),
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),

                    /// SCAN BUTTON
                    OutlinedButton(
                      onPressed: pickImageAndScan,
                      child: CustomText(text:"Scan Visiting Card",isCopy: false,isBold: true,size: 15,),
                    ),

                    SizedBox(height: 20),

                    if (isLoading) CircularProgressIndicator(),

                    SizedBox(height: 20),

                    /// FORM FIELDS
                    buildField("Name", nameController),
                    buildField("Company", companyController),
                    buildField("Job Title", jobController),
                    buildField("Phone", phoneController),
                    buildField("Email", emailController),
                    buildField("Website", websiteController),
                    buildField("Location", locationController),

                    SizedBox(height: 20),

                    CustomLoadingButton(callback: (){
                      controllers.insertSingleCustomer(context,"",nameController.text,phoneController.text,
                          emailController.text,"","",
                          "","","","India","",companyController.text,locationController.text,websiteController.text,jobController.text);
                    }, isLoading: true,text: "Save",controller: controllers.btnController,
                        backgroundColor: colorsConst.primary, radius: 5, width: screenWidth/2)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisitingCardData {
  String name = "";
  String company = "";
  String jobTitle = "";
  String phone = "";
  String email = "";
  String website = "";
  String location = "";
}

VisitingCardData parseOCRText(String text) {
  final data = VisitingCardData();

  text = text.replaceAll("\n", " ");

  // EMAIL
  final emailRegex =
  RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
  final emailMatch = emailRegex.firstMatch(text);
  if (emailMatch != null) data.email = emailMatch.group(0)!;

  // PHONE
  final phoneRegex = RegExp(r'\+?\d[\d\s]{8,}');
  final phoneMatch = phoneRegex.firstMatch(text);
  if (phoneMatch != null) data.phone = phoneMatch.group(0)!;

  // WEBSITE
  final webRegex = RegExp(r'(www\.[^\s]+)');
  final webMatch = webRegex.firstMatch(text);
  if (webMatch != null) data.website = webMatch.group(0)!;

  // LOCATION (better detection)
  final addressRegex = RegExp(
    r'\d{2,5}\s+[A-Za-z0-9\s]+,\s*[A-Za-z\s]+',
    caseSensitive: false,
  );

  final addressMatch = addressRegex.firstMatch(text);

  if (addressMatch != null &&
      !addressMatch.group(0)!.contains("@") &&
      !addressMatch.group(0)!.contains("+")) {
    data.location = addressMatch.group(0)!;
  }

  // NAME (first proper name)
  final nameRegex = RegExp(r'[A-Z][a-z]+\s[A-Z][a-z]+');
  final nameMatch = nameRegex.firstMatch(text);
  if (nameMatch != null) data.name = nameMatch.group(0)!;

  // COMPANY
  final companyRegex =
  RegExp(r'[A-Z\s]*(Enterprises|Solutions|Ltd|Pvt)', caseSensitive: false);
  final companyMatch = companyRegex.firstMatch(text);
  if (companyMatch != null) data.company = companyMatch.group(0)!;

  // JOB TITLE
  final jobRegex = RegExp(
      r'(Managing Director|Sales Executive|Manager|Developer|President)',
      caseSensitive: false);
  final jobMatch = jobRegex.firstMatch(text);
  if (jobMatch != null) data.jobTitle = jobMatch.group(0)!;

  return data;
}