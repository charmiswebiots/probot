import 'dart:developer';
import '../../../../config.dart';

class MoreOption extends StatelessWidget {
  const MoreOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatLayoutController>(builder: (chatCtrl) {
      return PopupMenuButton(
          padding: EdgeInsets.zero,
          icon: SvgPicture.asset(
            eSvgAssets.more,
            height: Sizes.s20,
            fit: BoxFit.fill,
          ),
          onSelected: (result) {
            log("res : $result");
            if (result == 0) {
            } else if (result == 1) {
              chatCtrl.showShareDialog();
            } else if (result == 2) {
            } else if (result == 3) {
              Get.toNamed(routeName.backgroundList)!.then((value) {
                chatCtrl.selectedImage = value;
                appCtrl.storage.write("backgroundImage", value);
                chatCtrl.update();
                log("chatCtrl.selectedImage : ${chatCtrl.selectedImage}");
                Get.forceAppUpdate();
              });
            } else {
              chatCtrl.clearChatSuccessDialog();
            }
          },
          iconSize: Sizes.s20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          itemBuilder: (ctx) => [
                chatCtrl.buildPopupMenuItem(
                    appFonts.rebuildResponse.tr, Icons.search, 0),
                chatCtrl.buildPopupMenuItem(
                    appFonts.shareFriend.tr, Icons.upload, 1),
                chatCtrl.buildPopupMenuItem(
                    appFonts.downloadChat.tr, Icons.copy, 2),
                chatCtrl.buildPopupMenuItem(
                    appFonts.changeBackground.tr, Icons.copy, 3),
                chatCtrl.buildPopupMenuItem(
                    appFonts.clearChat.tr, Icons.copy, 4),
              ]);
    });
  }
}
