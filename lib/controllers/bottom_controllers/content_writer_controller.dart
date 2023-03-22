import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:probot/models/content_model.dart';

import '../../bot_api/api_services.dart';
import '../../config.dart';

class ContentWriterController extends GetxController {
  String? selectedValue = "businessIdea";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List contentOptionList = [];
  ScrollController scrollController =
      ScrollController(initialScrollOffset: 50.0);
  Rx<List<ContentMessage>> messages = Rx<List<ContentMessage>>([]);
  final contentController = TextEditingController();
  RxString contentInput = ''.obs;
  RxInt itemCount = 0.obs;
  List<String> shareMessages = ['--THIS IS CONVERSATION with PROBOT--\n\n'];
  RxInt contentCount = 0.obs;
  final FlutterTts? flutterTts = FlutterTts();
  final contentScrollController = ScrollController();
  Rx<bool> isLoading = Rx<bool>(false);
  final isSpeechLoading = false.obs;
  final isSpeech = false.obs;

  dynamic htmlData;

  @override
  void onReady() {
    // TODO: implement onReady
    contentOptionList = appArray.contentOptionList;
    update();

    super.onReady();
  }

  //on option tap function
  onOptionTap(index) {
    final dashboardCtrl = Get.find<DashboardController>();
    if (index == 0) {
      dashboardCtrl.onBottomTap(1);
    } else if (index == 1) {
      dashboardCtrl.onBottomTap(2);
    } else {
      dashboardCtrl.onBottomTap(3);
    }
    dashboardCtrl.update();
  }

  speechStopMethod() async {
    isSpeech.value = false;
    await flutterTts!.stop();
    update();
  }

  void scrollDown() {
    contentScrollController.animateTo(
      contentScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  addTextCount() async {
    contentCount.value++;
    // LocalStorage.saveTextCount(count: count.value);
  }

  void proccessContentWrite() async {
    speechStopMethod();
    addTextCount();
    isLoading.value = true;
    update();
    messages.value.add(
      ContentMessage(
        text: contentController.text,
        textMessageType: ContentMessageType.user,
      ),
    );

    var input = contentController.text;
    contentInput.value = contentController.text;
    contentController.clear();
    update();
    log(":ISLOADING : #${isLoading.value}");

    ApiServices.chatCompeletionResponse(input).then((value) {
      log("value : $value");
      htmlData = value;
      update();

      isLoading.value = false;
      update();
    });
    contentController.clear();
    update();
  }
}
