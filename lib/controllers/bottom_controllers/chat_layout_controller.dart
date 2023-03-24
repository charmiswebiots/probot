import 'dart:developer';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:probot/bot_api/api_services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../config.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatLayoutController extends GetxController {
  dynamic data;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int index = 0;
  bool isLongPress = false;
  List backgroundList = [];
  Rx<List<ChatListDateWise>> chatList = Rx<List<ChatListDateWise>>([]);
  final chatController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String? time;
  List selectedIndex = [];
  List selectedData = [];
  DateTime? receiverTime;

  FocusNode focusNode = FocusNode();
  int count = 0;
  int receiverCount = 0;
  int lastIndex = 0;
  int receiverLastIndex = 0;
  String? selectedImage;
  late SpeechToText speech;
  Rx<List<ChatMessage>> messages = Rx<List<ChatMessage>>([]);
  Rx<bool> isLoading = Rx<bool>(false);
  final FlutterTts? flutterTts = FlutterTts();
  final _isSpeech = false.obs;
  final isListening = false.obs;
  List<String> shareMessages = ['--THIS IS CONVERSATION with PROBOT--\n\n'];
  List<String> selectedMessages = [];
  RxInt itemCount = 0.obs;
  RxString textInput = ''.obs;
  final _isSpeechLoading = false.obs;

  RxInt chatCount = 0.obs;
  RxString userInput = "".obs;
  RxString result = "".obs;
  static const interstitialButtonText = 'InterstitialAd';
  static const rewardedButtonText = 'RewardedAd';
  static const rewardedInterstitialButtonText = 'RewardedInterstitialAd';
  static const fluidButtonText = 'Fluid';
  static const inlineAdaptiveButtonText = 'Inline adaptive';
  static const anchoredAdaptiveButtonText = 'Anchored adaptive';
  static const nativeTemplateButtonText = 'Native template';

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  @override
  void onReady() {
    // TODO: implement onReady
    data = appCtrl.storage.read(session.selectedCharacter);
    backgroundList = appArray.backgroundList;
    selectedImage =
        appCtrl.storage.read("backgroundImage") ?? eImageAssets.background1;
    speech = SpeechToText();
    update();
    log("chatList : $data");
    if(appCtrl.firebaseConfigModel!.isAddShow! && appCtrl.envConfig["chatTextCount"] != "unlimited") {
      _createInterstitialAd();
    }

    super.onReady();
  }

  //clear data while go back
  clearData() {
    speechStopMethod();
    isLongPress = false;
    selectedData = [];
    selectedIndex = [];
    messages = Rx<List<ChatMessage>>([]);
    shareMessages = [];
    itemCount = 0.obs;
    update();
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }



  //initialize interstitial add
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? appCtrl.firebaseConfigModel!.interstitialAdIdAndroid!
            : appCtrl.firebaseConfigModel!.interstitialAdIdIOS!,
        request: appCtrl.request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            log('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            update();
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 3) {
              _createInterstitialAd();
            }
          },
        ));
    update();
    appCtrl.createRewardedAd();
  }

  //show interstitial add
  void showInterstitialAd() {
    if (_interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
    update();
  }

  //speech method
  speechMethod(String text, String language) async {
    _isSpeechLoading.value = true;
    _isSpeech.value = true;
    update();

    await flutterTts!.setLanguage(language);
    await flutterTts!.setPitch(1);
    await flutterTts!.setSpeechRate(0.45);
    await flutterTts!.speak(text);

    Future.delayed(
        const Duration(seconds: 2), () => _isSpeechLoading.value = false);
    update();
  }

  //stop speech method
  speechStopMethod() async {
    _isSpeech.value = false;
    await flutterTts!.stop();
    update();
  }

  //scroll direction
  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  //add text count
  addTextCount() async {
    debugPrint("-------${chatCount.value.toString()}--------");
    chatCount.value++;
    // LocalStorage.saveTextCount(count: chatCount.value);
  }

  //process for chat
  processChat() async {
    if(appCtrl.envConfig["chatTextCount"] != "unlimited") {
      int chatCount = int.parse(appCtrl.envConfig["chatTextCount"].toString());

      chatCount = chatCount - 1;
      log("chatCount : $chatCount");
      appCtrl.envConfig["chatTextCount"] = chatCount.toString();
      appCtrl.storage.write(session.envConfig, appCtrl.envConfig);
      appCtrl.envConfig = appCtrl.storage.read(session.envConfig);
    }
    appCtrl.update();
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    speechStopMethod();
    addTextCount();
    log("CONFIG L:${appCtrl.envConfig}");
    messages.value.add(
      ChatMessage(
          text: chatController.text,
          chatMessageType: ChatMessageType.user,
          time: DateTime.now().millisecondsSinceEpoch),
    );
    shareMessages.add("${chatController.text} - Myself\n");
    selectedMessages.add("${chatController.text} - Myself\n");
    itemCount.value = messages.value.length;
    update();
    Get.forceAppUpdate();
    if(appCtrl.envConfig["chatTextCount"] != "unlimited") {
      final subscribeCtrl = Get.isRegistered<SubscriptionFirebaseController>()
          ? Get.find<SubscriptionFirebaseController>()
          : Get.put(SubscriptionFirebaseController());
      await subscribeCtrl.addUpdateFirebaseData();
    }
    int i = messages.value.indexWhere(
        (element) => element.chatMessageType == ChatMessageType.loading);

    if (i < 0) {
      Future.delayed(const Duration(milliseconds: 5));
      log("i : $i");
      messages.value.add(
        ChatMessage(
            text: "",
            chatMessageType: ChatMessageType.loading,
            time: DateTime.now().millisecondsSinceEpoch),
      );
      itemCount.value = messages.value.length;
      update();
    }
    textInput.value = chatController.text;

    update();

    scrollDown();
    update();
    ApiServices.chatCompeletionResponse(chatController.text).then((value) {
      // isLoading.value = false
      messages.value.removeWhere(
          (element) => element.chatMessageType == ChatMessageType.loading);

      messages.value.add(
        ChatMessage(
            text: value.replaceFirst("\n", " ").replaceFirst("\n", " "),
            chatMessageType: ChatMessageType.bot,
            time: DateTime.now().millisecondsSinceEpoch),
      );
      itemCount.value = messages.value.length;
      update();
      shareMessages.add(
          "${value.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By PROBOT\n");
      selectedMessages.add(
          "${value.replaceFirst("\n", " ").replaceFirst("\n", " ")} -By PROBOT\n");

      scrollDown();
      isLoading.value = false;
      update();
    });
    chatController.clear();
    Get.forceAppUpdate();
    update();
  }

  //pop up menu item
  PopupMenuItem buildPopupMenuItem(
      String title, IconData iconData, int position) {
    return PopupMenuItem(
        value: position,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppCss.outfitMedium14.textColor(appCtrl.appTheme.txt)),
          const VSpace(Sizes.s15),
          if (position != 4)
            Divider(height: 0, color: appCtrl.appTheme.greyLight, thickness: 1)
        ]));
  }

  //show share dialog
  showShareDialog() {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return const Align(
          alignment: Alignment.center,
          child: ShareLayout(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  //clear chat success
  clearChatSuccessDialog() {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return const Align(
          alignment: Alignment.center,
          child: ClearChatSuccess(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  //speech to text
  void speechToText() async {
    speechStopMethod();
    chatController.text = '';
    result.value = '';
    userInput.value = '';
    log("ISLISTEN : ${isListening.value}");
    if (isListening.value == false) {
      bool available = await speech.initialize(
        onStatus: (val) {
          debugPrint('*** onStatus: $val');
          isListening.value = false;
          speech.stop();
          update();
        },
        onError: (val) {
          debugPrint('### onError: $val');
          isListening.value = false;
          speech.stop();
          update();
        },
      );
      if (available) {
        isListening.value = true;
        speech.listen(
            localeId: appCtrl.languageVal,
            onResult: (val) {
              chatController.text = val.recognizedWords.toString();
              userInput.value = val.recognizedWords.toString();
              log("speech.isNotListening : ${speech.isNotListening}");
            },
            listenFor: const Duration(seconds: 15));
        update();
      }
    } else {
      isListening.value = false;
      speechStopMethod();
      update();
    }
  }
}
