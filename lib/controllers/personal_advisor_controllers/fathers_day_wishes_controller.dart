import 'package:probot/bot_api/api_services.dart';

import '../../config.dart';

class FathersDayWishesController extends GetxController {
  TextEditingController fatherController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController wishGeneratedController = TextEditingController();
  bool isWishesGenerate = false;
  bool isLoader = false;
  String? response = '';

  onWishesGenerate() {
    isLoader = true;
    ApiServices.chatCompeletionResponse(
        "Write a Father's day wish message to ${fatherController.text} from ${relationController.text}").then((value) {
          response = value;
          update();
          isLoader = false;
          isWishesGenerate = true;
          update();
    });
    fatherController.clear();
    relationController.clear();
    update();
  }

  endWishGenerator() {
    dialogLayout.endDialog(
        title: appFonts.endFathersDay,
        subTitle: appFonts.areYouSureEndFathersDay,
        onTap: () {
          fatherController.clear();
          relationController.clear();
          isWishesGenerate = false;
          Get.back();
          update();
        });
  }
}