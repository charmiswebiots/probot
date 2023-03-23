import 'dart:developer';

import '../../../../config.dart';

class Receiver extends StatelessWidget {
  final ChatMessage? chatListModel;
  final int? index;

  const Receiver({
    Key? key,
    this.chatListModel,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatLayoutController>(builder: (chatCtrl) {
      return Align(
              alignment: Alignment.centerLeft,
              child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    ChatCommonWidget()
                        .userImage(appCtrl.selectedCharacter["image"]),
                    const HSpace(Sizes.s6),
                    chatListModel!.chatMessageType == ChatMessageType.loading
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Insets.i10,
                            ),
                            decoration: BoxDecoration(
                                color: appCtrl.appTheme.boxBg,
                                boxShadow: [
                                  BoxShadow(
                                      color: appCtrl.appTheme.primaryShadow,
                                      offset: const Offset(0, 10),
                                      blurRadius: 20)
                                ],
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r6)),
                            child: Image.asset(
                              eGifAssets.loading,
                              height: Sizes.s40,
                            ))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    chatListModel!.text!.length > 40
                                        ? ReceiverWidthText(
                                            text: chatListModel!.text!)
                                        : ReceiverContent(
                                            text: chatListModel!.text!),
                                    const HSpace(Sizes.s5),
                                    SvgPicture.asset(eSvgAssets.volume).inkWell(
                                        onTap: () {
                                      String code = appCtrl.languageVal == "en"
                                          ? "US"
                                          : appCtrl.languageVal == "fr"
                                              ? "CA"
                                              : appCtrl.languageVal == "ge"
                                                  ? "GE"
                                                  : appCtrl.languageVal == "hi"
                                                      ? "IN"
                                                      : appCtrl.languageVal ==
                                                              "it"
                                                          ? "IT"
                                                          : appCtrl.languageVal ==
                                                                  "ja"
                                                              ? "JP"
                                                              : "US";
                                      chatCtrl.speechMethod(
                                          chatListModel!.text!,
                                          '${appCtrl.languageVal}-$code');
                                    })
                                  ],
                                ),
                                const VSpace(Sizes.s3),
                                ChatCommonWidget().timeTextLayout(
                                    chatListModel!.time!.toString())
                              ]).inkWell(onTap: () {
                            if (chatCtrl.isLongPress) {
                              if (!chatCtrl.selectedIndex.contains(index)) {
                                chatCtrl.selectedIndex.add(index);
                                chatCtrl.selectedData
                                    .add(chatCtrl.selectedMessages[index!]);
                                chatCtrl.update();
                              }else{
                                if (chatCtrl.selectedIndex.contains(index)) {
                                  chatCtrl.selectedIndex.remove(index);
                                  chatCtrl.selectedData.remove(chatCtrl.selectedMessages[index!]);
                                  chatCtrl.update();
                                }
                              }
                            }
                          }),
                  ])
                  .marginSymmetric(horizontal: Insets.i20, vertical: Insets.i5))
          .decorated(
              color: chatCtrl.selectedIndex.contains(index)
                  ? appCtrl.appTheme.primaryLight
                  : appCtrl.appTheme.bg1)
          .onLongPressTap(onLongPress: () {
        log("chatCtrl.shareMessages[index!] : ${chatCtrl.selectedMessages[index!]}");
        chatCtrl.isLongPress = true;
        if (!chatCtrl.selectedIndex.contains(index)) {
          chatCtrl.selectedIndex.add(index);
          chatCtrl.selectedData.add(chatCtrl.selectedMessages[index!]);
          chatCtrl.update();
        }
      });
    });
  }
}