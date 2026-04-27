import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/screens/leads/update_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/reminder_utils.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/image_controller.dart';
import '../../controller/product_controller.dart';
import '../../models/customer_full_obj.dart';
import '../../models/new_lead_obj.dart';
import '../../models/order_model.dart';
import '../invoice/invoice.dart';

class ViewQuotationDetails extends StatefulWidget {
  final String id;
  final Quotations list;
  const ViewQuotationDetails({
    super.key,
    required this.id,required this.list,
  });

  @override
  State<ViewQuotationDetails> createState() => _ViewQuotationDetailsState();
}

class _ViewQuotationDetailsState extends State<ViewQuotationDetails> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      productCtr.getQuotationFullDetails(widget.id);
    });
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
              child: Obx(
                    () => productCtr.dataRefresh.value==false
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                      itemCount: productCtr.quotationsListDetail.length,
                        itemBuilder: (context,index){
                        var data = productCtr.quotationsListDetail[index];
                          return Column(
                            children: [
                              20.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: screenWidth / 2.5,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.arrow_back,
                                            color: colorsConst.third,
                                          ),
                                        ),
                                        CustomText(
                                          text: "View Quotation Details",
                                          isCopy: true,
                                          colors: colorsConst.textColor,
                                          size: 20,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              10.height,
                              Divider(
                                color: colorsConst.textColor,
                                thickness: 1,
                              ),
                              20.height,
                              rowText("Quotation",widget.list.quotationNo)
                            ],
                          );
                        }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget rowText(String text,String value){
  return Row(
    children: [
      CustomText(text: text, isCopy: true),
      CustomText(text: value, isCopy: true)
    ],
  );
}