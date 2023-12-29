import 'package:probot/screens/app_screens/subscription_plan/layouts/plan_list_ui.dart';

import '../../../../config.dart';

class SubscribePlanUI extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? snapShot;
  final dynamic data;

  const SubscribePlanUI({Key? key, this.snapShot, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      ClipSmoothRect(
          clipBehavior: Clip.hardEdge,
          child: Container(
              margin: const EdgeInsets.symmetric(
                  vertical: Insets.i8, horizontal: Insets.i5),
              decoration: BoxDecoration(
                  color:  snapShot!.data!.docs.isEmpty  ?  appCtrl.appTheme.primaryLight : snapShot!.data!.docs[0]
                              .data()["subscriptionType"]
                              .toString()
                              .toLowerCase() ==
                          data["type"].toString().toLowerCase()
                      ? appCtrl.appTheme.yellowColor
                      : appCtrl.appTheme.primaryLight,
                  border: Border.all(
                      color:   snapShot!.data!.docs.isEmpty  ?  appCtrl.appTheme.primaryLight1 :  snapShot!.data!.docs[0]
                                  .data()["subscriptionType"]
                                  .toString()
                                  .toLowerCase() ==
                              data["type"].toString().toLowerCase()
                          ? appCtrl.appTheme.yellowColor
                          : appCtrl.appTheme.primaryLight1),
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
              child:PlanListUi(snapShot: snapShot,data: data))),
      if (  snapShot!.data != null && snapShot!.data!.docs.isNotEmpty  &&   snapShot!.data!.docs[0]
              .data()["subscriptionType"]
              .toString()
              .toLowerCase() ==
          data["type"].toString().toLowerCase())
        SvgPicture.asset(eSvgAssets.crown,
                colorFilter: ColorFilter.mode(
                    appCtrl.appTheme.sameWhite, BlendMode.srcIn))
            .paddingAll(Insets.i8)
            .decorated(
                color: appCtrl.appTheme.yellowColor, shape: BoxShape.circle)
    ]).inkWell(onTap: () => Get.toNamed(routeName.viewSubscription));
  }
}
