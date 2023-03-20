


import '../../../../config.dart';

class SubscriptionList extends StatelessWidget {
  final SubscribeModel? subscribeModel;

  const SubscriptionList({Key? key, this.subscribeModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonSubscribeTitle(subscribeModel: subscribeModel),
        ...subscribeModel!.benefits!
            .map((e) => Row(
                  children: [
                    Icon(Icons.circle,
                        size: Sizes.s3, color: appCtrl.appTheme.lightText),
                    const HSpace(Sizes.s8),
                    Text(e.toString().tr,
                        style: AppCss.outfitLight14
                            .textColor(appCtrl.appTheme.lightText)),
                  ],
                ).marginSymmetric(horizontal: Insets.i20, vertical: Insets.i8))
            .toList(),
        const VSpace(Sizes.s10),
        DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1,
                dashLength: 3,
                dashColor: appCtrl.appTheme.txt.withOpacity(.1))
            .marginSymmetric(horizontal: Insets.i15),
        const VSpace(Sizes.s12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RichText(
              text: TextSpan(
                  text:
                      "${appCtrl.priceSymbol}${(appCtrl.currencyVal * subscribeModel!.price!).toStringAsFixed(2)} / ",
                  style:
                      AppCss.outfitSemiBold18.textColor(appCtrl.appTheme.txt),
                  children: <TextSpan>[
                TextSpan(
                    text: subscribeModel!.priceTpe!.tr.toUpperCase(),
                    style:
                        AppCss.outfitMedium14.textColor(appCtrl.appTheme.txt))
              ])),
          Row(children: [
            Text(appFonts.payNow.tr,
                style:
                    AppCss.outfitMedium14.textColor(appCtrl.appTheme.primary)),
            const HSpace(Sizes.s8),
            SvgPicture.asset(eSvgAssets.rightArrow,
                colorFilter:
                    ColorFilter.mode(appCtrl.appTheme.primary, BlendMode.srcIn))
          ])
        ]).marginSymmetric(horizontal: Insets.i15),
        const VSpace(Sizes.s20)
      ],
    );
  }
}
