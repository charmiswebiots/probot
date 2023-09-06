import 'dart:developer';
import 'package:probot/config.dart';

class SubscriptionFirebaseController extends GetxController {
  //subscribe plan
  subscribePlan(
      {SubscribeModel? subscribeModel,
      paymentMethod,
      isSubscribe = true,
      amountBalance,
      isBack, subscriptionId}) async {
    DateTime now = DateTime.now();
    DateTime? expiryDate;
    if (isSubscribe == true) {
      appCtrl.isSubscribe = true;
      appCtrl.storage.write(session.isSubscribe, true);
      if (subscribeModel!.planType == "Weekly") {
        expiryDate = DateTime(now.year, now.month, now.day + 7);
      } else if (subscribeModel.planType == "Monthly") {
        expiryDate = DateTime(now.year, now.month + 1, now.day);
      } else {
        expiryDate = DateTime(now.year + 1, now.month, now.day);
      }
    } else {
      log("AMOUIJT : ${appCtrl.envConfig["balance"]}");
      int balance = appCtrl.envConfig["balance"];
      balance = int.parse(amountBalance.toString()) + balance;
      log("amountBalance : $balance");
      appCtrl.envConfig["balance"] = balance;
    }
    appCtrl.isAnySubscribe = true;
    appCtrl.storage.write(session.isAnySubscribe, true);
    log("EXPIER : $expiryDate");
    log("subscribeModel : #$subscribeModel");
    String? userName;
    userName = appCtrl.storage.read("userName");
    int id = DateTime.now().millisecondsSinceEpoch;
    log("appCtrl.envConfig: ${appCtrl.envConfig}");
    appCtrl.update();
    Get.forceAppUpdate();
    await FirebaseFirestore.instance
        .collection("userSubscribe")
        .where("email", isEqualTo: appCtrl.storage.read("userName"))
        .limit(1)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection("userSubscribe")
            .doc(id.toString())
            .set({
          "email": userName,
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "subscriptionType": isSubscribe ? subscribeModel!.type : "",
          "isExpiry": false,
          "isSubscribe": isSubscribe,
          "createdDate": DateTime.now().millisecondsSinceEpoch,
          "expiryDate": expiryDate,
          "price": isSubscribe ? 0 : amountBalance,
          "balance": appCtrl.envConfig["balance"],
          "paymentMethod": paymentMethod,
          "subscriptionId": isSubscribe ? subscriptionId : "",
        }).then((value) {
          if(isBack) {
           Get.back();
           Get.toNamed(routeName.subscriptionPlan);
          } else {appCtrl.splashDataCheck();
          }
        });
      } else {
        await FirebaseFirestore.instance
            .collection("userSubscribe")
            .doc(value.docs[0].id)
            .update({
          "email": userName,
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "createdDate": DateTime.now().millisecondsSinceEpoch,
          "expiryDate": expiryDate,
          "price": isSubscribe ? 0 : amountBalance,
          "isSubscribe": isSubscribe,
          "subscriptionType": isSubscribe ? subscribeModel!.type : "",
          "balance": appCtrl.envConfig["balance"],
          "paymentMethod": paymentMethod,
          "subscriptionId": isSubscribe ? subscriptionId : "",
        }).then((value) {
          if(isBack) {
            Get.back();
            Get.toNamed(routeName.subscriptionPlan);
          } else {appCtrl.splashDataCheck();
          }
        });
      }
    });
  }

  // add or update firebase data
  addUpdateFirebaseData() {
    FirebaseFirestore.instance
        .collection("userSubscribe")
        .where("email", isEqualTo: appCtrl.storage.read("userName"))
        .limit(1)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        if (value.docs[0].data()["isSubscribe"] == false) {
          FirebaseFirestore.instance
              .collection("userSubscribe")
              .doc(value.docs[0].id)
              .update({
            "balance": appCtrl.envConfig["balance"],
          }).then((value) async {
            await FirebaseFirestore.instance
                .collection("userSubscribe")
                .where("email", isEqualTo: appCtrl.storage.read("userName"))
                .limit(1)
                .get()
                .then((value) {
              if (value.docs.isNotEmpty) {
                appCtrl.envConfig["balance"] = value.docs[0].data()["balance"];
                appCtrl.storage.write(session.envConfig, appCtrl.envConfig);
                appCtrl.envConfig = appCtrl.storage.read(session.envConfig);
              }
            });
          });
          update();
        }
      } else {
        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          "balance": appCtrl.envConfig["balance"],
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((userVal) {
            if (userVal.exists) {
              appCtrl.envConfig["balance"] = userVal.data()!["balance"];
              appCtrl.storage.write(session.envConfig, appCtrl.envConfig);
              appCtrl.envConfig = appCtrl.storage.read(session.envConfig);
              update();
            }
          });
        });
      }
    });
  }

  removeBalance() {
    int balance = appCtrl.envConfig["balance"];
    if (balance == 0) {
      appCtrl.balanceTopUpDialog();
    } else {
      balance = balance - 1;
      appCtrl.envConfig["balance"] = balance;
      log("BALANCE : ${appCtrl.envConfig["balance"]}");

      update();
      if (!appCtrl.isGuestLogin) {
        addUpdateFirebaseData();
      } else {
        log("BALANCE : ${appCtrl.envConfig["balance"]}");

        appCtrl.storage.write(session.envConfig, appCtrl.envConfig);
        appCtrl.update();
      }
    }
  }
}
