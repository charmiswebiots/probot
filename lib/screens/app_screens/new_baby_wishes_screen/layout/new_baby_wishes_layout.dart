import '../../../../config.dart';

class NewBabyWishesLayout extends StatelessWidget {
  const NewBabyWishesLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewBabyWishesController>(
      builder: (newCtrl) {
        return Column(
          children: [
            Column(children: [
              textCommon.outfitSemiBoldPrimary16(
                  text: appFonts.wonderFullGreetings),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textCommon.outfitSemiBoldTxt14(
                        text: appFonts.selectGender),
                    const VSpace(Sizes.s10),
                    Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: newCtrl.genderLists
                            .asMap()
                            .entries
                            .map((e) => SelectGenderLayout(
                            data: e.value,
                            index: e.key,
                            selectedIndex: newCtrl.selectIndex,
                            onTap: () =>
                                newCtrl.onGenderChange(e.key)))
                            .toList()),
                    const VSpace(Sizes.s20),
                    textCommon.outfitSemiBoldTxt14(
                        text: appFonts.babyNameOnly),
                    const VSpace(Sizes.s10),
                    TextFieldCommon(hintText: appFonts.enterValue),
                    const VSpace(Sizes.s20),
                    textCommon.outfitSemiBoldTxt14(
                        text: appFonts.relationWithBaby),
                    const VSpace(Sizes.s10),
                    TextFieldCommon(hintText: appFonts.enterValue),
                    const VSpace(Sizes.s20),
                    MusicCategoryLayout(
                        title: appFonts.messageGenerateIn,
                        category: newCtrl.langOnSelect ?? "English",
                        onTap: () => newCtrl.onLanguageSheet())
                  ])
                  .paddingSymmetric(
                  vertical: Insets.i20, horizontal: Insets.i15)
                  .authBoxExtension()
            ]),
            const VSpace(Sizes.s30),
            ButtonCommon(
                title: appFonts.goodWishesPlease,
                onTap: () => newCtrl.onWishesGenerate())
          ],
        ).paddingSymmetric(
            horizontal: Insets.i20, vertical: Insets.i30);
      }
    );
  }
}
