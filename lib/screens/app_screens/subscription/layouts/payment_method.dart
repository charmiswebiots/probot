import 'dart:developer';
import 'dart:io';
import '../../../../config.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../../../controllers/common_controllers/in_app_controller.dart';
import '../../card_screen/card_screen.dart';

class PaymentList extends StatelessWidget {
  final String? data;
  final SubscribeModel? subscribe;
  final dynamic argData;

  const PaymentList({Key? key, this.data, this.subscribe,this.argData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return GetBuilder<SubscriptionController>(builder: (subscribeCtrl) {
          return CommonStream(
            child: Material(
                color: appCtrl.appTheme.trans,
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      CommonPopUpTitle(title: appFonts.payMoneyFrom.tr),
                      DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 1,
                          dashLength: 3,
                          dashColor: appCtrl.appTheme.txt.withOpacity(.1)),
                      const VSpace(Sizes.s25),
                      (appCtrl.firebaseConfigModel!.isPaypal! == false &&
                              appCtrl.firebaseConfigModel!.isRazorPay! == false &&
                              appCtrl.firebaseConfigModel!.isStripe! == false &&
                              appCtrl.firebaseConfigModel!.isInApp! == false )
                          ? Text(appFonts.noPaymentMethod.tr,
                                  style: AppCss.outfitSemiBold16
                                      .textColor(appCtrl.appTheme.error))
                              .paddingSymmetric(horizontal: Insets.i20)
                          : Column(
                              children:
                                  appArray.paymentMethodList.asMap().entries.map((e) {
                              return e.value["title"] == "payPal"
                                  ? appCtrl.firebaseConfigModel!.isPaypal!
                                      ? PaymentMethodList(
                                          index: e.key,
                                          data: e.value,
                                          selectIndexPayment:
                                              subscribeCtrl.selectIndexPayment,
                                          onTap: () {
                                            subscribeCtrl.selectIndexPayment = e.key;
                                            subscribeCtrl.subscribeModel = subscribe;
                                            subscribeCtrl.update();
                                          })
                                      : Container()
                                  : e.value["title"] == "razor"
                                      ? appCtrl.firebaseConfigModel!.isRazorPay!
                                          ? PaymentMethodList(
                                              index: e.key,
                                              data: e.value,
                                              selectIndexPayment:
                                                  subscribeCtrl.selectIndexPayment,
                                              onTap: () {
                                                subscribeCtrl.selectIndexPayment =
                                                    e.key;
                                                subscribeCtrl.subscribeModel =
                                                    subscribe;
                                                subscribeCtrl.update();
                                              })
                                          : Container()
                                      : e.value["title"] == "stripe"
                                          ? appCtrl.firebaseConfigModel!.isStripe!
                                              ? PaymentMethodList(
                                                  index: e.key,
                                                  data: e.value,
                                                  selectIndexPayment: subscribeCtrl
                                                      .selectIndexPayment,
                                                  onTap: () {
                                                    subscribeCtrl.selectIndexPayment =
                                                        e.key;
                                                    subscribeCtrl.subscribeModel =
                                                        subscribe;
                                                    subscribeCtrl.update();
                                                  })
                                              : Container()
                                          : e.value["title"] == "inApp"
                                              ? appCtrl.firebaseConfigModel!.isInApp!
                                                  ? PaymentMethodList(
                                                      index: e.key,
                                                      data: e.value,
                                                      selectIndexPayment:
                                                          subscribeCtrl
                                                              .selectIndexPayment,
                                                      onTap: () {
                                                        subscribeCtrl
                                                                .selectIndexPayment =
                                                            e.key;
                                                        subscribeCtrl.subscribeModel =
                                                            subscribe;
                                                        subscribeCtrl.update();
                                                      })
                                                  : Container()

                                                  : Container();
                            }).toList()),
                      const VSpace(Sizes.s35),
                      (appCtrl.firebaseConfigModel!.isPaypal! == false &&
                              appCtrl.firebaseConfigModel!.isRazorPay! == false &&
                              appCtrl.firebaseConfigModel!.isStripe! == false &&
                              appCtrl.firebaseConfigModel!.isInApp! == false
                             )
                          ? Container()
                          : Row(children: [
                              Expanded(
                                  child: ButtonCommon(
                                      onTap: () => Get.back(),
                                      title: appFonts.cancel,
                                      isGradient: false,
                                      style: AppCss.outfitMedium16
                                          .textColor(appCtrl.appTheme.primary),
                                      color: appCtrl.appTheme.trans,
                                      borderColor: appCtrl.appTheme.primary)),
                              const HSpace(Sizes.s15),
                              Expanded(
                                  child: ButtonCommon(
                                      onTap: () {
                                        if (subscribeCtrl.selectIndexPayment == 0) {
                                          subscribeCtrl.onPaypalPayment(
                                              amount: data!, subscribe: subscribe);
                                          Get.back();
                                        } else if (subscribeCtrl.selectIndexPayment ==
                                            1) {
                                          // log("SUBSCRIBE $subscribe");
                                          //  Get.back();
                                          // Get.to(() => CardScreen(subscribeModel: subscribe),arguments: argData);
                                          subscribeCtrl.stripePayment(
                                              amount: data!,
                                              currency: 'INR',
                                              subscribe: subscribe);

                                        } else if (subscribeCtrl.selectIndexPayment ==
                                            2) {
                                          subscribeCtrl.openSession(
                                              subscribe: subscribe);
                                          Get.back();
                                        } else if (subscribeCtrl.selectIndexPayment ==
                                            3) {
                                          late PurchaseParam purchaseParam;
                                          final Map<String, PurchaseDetails>
                                              purchases = Map<String,
                                                      PurchaseDetails>.fromEntries(
                                                  inAppCtrl.purchases.map(
                                                      (PurchaseDetails purchase) {
                                            if (purchase.pendingCompletePurchase) {
                                              inAppCtrl.inAppPurchase
                                                  .completePurchase(purchase);
                                            }
                                            log("_purchases : ${inAppCtrl.purchases}");
                                            return MapEntry<String, PurchaseDetails>(
                                                purchase.productID, purchase);
                                          }));

                                          if (Platform.isAndroid) {
                                            // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                                            // verify the latest status of you your subscription by using server side receipt validation
                                            // and update the UI accordingly. The subscription purchase status shown
                                            // inside the app may not be accurate.
                                            final GooglePlayPurchaseDetails?
                                                oldSubscription = _getOldSubscription(
                                                    subscribe!.planType!
                                                                .toLowerCase() ==
                                                            "weekly"
                                                        ? inAppCtrl.products[7]
                                                        : subscribe!.planType!
                                                                    .toLowerCase() ==
                                                                "monthly"
                                                            ? inAppCtrl.products[6]
                                                            : inAppCtrl.products[8],
                                                    purchases);

                                            purchaseParam = GooglePlayPurchaseParam(
                                                productDetails: subscribe!.planType!
                                                            .toLowerCase() ==
                                                        "weekly"
                                                    ? inAppCtrl.products[7]
                                                    : subscribe!.planType!
                                                                .toLowerCase() ==
                                                            "monthly"
                                                        ? inAppCtrl.products[6]
                                                        : inAppCtrl.products[8],
                                                changeSubscriptionParam:
                                                    (oldSubscription != null)
                                                        ? ChangeSubscriptionParam(
                                                            oldPurchaseDetails:
                                                                oldSubscription,
                                                          )
                                                        : null);
                                          } else {
                                            purchaseParam = PurchaseParam(
                                                productDetails: subscribe!.planType!
                                                            .toLowerCase() ==
                                                        "weekly"
                                                    ? inAppCtrl.products[7]
                                                    : subscribe!.planType!
                                                                .toLowerCase() ==
                                                            "monthly"
                                                        ? inAppCtrl.products[6]
                                                        : inAppCtrl.products[8]);

                                            log("IOS : $purchaseParam");
                                          }
                                          log("inAppCtrl.products[1] : ${inAppCtrl.products[0]}");
                                          String id = subscribe!.planType!
                                                      .toLowerCase() ==
                                                  "weekly"
                                              ? inAppCtrl.products[7].id
                                              : subscribe!.planType!.toLowerCase() ==
                                                      "monthly"
                                                  ? inAppCtrl.products[6].id
                                                  : inAppCtrl.products[8].id;
                                          log("id : $id");
                                          inAppCtrl.inAppPurchase.buyConsumable(
                                              purchaseParam: purchaseParam,
                                              autoConsume: kAutoConsume);
                                          final Stream<List<PurchaseDetails>>
                                              purchaseUpdated =
                                              inAppCtrl.inAppPurchase.purchaseStream;
                                          inAppCtrl.subscription = purchaseUpdated
                                              .listen((List<PurchaseDetails>
                                                  purchaseDetailsList) async {
                                            log("LOSY purchaseDetailsList : #$purchaseDetailsList");
                                            for (final PurchaseDetails purchaseDetails
                                                in purchaseDetailsList) {
                                              log("purchaseDetails.status : ${purchaseDetails.status}");
                                              if (purchaseDetails.status ==
                                                  PurchaseStatus.pending) {
                                                inAppCtrl.showPendingUI();
                                              } else {
                                                if (purchaseDetails.status ==
                                                    PurchaseStatus.error) {
                                                  inAppCtrl.handleError(
                                                      purchaseDetails.error!);
                                                } else if (purchaseDetails.status ==
                                                        PurchaseStatus.purchased ||
                                                    purchaseDetails.status ==
                                                        PurchaseStatus.restored) {
                                                  final bool valid =
                                                      await inAppCtrl.verifyPurchase(
                                                          purchaseDetails);
                                                  if (valid) {
                                                    inAppCtrl.deliverProduct(
                                                        purchaseDetails,
                                                        subscribe: subscribe);
                                                  } else {
                                                    inAppCtrl.handleInvalidPurchase(
                                                        purchaseDetails);
                                                    return;
                                                  }
                                                }
                                              }
                                            }
                                          }, onDone: () {
                                            inAppCtrl.subscription.cancel();
                                          }, onError: (Object error) {
                                            // handle error here.
                                          });
                                        }
                                      },
                                      title: appFonts.apply))
                            ]).marginSymmetric(horizontal: Insets.i15),
                      const VSpace(Sizes.s25)
                    ])
                    .decorated(
                        color: appCtrl.appTheme.white,
                        borderRadius: BorderRadius.circular(AppRadius.r10))
                    .marginSymmetric(horizontal: Insets.i20))
          );
        });
      }
    );
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == basicSubPlan9 &&
        purchases[advanceSubPlan19] != null) {
      oldSubscription =
          purchases[advanceSubPlan19]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == advanceSubPlan19 &&
        purchases[basicSubPlan9] != null) {
      oldSubscription = purchases[basicSubPlan9]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == advanceSubPlan29 &&
        purchases[advanceSubPlan29] != null) {
      oldSubscription =
          purchases[advanceSubPlan29]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}
