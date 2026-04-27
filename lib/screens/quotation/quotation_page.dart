import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/screens/quotation/quotation_history.dart';
import 'package:get/get.dart';
import '../../billing/billing_view/new_billing_screen.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  Container(
                    height: 70,
                    color: Color(0xffE2E8F0),
                    child: TabBar(
                      controller: productCtr.productTab,
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,

                      labelColor: colorsConst.primary,
                      unselectedLabelColor: Colors.grey,

                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 18,
                      ),

                      tabs: [
                        Tab(
                          child: const Text('Quotation History'),
                        ),
                        Tab(
                          child: const Text('Create Quotation'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: productCtr.productTab,
                      children: [
                        // SendQuotation(),
                        QuotationHistory(),
                        NewBillingScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
}
