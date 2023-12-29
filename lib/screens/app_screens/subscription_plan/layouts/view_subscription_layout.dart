import 'package:intl/intl.dart';
import '../../../../config.dart';

class ViewSubscriptionLayout extends StatelessWidget {
  final SubscribeModel? subscribe;
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? snapShot;
  final dynamic data;
  final GestureTapCallback? onTap,cancelOnTap;

  const ViewSubscriptionLayout(
      {Key? key, this.subscribe, this.snapShot, this.data, this.onTap,this.cancelOnTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CommonSubscribeTitle(
          subscribeModel: subscribe,
          isActivePlan: snapShot!.data!.docs.isEmpty  ?  false :snapShot!.data!.docs[0]
                  .data()["subscriptionType"]
                  .toString()
                  .toLowerCase() ==
              data["type"].toString().toLowerCase()),
      const VSpace(Sizes.s20),
      snapShot!.data != null && snapShot!.data!.docs.isNotEmpty  &&     snapShot!.data!.docs[0]
                  .data()["subscriptionType"]
                  .toString()
                  .toLowerCase() ==
              data["type"].toString().toLowerCase()
    ? Column(children: [
              CommonRow(
                  title: appFonts.paidAmount,
                  price:
                      "${appCtrl.priceSymbol}${(appCtrl.currencyVal * data["price"]).toStringAsFixed(0)}"),
              const VSpace(Sizes.s20),
              CommonRow(
                  title: appFonts.including,
                  price: appFonts.unlimitedChatImage.tr),
              const VSpace(Sizes.s40),
              DottedLines(color: appCtrl.appTheme.txt.withOpacity(.1)),
              const VSpace(Sizes.s15),
              CommonRow(
                  color: appCtrl.appTheme.redColor,
                  title: appFonts.expiryDate,
                  price: DateFormat("dd/MM/yyyy").format(DateTime.parse(
                      snapShot!.data!.docs[0]["expiryDate"]
                          .toDate()
                          .toString()))),
        const VSpace(Sizes.s20),
        ButtonCommon(
            title: appFonts.cancel,
            isGradient: false,
            margin: 0,
            onTap: cancelOnTap,
            style: AppCss.outfitRegular18
                .textColor(appCtrl.appTheme.primary)
                .letterSpace(.4),
            color: appCtrl.appTheme.white,
            borderColor: appCtrl.appTheme.primary)
            ]).marginSymmetric(horizontal: Insets.i15)
          : Column(children: [
              textCommon.semiBoldPrimary18(
                  text:
                      "${appCtrl.priceSymbol}${(appCtrl.currencyVal * subscribe!.price!).toStringAsFixed(2)} only/- "),
              const VSpace(Sizes.s20),
              RowCommon(title: appFonts.unlimitedChatForMonth),
              const VSpace(Sizes.s15),
              RowCommon(title: appFonts.unlimitedImage),
              const VSpace(Sizes.s15),
              RowCommon(title: appFonts.unlimitedContent)
            ]).marginSymmetric(horizontal: Insets.i15),
      const VSpace(Sizes.s20),
      if (  snapShot!.data != null && snapShot!.data!.docs.isNotEmpty  &&  snapShot!.data!.docs[0]
              .data()["subscriptionType"]
              .toString()
              .toLowerCase() !=
          data["type"].toString().toLowerCase())
        ButtonCommon(
            title: appFonts.selectThisPlan,
            isGradient: false,
            margin: 15,
            onTap: onTap,
            style: AppCss.outfitRegular18
                .textColor(appCtrl.appTheme.primary)
                .letterSpace(.4),
            color: appCtrl.appTheme.white,
            borderColor: appCtrl.appTheme.primary).paddingOnly(bottom: Insets.i20),

    ]);
  }
}
