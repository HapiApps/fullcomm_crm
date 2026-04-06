import '../../controller/controller.dart';

class ProjectData {

  static const String title   = 'MARTWAY';
//PROD
//   static const String version = '0.0.17';
//   static const String cashId = '314';

  //DEV

  static const String cashId = "577";
  static const String cash = "1001";
  static const String name = "Cash Customer";
  // static const String mobile = "9966111100";
  static const String mobile = "-";
  static const String address = "chennai";


  static const String billTitle = 'MARTWAY';

  // DEV Mode :
  // static const String domain = "https://martwaydevs.celwiz.com/DEV";
  // static const String billAddress  = '221/257,KVB Garden,Raja Annamalai Puram,\nChennai-600028';
  // static const String billFooter = 'For Order WhatsApp : #12345 67890\nThanks for Shopping!\nVisit Us Again.';

  // PRODUCTION Mode
  static const String domain = "https://martwayd.celwiz.com/PRO";
  static const String billAddress = 'No.191/209,KVB Garden,Raja AnnamalaiPuram, Ch-28';
  static const String billAddress1 = 'Chennai-600028';
  static final String billMobile = '8637623735/ 044-48555255/ 9344443752/ Cashier:${controllers.storage.read("id")}';
  static const String billFooter  = 'For Order WhatsApp : 86376 23735';
  static const String billFooter_42  = 'WhatsApp Order : 86376 23735';
  static const String billFooter1  = 'Thanks for Shopping! Visit Us Again.';

}