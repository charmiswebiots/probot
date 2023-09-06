import 'dart:developer';

import '../../../../config.dart';

class SubscriptionList extends StatelessWidget {
  const SubscriptionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscribeCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("plans")
              .orderBy("price", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return   StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("userSubscribe")
                      .where("email",
                          isEqualTo: appCtrl.storage.read("userName"))
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapShot) {
                    if (snapShot.hasData) {
                      if(snapShot.data != null && snapShot.data!.docs.isNotEmpty) {
                        log("SNAOOO");
                        return PlanListCommon(snapShot: snapshot);
                      }else{
                        log("SNAO");
                        subscribeCtrl.subscribeModel = SubscribeModel.fromJson(
                            snapshot.data!.docs[0].data());
                        subscribeCtrl.selectedPrice =
                        subscribeCtrl.subscribeModel!.price!;
                        return PlanListCommon(snapShot: snapshot);
                      }
                    } else {


                      subscribeCtrl.subscribeModel = SubscribeModel.fromJson(
                          snapshot.data!.docs[0].data());
                      subscribeCtrl.selectedPrice =
                          subscribeCtrl.subscribeModel!.price!;
                      return PlanListCommon(snapShot: snapshot);
                    }
                  });
            } else {
              return Container();
            }
          });
    });
  }
}
