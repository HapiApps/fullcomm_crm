import 'package:fullcomm_crm/common/widgets/log_in.dart';
import 'package:fullcomm_crm/common/widgets/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/constant/assets_constant.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/default_constant.dart';
import '../controller/controller.dart';
import 'custom_text.dart';

class CustomAppbar extends StatefulWidget {
  const CustomAppbar({super.key, required this.text});
  final String text;

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      controllers.isAdmin.value = prefs.getBool("isAdmin") ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: const ValueKey("App Bar"),
      automaticallyImplyLeading: false,
      backgroundColor: colorsConst.primary,
      leadingWidth: 150,
      elevation: 0.0,
      //centerTitle: true,
      title: const CustomText(
          text: appName, colors: Colors.white, size: 30, isBold: true),
      // leading: const Center(
      //   child:  CustomText(
      //     text:"Zengraf",
      //     colors:Colors.white,size: 25,
      //     isBold:true),
      // ),
      actions: [
        // Center(
        //   child: IconButton(onPressed: (){},
        //       icon:SvgPicture.asset(assets.msg,width:25,height:25,)),
        // ),
        5.width,

        Center(
          child: CustomText(
            text: controllers.storage.read("f_name"),
            colors: Colors.white,
            size: 18,
            isBold: true,
          ),
        ),
        15.width,
        Obx(
          () => controllers.isAdmin.value
              ? Center(
                  child: IconButton(
                      onPressed: () {
                        //Get.to(const SignUp(), duration: Duration.zero);
                      },
                      icon: SvgPicture.asset(
                        assets.add,
                        width: 20,
                        height: 20,
                      )),
                )
              : 0.width,
        ),
        5.width,
        Center(
          child: IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool("loginScreen${controllers.versionNum}", false);
                prefs.setBool("isAdmin", false);
                Get.to(const LoginPage(), duration: Duration.zero);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 25,
              )),
        ),
        5.width,
      ],
    );
  }
}
