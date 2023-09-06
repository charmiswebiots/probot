import '../../../../config.dart';

class PlanListCommon extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapShot;

  const PlanListCommon({Key? key, required this.snapShot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscribeCtrl) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ...snapShot.data!.docs.asMap().entries.map((e) {
            return Stack(alignment: Alignment.topRight, children: [
              ClipSmoothRect(
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: Insets.i8, horizontal: Insets.i5),
                      decoration: BoxDecoration(
                          color: subscribeCtrl.selectedPlan == e.key
                              ? appCtrl.appTheme.primary
                              : appCtrl.appTheme.primaryLight,
                          border: Border.all(
                              color: subscribeCtrl.selectedPlan == e.key
                                  ? appCtrl.appTheme.primary
                                  : appCtrl.appTheme.primaryLight1),
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1)),
                      child: Column(children: [
                        ClipSmoothRect(
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Insets.i25,
                                    vertical: Insets.i15),
                                child: Column(children: [
                                  textCommon.outfitMediumPrimary14(
                                      text: e.value.data()["planType"]),
                                  const VSpace(Sizes.s10),
                                  Text(
                                      appCtrl.priceSymbol +
                                          (appCtrl.currencyVal *
                                                  e.value.data()["price"])
                                              .toStringAsFixed(2)
                                              .toString(),
                                      style: AppCss.outfitBold18.textColor(
                                          appCtrl.appTheme.sameBlack)),
                                  const VSpace(Sizes.s5),
                                  textCommon.regularLightText12(
                                      text: "/${e.value.data()["type"]}")
                                ])).planExtension(e.key ==
                                    subscribeCtrl.selectedPlan
                                ? appCtrl.appTheme.primaryLight2
                                : appCtrl.appTheme.sameWhite)),
                        Text(
                                e.value
                                    .data()["title"]
                                    .toString()
                                    .replaceAll("-", "\n"),
                                textAlign: TextAlign.center,
                                style: AppCss.outfitMedium12
                                    .textColor(
                                        e.key == subscribeCtrl.selectedPlan
                                            ? appCtrl.appTheme.sameWhite
                                            : appCtrl.appTheme.primary)
                                    .textHeight(1.2))
                            .paddingSymmetric(vertical: Insets.i8)
                      ]))),
              if (e.key == subscribeCtrl.selectedPlan)
                SvgPicture.asset(eSvgAssets.singleTick)
                    .paddingAll(Insets.i8)
                    .decorated(
                        color: appCtrl.appTheme.primary, shape: BoxShape.circle)
            ]).marginSymmetric(horizontal: Insets.i5).inkWell(
                onTap: () => subscribeCtrl.onSelectPlan(e.key, e.value));
          }).toList()
        ]).marginSymmetric(horizontal: Insets.i10),
      );
    });
  }
}
