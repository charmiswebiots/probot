import '../../../../config.dart';

class TableCommon extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapShot;

  const TableCommon({Key? key, required this.snapShot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscribeCtrl) {
      return Table(columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(flex: 3.5),
        1: FlexColumnWidth(),
        2: FlexColumnWidth()
      }, children: [
        CommonAppWidgets().tableRow(),
        ...snapShot.data!.docs.asMap().entries.map((e) {
          return TableRow(
              decoration: BoxDecoration(
                  color: appCtrl.appTheme.white,
                  border: Border(
                      bottom: BorderSide(
                          color: e.key != snapShot.data!.docs.length - 1
                              ? appCtrl.appTheme.white
                              : appCtrl.appTheme.primaryLightBorder))),
              children: [
                Text(e.value.data()["title"],
                        style: AppCss.outfitRegular14
                            .textColor(appCtrl.appTheme.txt))
                    .paddingOnly(
                        left: Insets.i20,
                        top: e.key == 0 ? Insets.i16 : 0,
                        bottom: Insets.i20),
                SvgPicture.asset(e.key == 0
                        ? eSvgAssets.offerTick
                        : eSvgAssets.offerCancel)
                    .paddingOnly(
                        top: e.key == 0 ? Insets.i14 : 0, bottom: Insets.i20)
                    .tableExtension(),
                SvgPicture.asset(subscribeCtrl.selectedPlan == 0
                        ? e.value.data()["isWeekly"]
                            ? eSvgAssets.offerTick
                            : eSvgAssets.offerCancel
                        : subscribeCtrl.selectedPlan == 1
                            ? e.value.data()["isMonthly"]
                                ? eSvgAssets.offerTick
                                : eSvgAssets.offerCancel
                            : e.value.data()["isLimited"]
                                ? eSvgAssets.offerTick
                                : eSvgAssets.offerCancel)
                    .paddingOnly(
                        top: e.key == 0 ? Insets.i14 : 0, bottom: Insets.i20)
                    .tableExtension()
              ]);
        }).toList()
      ]);
    });
  }
}
