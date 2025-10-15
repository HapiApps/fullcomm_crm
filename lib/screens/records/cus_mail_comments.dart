import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/mail_receive_obj.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/custom_comment_container.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';

class CusMailComments extends StatefulWidget {
  final String? id;
  final String? mainName;
  final String? mainMobile;
  final String? mainEmail;
  final String? city;
  final String? companyName;
  const CusMailComments({super.key, this.id, this.mainName, this.mainMobile, this.mainEmail, this.city, this.companyName});

  @override
  State<CusMailComments> createState() => _CusMailCommentsState();
}

class _CusMailCommentsState extends State<CusMailComments> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isWebView = screenWidth > screenHeight;
    screenWidth > screenHeight ? screenWidth * 0.30 : screenWidth * 0.90;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.backgroundColor,
        body:Container(
          width:screenWidth-130,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.height,
               CustomText(text: "New Leads - Suspects",
                colors: colorsConst.textColor,isBold: true,size: 20,),
              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomText(
                    text:widget.mainName.toString(),
                    colors: colorsConst.textColor,isBold: true,),
                  CustomText(text: widget.mainMobile.toString(),
                    colors: colorsConst.textColor,isBold: true,),
                  CustomText(text:widget.mainEmail.toString(),colors: colorsConst.textColor,isBold: true,),
                  CustomText(text: widget.city.toString() ,colors: colorsConst.textColor,isBold: true,),
                  CustomText(text:widget.companyName.toString(),colors: colorsConst.textColor,isBold: true,),
                ],
              ),
              20.height,
              const Divider(
                color: Color(0xffE1E5FA),
                thickness: 1,
                height: 25,
                indent: 16,
                endIndent: 16,
              ),

              Expanded(
                child: Expanded(
                  child: FutureBuilder<List<MailReceiveObj>>(
                    future: controllers.customMailFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            150.height,
                            Center(child: SvgPicture.asset("assets/images/noDataFound.svg")),
                          ],
                        );
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final mailList = snapshot.data!;
                        return MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: mailList.length,
                          itemBuilder: (context, index) {
                            final data = mailList[index];
                            final formattedDate = DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(data.fromData ?? ''));

                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorsConst.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: colorsConst.headColor,
                                          borderRadius: BorderRadius.circular(27),
                                        ),
                                        child: const Icon(Icons.mail, size: 15),
                                      ),
                                      const SizedBox(width: 10),
                                      CustomContainer(
                                        width: 140,
                                        height: 35,
                                        borderRadius: 30,
                                        text: formattedDate,
                                        color: colorsConst.headColor,
                                        size: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: "Command",
                                        colors: colorsConst.headColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: colorsConst.secondary,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: CustomText(
                                            text: data.message ?? '',
                                            colors: colorsConst.textColor,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text("No data found"));
                      }
                    },
                  ),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }
}