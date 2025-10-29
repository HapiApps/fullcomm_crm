import 'package:get/get.dart';

final imageController = Get.put(ImageController());

class ImageController extends GetxController {
  var loanDocument = "".obs;

  var photo1 = "".obs, resume = "".obs, idCard = "".obs;
  var empFileName = "".obs, resumeFileName = "".obs, idCardFileName = "".obs;
  var empMediaData = <int>[].obs,
      resumeMediaData = <int>[].obs,
      idCardMediaData = <int>[].obs;
  var imagePath1 = "";
  var imagePath2 = "";

  var photo2 = "".obs;
  var imageLength = 1;
  RxList images = [].obs;
  var img1 = "".obs;
  var img2 = "".obs;
  var img3 = "".obs;

  var image = "".obs;
}
