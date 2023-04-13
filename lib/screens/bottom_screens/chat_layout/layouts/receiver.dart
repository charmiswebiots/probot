import 'dart:developer';

import '../../../../config.dart';

class Receiver extends StatelessWidget {
  final dynamic chatListModel;
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
                    .userImage(chatListModel["avatar"]),
                const HSpace(Sizes.s6),
                chatListModel["messageType"] == ChatMessageType.loading.name
                    ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.i10,
                    ),
                    decoration: BoxDecoration(
                        color: appCtrl.appTheme.boxBg,
                        boxShadow:   appCtrl.isTheme ? null : [
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
                          chatListModel["message"].length > 40
                              ? ReceiverWidthText(
                            text: chatListModel["message"],row: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ChatCommonWidget().timeTextLayout(
                                  chatListModel["createdDate"].toString()),
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
                                        chatListModel["message"],
                                        '${appCtrl.languageVal}-$code');
                                  })
                            ],
                          ),)
                              : ReceiverContent(
                            text: chatListModel["message"],row: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ChatCommonWidget().timeTextLayout(
                                  chatListModel["createdDate"].toString()),
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
                                        chatListModel["message"],
                                        '${appCtrl.languageVal}-$code');
                                  })
                            ],
                          ),),
                          const HSpace(Sizes.s5),

                        ],
                      ),
                      const VSpace(Sizes.s3),

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
