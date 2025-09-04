import 'package:fullcomm_crm/components/custom_company_tile.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:fullcomm_crm/screens/company/add_company.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/common/constant/assets_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_lead_tile.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/models/lead_obj.dart';
import 'package:fullcomm_crm/screens/leads/add_lead.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../components/custom_appbar.dart';

class ViewCompany extends StatefulWidget {
  const ViewCompany({super.key});

  @override
  State<ViewCompany> createState() => _ViewCompanyState();
}

class _ViewCompanyState extends State<ViewCompany> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = screenSize.width - 380.0;
    final double partWidth = minPartWidth / 9;
    final double adjustedPartWidth = partWidth;
    return SelectionArea(
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CustomAppbar(
              text: appName,
            ),
          ),
          // body: SfDataGrid(
          //   source: employeeDataSource,
          //   columnWidthMode: ColumnWidthMode.fill,
          //   headerGridLinesVisibility: GridLinesVisibility.none,
          //   gridLinesVisibility: GridLinesVisibility.none,
          //   footerHeight: 75,
          //   footer:10.height,
          //   columns: <GridColumn>[
          //     GridColumn(
          //       visible: false,
          //       //autoFitPadding: const EdgeInsets.fromLTRB(10, 01, 20, 100),
          //       columnWidthMode:ColumnWidthMode.fitByCellValue,
          //         columnName: 'isCheck',
          //         label:CustomText(
          //           text: "",
          //           textAlign: TextAlign.end,
          //           colors: colorsConst.primary,
          //           size: 20,
          //         ),
          //     ),
          //     GridColumn(
          //         columnName: 'name',
          //         label:CustomText(
          //           textAlign: TextAlign.end,
          //           text: "Name",
          //           colors: colorsConst.primary,
          //           size: 20,
          //         )
          //     ),
          //     GridColumn(
          //         columnName: 'mobileNumber',
          //         label: CustomText(
          //           textAlign: TextAlign.end,
          //           text: "Mobile no",
          //           colors: colorsConst.primary,
          //           size: 20,
          //         )
          //     ),
          //     GridColumn(
          //         columnName: 'email',
          //         label:CustomText(
          //           textAlign: TextAlign.end,
          //           text: "Email",
          //           colors: colorsConst.primary,
          //           size: 20,
          //         )
          //     ),
          //     GridColumn(
          //         columnName: 'companyName',
          //         label:CustomText(
          //           textAlign: TextAlign.end,
          //           text: "Company Name",
          //           colors: colorsConst.primary,
          //           size:20,
          //         )
          //     ),
          //     GridColumn(
          //         columnName: 'status',
          //         label:CustomText(
          //           textAlign: TextAlign.end,
          //           text: "Status",
          //           colors: colorsConst.primary,
          //           size: 20,
          //         )
          //     ),
          //     GridColumn(
          //         columnName: 'rating',
          //         label:CustomText(
          //           textAlign: TextAlign.end,
          //           text: "Rating",
          //           colors: colorsConst.primary,
          //           size: 20,
          //         )
          //     ),
          //   ],
          // ),
          body: Stack(
            children: [
              utils.sideBarFunction(context),
              Positioned(
                left: 130,
                child: Container(
                  width: 1349 > MediaQuery.of(context).size.width - 130
                      ? 1349
                      : MediaQuery.of(context).size.width - 130,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    // keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,
                    // controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1230 > MediaQuery.of(context).size.width - 250
                          ? 1230
                          : MediaQuery.of(context).size.width - 250,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          30.height,
                          Obx(
                            () => CustomText(
                              text:
                                  "Companies(${controllers.allCompanyLength.value})",
                              colors: colorsConst.primary,
                              size: 23,
                              isBold: true,
                            ),
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      assets.delete,
                                      width: 25,
                                      height: 25,
                                    ),
                                    10.width,
                                    SvgPicture.asset(
                                      assets.edit,
                                      width: 18,
                                      height: 18,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // void sendEmail(
                                        //     {required String email,
                                        //       required String subject,
                                        //       required String name,
                                        //       required String body}) async {
                                        //   String encodedSubject = Uri.encodeComponent(subject);
                                        //   String encodedBody = Uri.encodeComponent(body);
                                        //   String mailtoLink =
                                        //       'mailto:$email?subject=$encodedSubject&body=$encodedBody&headers=header1:$name';
                                        //
                                        //   if (await canLaunchUrl(Uri.parse(mailtoLink))) {
                                        //     await launchUrl(Uri.parse(mailtoLink));
                                        //   } else {
                                        //     throw 'Could not launch $mailtoLink';
                                        //   }
                                        // }
                                        //
                                        // utils.sendEmailA();
                                        // utils.sendEmail(
                                        //   name: "Manju",
                                        //   email: "manjusudalaimani@gmail.com",
                                        //   subject: 'Demo email',
                                        //   message: 'This email code just text'
                                        // );
                                        //utils.sendEmail(email: "ponrohinirohini@gmail.com", subject: "Test email", name: "Manju");
                                        //controllers.isLead.value=false;
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                const AddCompany(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                        //Get.to(const AddLead());
                                      },
                                      child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          onHover: (PointerEvent details) {
                                            controllers.isCoAdd.value = true;
                                          },
                                          onExit: (PointerEvent details) {
                                            controllers.isCoAdd.value = false;
                                          },
                                          child: Obx(
                                            () => CustomText(
                                              text: "Add Company",
                                              decoration:
                                                  controllers.isCoAdd.value
                                                      ? TextDecoration.underline
                                                      : TextDecoration.none,
                                              colors: colorsConst.primary,
                                              size: 20,
                                            ),
                                          )),
                                    ),
                                    5.width,
                                    CustomText(
                                      text: "|",
                                      colors: colorsConst.secondary,
                                      size: 20,
                                    ),
                                    5.width,
                                    CustomText(
                                      text: "Import",
                                      colors: colorsConst.primary,
                                      size: 20,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(assets.manageColumn),
                              20.width,
                              SizedBox(
                                width: 1230 >
                                        MediaQuery.of(context).size.width - 250
                                    ? 1100
                                    : MediaQuery.of(context).size.width - 300,
                                height: 50,
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {
                                      controllers.searchText.value = value.trim();
                                  },
                                  decoration: InputDecoration(
                                    hoverColor: Colors.white,
                                    hintText: "Search",
                                    hintStyle: TextStyle(
                                      color: colorsConst.secondary,
                                      fontSize: 15,
                                      fontFamily: "Lato",
                                    ),
                                    //prefixIcon: SvgPicture.asset(assets.search,width: 1,height: 1,),
                                    prefixIcon: IconButton(
                                        onPressed: () {},
                                        icon: SvgPicture.asset(assets.search,
                                            width: 15, height: 15)),
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 1230 >
                                        MediaQuery.of(context).size.width - 250
                                    ? 1000
                                    : MediaQuery.of(context).size.width - 380,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Name",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Mobile no.",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: CustomText(
                                        textAlign: TextAlign.start,
                                        text: "Email",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: CustomText(
                                        textAlign: TextAlign.center,
                                        text: "City",
                                        size: 15,
                                        colors: colorsConst.primary,
                                        isBold: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: Center(
                                        child: CustomText(
                                          textAlign: TextAlign.start,
                                          text: "Industry",
                                          size: 15,
                                          colors: colorsConst.primary,
                                          isBold: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: adjustedPartWidth,
                                      child: Center(
                                        child: CustomText(
                                          textAlign: TextAlign.start,
                                          text: "Product",
                                          size: 15,
                                          colors: colorsConst.primary,
                                          isBold: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder<List<CompanyObj>>(
                              future: controllers.allCompanyFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        if (snapshot.data![index].coName
                                            .toString()
                                            .toLowerCase()
                                            .contains(controllers.searchText
                                                .toLowerCase())) {
                                          return CustomCompanyTile(
                                            name: snapshot.data![index].coName
                                                .toString(),
                                            mobileNumber: snapshot
                                                .data![index].phoneMap
                                                .toString(),
                                            emailId: snapshot
                                                .data![index].emailMap
                                                .toString(),
                                            product: snapshot
                                                .data![index].product
                                                .toString(),
                                            city: snapshot.data![index].city
                                                .toString(),
                                            industry: snapshot
                                                .data![index].coIndustry
                                                .toString(),
                                          );
                                        }
                                        return const SizedBox();
                                      });
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Text("No Company"));
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                          20.height,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
