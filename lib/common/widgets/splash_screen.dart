//
// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:anpace/common/constant/assets_constant.dart';
// import 'package:anpace/common/extentions/int_extensions.dart';
// import 'package:anpace/components/custom_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:page_transition/page_transition.dart';
//
// class GudMrgPage extends StatelessWidget {
//   const GudMrgPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return  AnimatedSplashScreen(
//         duration: 300,
//         splashIconSize: 800,
//         splashTransition: SplashTransition.fadeTransition,
//         splash:Container(
//           color: Colors.white,
//           width: double.infinity,
//           height: double.infinity,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                   child: Container(
//                     height: 300,
//                     width: 300,
//                     child: SvgPicture.asset(assets.gudMrng),
//                   ),
//                 ),
//                 20.height,
//                 //CustomText(text: "${customFunction.greeting()} ${testController.storage.read("f_name")}",colors: Colors.black,isBold: true,size: 22,),
//                 20.height,
//                 //CustomText(text: constValue.planDay,colors: colorsConst.primary,isBold: true,size: 18,)
//                 // customWidget.boldtext("Login Success!", colorsConst.primary, 20)
//               ],
//             ),
//           ),
//         ),
//         // nextScreen:widget.signupscreen&&widget.loginscreen?animatedDrawer():widget.signupscreen?loginpage():intro(),
//         pageTransitionType: PageTransitionType.fade,
//         nextScreen:  HomeDrawer()
//     );
//   }
// }
//
//
//
//
//
//
//
