import '../../../config.dart';

class Subscription extends StatelessWidget {
  final subscribeCtrl = Get.put(SubscriptionController());

  Subscription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (_) {
      return DirectionalityRtl(
          child: WillPopScope(
              onWillPop: () async {
                subscribeCtrl.isBack ? Get.back() : appCtrl.splashDataCheck();
                return true;
              },
              child: Scaffold(
                  backgroundColor: appCtrl.appTheme.bg1,
                  appBar: AppAppBarCommon(
                      title: appFonts.selectPlan,
                      actionIcon: eSvgAssets.currency,
                      isAction: true,
                      isBalanceShow: false,
                      leadingOnTap: () => subscribeCtrl.isBack
                          ? Get.back()
                          : appCtrl.splashDataCheck(),
                      actionOnTap: () => subscribeCtrl.currencyListDialog()),
                  body: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Stack(children: [
                          Image.asset(eImageAssets.subscriptionTopBg),
                          IntrinsicHeight(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                Text(appFonts.lifeTimeAccessibility.tr,
                                    style: AppCss.outfitMedium18
                                        .textColor(appCtrl.appTheme.sameWhite)),
                                Image.asset(eImageAssets.subscriptionCrown,
                                    height: Sizes.s80)
                              ]).marginSymmetric(horizontal: Insets.i20))
                        ])
                            .width(MediaQuery.of(context).size.width)
                            .paddingSymmetric(horizontal: Insets.i20),
                        const VSpace(Sizes.s20),
                        const SubscriptionAdvantage(),
                        const VSpace(Sizes.s20),
                        Text(appFonts.choosePeriod.tr,
                                style: AppCss.outfitBold16
                                    .textColor(appCtrl.appTheme.txt))
                            .paddingSymmetric(horizontal: Insets.i20),
                        const VSpace(Sizes.s25),
                        const SubscriptionList(),
                        const VSpace(Sizes.s20),
                        ButtonCommon(
                            margin: Insets.i20,
                            title: appFonts.selectPlan.tr,
                            onTap: () => subscribeCtrl.onPayPlan()),
                        const VSpace(Sizes.s15),
                        Text(appFonts.continueWithLimitedVersion.tr,
                                style: AppCss.outfitRegular16
                                    .textColor(appCtrl.appTheme.primary))
                            .inkWell(onTap: () => appCtrl.splashDataCheck())
                            .alignment(Alignment.center)
                      ]).marginSymmetric(vertical: Insets.i25)))));
    });
  }
}
