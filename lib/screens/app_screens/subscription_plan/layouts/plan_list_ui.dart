import 'package:intl/intl.dart';
import '../../../../config.dart';

class PlanListUi extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? snapShot;
  final dynamic data;

  const PlanListUi({Key? key, this.data, this.snapShot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipSmoothRect(
          child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Insets.i20, vertical: Insets.i15),
              child: Column(children: [
                snapShot!.data != null && snapShot!.data!.docs.isNotEmpty  &&      snapShot!.data!.docs[0]
                            .data()["subscriptionType"]
                            .toString()
                            .toLowerCase() ==
                        data["type"].toString().toLowerCase()
                    ? Text("PURCHASED",
                        style: AppCss.outfitMedium10
                            .textColor(appCtrl.appTheme.lightText))
                    : Text(data["type"],
                        style: AppCss.outfitMedium14
                            .textColor(appCtrl.appTheme.primary)),
                const VSpace(Sizes.s10),
                Text(
                    appCtrl.priceSymbol +
                        (appCtrl.currencyVal * data["price"])
                            .toStringAsFixed(0)
                            .toString(),
                    style: AppCss.outfitBold18
                        .textColor(appCtrl.appTheme.sameBlack)),
                const VSpace(Sizes.s5),
                textCommon.regularLightText12(text:"/${data["type"]}")
              ])).planExtension(appCtrl.appTheme.sameWhite)),
      (  snapShot!.data != null && snapShot!.data!.docs.isNotEmpty  &&   snapShot!.data!.docs[0]
                  .data()["subscriptionType"]
                  .toString()
                  .toLowerCase() ==
              data["type"].toString().toLowerCase())
          ? Column(children: [
              Text("Renews",
                  textAlign: TextAlign.center,
                  style: AppCss.outfitMedium12
                      .textColor(appCtrl.appTheme.sameWhite)
                      .textHeight(1.2)),
              const VSpace(Sizes.s5),
              Text(
                  snapShot!.data!.docs[0]["subscriptionType"] != "lifetime"
                      ? DateFormat("dd/MM/yyyy").format(DateTime.parse(snapShot!
                          .data!.docs[0]["expiryDate"]
                          .toDate()
                          .toString()))
                      : "Lifetime",
                  textAlign: TextAlign.center,
                  style: AppCss.outfitBold12
                      .textColor(appCtrl.appTheme.sameWhite)
                      .textHeight(1.2))
            ]).marginSymmetric(vertical: Insets.i6)
          : Text(data["title"].toString().replaceAll("-", "\n"),
                  textAlign: TextAlign.center,
                  style: AppCss.outfitMedium12
                      .textColor(appCtrl.appTheme.primary)
                      .textHeight(1.2))
              .paddingSymmetric(vertical: Insets.i8)
    ]);
  }
}
