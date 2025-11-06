import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/utilities/utils.dart';
import '../components/custom_sidebar.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../services/api_services.dart';

class Quotations extends StatefulWidget {
  final String? id;
  final String? mainName;
  final String? mainMobile;
  final String? mainEmail;
  final String? city;
  final String? companyName;
  const Quotations({
    super.key,
    this.id,
    this.mainName,
    this.mainMobile,
    this.mainEmail,
    this.city,
    this.companyName,
  });

  @override
  State<Quotations> createState() => _QuotationsState();
}

class _QuotationsState extends State<Quotations> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllers.mailReceivesList.value = [];
    apiService.mailReceiveDetails(widget.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
                width: MediaQuery.of(context).size.width - 490,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      20.height,
                      Row(
                        children: [
                          CustomText(
                            text: "Quotations",
                            colors: colorsConst.textColor,
                            size: 20,
                            isBold: true,
                          ),
                        ],
                      ),
                      40.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: widget.mainName.toString(),
                            colors: colorsConst.textColor,
                            size: 15,
                          ),
                          CustomText(
                            text: widget.mainMobile.toString(),
                            colors: colorsConst.textColor,
                            size: 15,
                          ),
                          CustomText(
                            text: widget.mainEmail.toString(),
                            colors: colorsConst.textColor,
                            size: 15,
                          ),
                          CustomText(
                            text: widget.city.toString(),
                            colors: colorsConst.textColor,
                            size: 15,
                          ),
                          CustomText(
                            text: widget.companyName.toString(),
                            colors: colorsConst.textColor,
                            size: 15,
                          ),
                        ],
                      ),
                      10.height,
                      Divider(
                        color: colorsConst.textColor,
                        thickness: 0.5,
                      ),
                      20.height,
                      SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: Obx(
                            () => ListView.builder(
                                itemCount: controllers.mailReceivesList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                const Color(0xffAFC8D9),
                                            radius: 15,
                                            child: Icon(
                                              Icons.email,
                                              color: colorsConst.primary,
                                              size: 15,
                                            ),
                                          ),
                                          8.width,
                                          Container(
                                            width: 150,
                                            height: 30,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: const Color(0xffAFC8D9),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: CustomText(
                                              //textAlign: TextAlign.start,
                                              text: controllers
                                                      .mailReceivesList[index]
                                                  ['sent_date'],
                                              colors: colorsConst.primary,
                                              size: 13,
                                              isBold: true,
                                            ),
                                          )
                                        ],
                                      ),
                                      30.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: "Comment",
                                            colors: colorsConst.headColor,
                                            size: 15,
                                          ),
                                          60.width,
                                          Container(
                                            decoration: BoxDecoration(
                                                color: colorsConst.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            alignment: Alignment.center,
                                            width: 520,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: CustomText(
                                                text: controllers
                                                    .mailReceivesList[index]
                                                        ['message']
                                                    .toString()
                                                    .trim(),
                                                size: 15,
                                                textAlign: TextAlign.start,
                                                colors: colorsConst.textColor,
                                                isBold: false,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      30.height,
                                    ],
                                  );
                                }),
                          )),
                    ],
                  ),
                )),
            utils.funnelContainer(context)
          ],
        ),
      ),
    );
  }
}
