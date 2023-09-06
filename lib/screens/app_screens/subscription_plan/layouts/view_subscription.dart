import "dart:developer";

import "../../../../config.dart";

class ViewSubscription extends StatelessWidget {
  const ViewSubscription({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscribeCtrl) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.bg1,
          appBar: AppAppBarCommon(
              title: appFonts.subscriptionPlan,
              actionIcon: eSvgAssets.currency,
              isAction: true,
              leadingOnTap: () => Get.back(),
              actionOnTap: () => subscribeCtrl.currencyListDialog()),
          body: SingleChildScrollView(
              child: Column(children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("plans")
                    .orderBy("price", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container();
                  } else if (!snapshot.hasData) {
                    return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    appCtrl.appTheme.primary)))
                        .height(MediaQuery.of(context).size.height);
                  } else {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("userSubscribe")
                            .where("email",
                                isEqualTo: appCtrl.storage.read("userName"))
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapShot) {
                          if (snapShot.hasData) {
                            return Column(children: [
                              ...snapshot.data!
                                  .docs
                                  .asMap()
                                  .entries
                                  .map((e) {
                                SubscribeModel subscribe =
                                SubscribeModel.fromJson(e.value.data());
                                return ViewSubscriptionLayout(
                                    data: e.value.data(),
                                    cancelOnTap: () =>
                                        subscribeCtrl.onTapCancelSubscription(
                                            snapShot.data!.docs[0]
                                                .data()["subscriptionId"],snapShot.data!.docs[0].id),
                                    onTap: () =>
                                        subscribeCtrl.onTapPlan(e.value),
                                    snapShot: snapShot,
                                    subscribe: subscribe)
                                    .planListExtension()
                                    .marginOnly(bottom: Insets.i20);
                              }).toList()
                            ]);
                          } else {
                            return Container();
                          }
                        });
                  }
                })
          ]).marginSymmetric(vertical: Insets.i25, horizontal: Insets.i20)));
    });
  }
}
