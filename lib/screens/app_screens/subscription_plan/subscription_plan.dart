import 'package:probot/screens/app_screens/subscription_plan/layouts/after_subscribe.dart';

import '../../../config.dart';

class SubscriptionPlan extends StatelessWidget {
  final subscriptionCtrl = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());

  SubscriptionPlan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DirectionalityRtl(
        child: Scaffold(
            backgroundColor: appCtrl.appTheme.bg1,
            appBar: AppAppBarCommon(
                title: appFonts.subscriptionPlan,
                actionIcon: eSvgAssets.currency,
                leadingOnTap: () => Get.back()),
            body:
                GetBuilder<SubscriptionController>(builder: (subscriptionCtrl) {
              return SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Stack(children: [
                      Image.asset(eImageAssets.subscriptionTopBg),
                      IntrinsicHeight(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(appFonts.planPeriod.tr,
                            style: AppCss.outfitBold16
                                .textColor(appCtrl.appTheme.txt))
                        .paddingSymmetric(horizontal: Insets.i20),
                    const VSpace(Sizes.s25),
                    const AfterSubscribe(),
                    const VSpace(Sizes.s20)
                  ]).marginSymmetric(vertical: Insets.i25));
            })));
  }
}
