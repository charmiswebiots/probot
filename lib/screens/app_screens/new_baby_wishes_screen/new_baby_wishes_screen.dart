import '../../../config.dart';

class NewBabyWishesScreen extends StatelessWidget {
  final newCtrl = Get.put(NewBabyWishesController());

  NewBabyWishesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewBabyWishesController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.bg1,
          resizeToAvoidBottomInset: false,
          appBar: AppAppBarCommon(
              title: appFonts.newBabyWishes, leadingOnTap: () => Get.back()),
          body: SingleChildScrollView(
              child: newCtrl.isWishGenerate == true
                  ? Column(children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textCommon.outfitSemiBoldPrimary16(
                                text: appFonts.lovelyGreetings),
                            const VSpace(Sizes.s15),
                            InputLayout(
                                hintText: "",
                                title: appFonts.goodWishes,
                                color: appCtrl.appTheme.white,
                                isMax: false,
                                controller: newCtrl.wishGenController)
                          ]),
                      const VSpace(Sizes.s20),
                      ButtonCommon(
                          title: appFonts.endBornBabyWish,
                          onTap: () => newCtrl.endBabyWishesSuggestion())
                    ]).paddingSymmetric(
                      horizontal: Insets.i20, vertical: Insets.i30)
                  : const NewBabyWishesLayout()));
    });
  }
}
