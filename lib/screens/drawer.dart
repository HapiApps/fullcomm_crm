import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/controller/controller.dart';

import '../common/constant/default_constant.dart';
import '../components/custom_text.dart';
import 'leads/view_lead.dart';

class SideBarDrawer extends StatefulWidget {
  const SideBarDrawer({super.key});

  @override
  State<SideBarDrawer> createState() => _SideBarDrawerState();
}

class _SideBarDrawerState extends State<SideBarDrawer> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntrinsicWidth(
        child: NavigationRail(
          backgroundColor: colorsConst.primary,
          selectedIndex: controllers.selectedIndex.value,

          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.home,color: colorsConst.primary,),
              label:  Container(
                color: colorsConst.primary,
                height: 130,
                child: Center(
                  child: CustomText(
                    text: constValue.dashboard,
                    colors: Colors.white,
                    size: 20,
                    isBold: true,
                  ),
                ),
              ),
            ),

            NavigationRailDestination(
              icon: Icon(Icons.favorite,color: colorsConst.primary,),
              label:GestureDetector(
                onTap: (){

                 // Get.to(const ViewLead(),duration: Duration.zero);
                },
                child: SizedBox(
                  height: 130,
                  child: Center(
                    child: CustomText(
                      text: constValue.lead,
                      colors: Colors.white,
                      size: 20,
                      isBold: true,
                    ),
                  ),
                ),
              ),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.logout),
              label: Text('Logout'),
            ),
          ],
          extended: controllers.extended,
          onDestinationSelected: (int index) {
            setState(() {
              controllers.selectedIndex.value = index;
            });
          },

        ),
      ),
    );
  }
}
