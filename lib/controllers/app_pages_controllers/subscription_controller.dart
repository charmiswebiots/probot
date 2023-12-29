import 'dart:convert';
import 'dart:developer';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../config.dart';
import '../../screens/app_screens/subscription/layouts/paypal_payment.dart';
import '../../screens/app_screens/subscription/layouts/razorpay_services.dart';

class SubscriptionController extends GetxController {
  List<SubscribeModel> subscriptionLists = [];
  List currencyList = [];
  int selectedPrice = 0;
  int finalPrice = 9;
  int selectIndex = 0;
  int selectedPlan = 0;
  int selectIndexPayment = 0;
  SubscribeModel? subscribeModel;
  List paymentMethods = [];
  Map<String, dynamic>? paymentIntentData;
  bool isLoading = false, isBack = true;

  String? checkoutUrl;
  String? executeUrl;
  String? accessToken;
  PaypalServices services = PaypalServices();
  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';
  WebViewController controller = WebViewController();
  final client = http.Client();
  Razorpay razorpay = Razorpay();

  // item name, price and quantity
  String itemName = 'PROBOT SUBSCRIPTION';
  String? planType;
  String? finalPlan;
  int quantity = 1;
  Function? onFinish;

  Map<String, String> headers = {
    'Authorization': 'Bearer ${appCtrl.firebaseConfigModel!.stripeKey}',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<Map<String, dynamic>> onTapCancelSubscription(subId,docId) async {
    log("SUB ID $subId");
    final String url = 'https://api.stripe.com/v1/subscriptions/$subId';

    var response = await http.delete(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        "cancel_at_period_end": true,
      }),
    );
    if (response.statusCode == 200) {

      await FirebaseFirestore.instance.collection("userSubscribe").doc(docId).delete().then((value) {

        showDialog(
            barrierDismissible: false,
            context: Get.context!,
            builder: (context) {
              return AlertDialogCommon(
                  image: eImageAssets.success,
                  bText1: appFonts.okay,
                  title: appFonts.alert,
                  subtext: appFonts.successfullyCancelSubscription,
                  b1OnTap:  isBack ? () {
                    final quickAdvisorCtrl = Get.isRegistered<QuickAdvisorController>()
                        ? Get.find<QuickAdvisorController>()
                        : Get.put(QuickAdvisorController());
                    quickAdvisorCtrl.onReady();
                    appCtrl.isSubscribe = false;
                    appCtrl.isAnySubscribe = false;
                    appCtrl.storage.write(session.isSubscribe, false);
                    appCtrl.storage.write(session.isAnySubscribe, false);
                    appCtrl.update();
                    Get.back();
                    Get.offAllNamed(routeName.dashboard);

                  } :() => appCtrl.splashDataCheck(),
                  crossOnTap:
                  isBack ? () {
                    final quickAdvisorCtrl = Get.isRegistered<QuickAdvisorController>()
                        ? Get.find<QuickAdvisorController>()
                        : Get.put(QuickAdvisorController());
                    quickAdvisorCtrl.onReady();
                    appCtrl.isSubscribe = false;
                    appCtrl.isAnySubscribe = false;
                    appCtrl.storage.write(session.isSubscribe, false);
                    appCtrl.storage.write(session.isAnySubscribe, false);
                    appCtrl.update();
                    Get.back();
                    Get.offAllNamed(routeName.dashboard);
                  } :() => appCtrl.splashDataCheck());
            });
        appCtrl.update();
        Get.forceAppUpdate();
      });
      log("Cancel RES ${json.decode(response.body)}");
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw snackBarMessengers(message: "Failed To Cancel Subscription");
    }
  }



  // Stripe Payment Method
  Future<void> stripePayment(
      {required String amount,
      required String currency,
      SubscribeModel? subscribe}) async {
    try {
      isLoading = true;
      paymentIntentData = await createPaymentIntent(amount, currency);

     log("STRIPE $paymentIntentData");
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(

            paymentSheetParameters: SetupPaymentSheetParameters(
                merchantDisplayName: 'JUSTIN',
                billingDetails: const BillingDetails(
                  email: 'email@stripe.com',
                  phone: '+60123456789',
                  address: Address(
                    city: 'Kuala Lumpur',
                    country: 'US',
                    line1: 'Concourse Level',
                    line2: '',
                    state: '',
                    postalCode: '90001',
                  ),
                ),
                customerId: paymentIntentData!['customer'],
                paymentIntentClientSecret: paymentIntentData!['client_secret'],
                customerEphemeralKeySecret:
                    paymentIntentData!['ephemeralKey']));

        isLoading = false;

        displayPaymentSheet(subscribe, "stripe");
        update();
      }
    } catch (e) {
      throw Exception("$e");
    }
    update();
  }

  // Stripe Error handler
  displayPaymentSheet(subscribe, paymentMethod) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      showDialog(
          barrierDismissible: false,
          context: Get.context!,
          builder: (context) {
            return AlertDialogCommon(
                image: eImageAssets.paymentSuccess,
                bText1: appFonts.okay,
                title: appFonts.paymentSuccess,
                subtext: appFonts.congratulation,
                b1OnTap: () async {
                  final firebaseCtrl =
                      Get.isRegistered<SubscriptionFirebaseController>()
                          ? Get.find<SubscriptionFirebaseController>()
                          : Get.put(SubscriptionFirebaseController());
                  firebaseCtrl.subscribePlan(
                      subscribeModel: subscribe,
                      paymentMethod: paymentMethod,
                      isBack: isBack);
                },
                crossOnTap: isBack
                    ? () {
                        final firebaseCtrl =
                            Get.isRegistered<SubscriptionFirebaseController>()
                                ? Get.find<SubscriptionFirebaseController>()
                                : Get.put(SubscriptionFirebaseController());
                        firebaseCtrl.subscribePlan(
                            subscribeModel: subscribe,
                            paymentMethod: paymentMethod,
                            isBack: isBack);
                      }
                    : () => appCtrl.splashDataCheck());
          });
    } on Exception {
      showDialog(
          barrierDismissible: false,
          context: Get.context!,
          builder: (context) {
            return AlertDialogCommon(
                image: eImageAssets.paymentFailed,
                bText1: appFonts.tryAgain,
                title: appFonts.paymentFailed,
                subtext: appFonts.oppsDueTo,
                b1OnTap: () => isBack ? Get.back() : appCtrl.splashDataCheck(),
                crossOnTap: () =>
                    isBack ? Get.back() : appCtrl.splashDataCheck());
          });
    }
    update();
  }

  // Stripe Create payment Method
  createPaymentIntent(String amount, String currency) async {


    try {
      Map<String, dynamic> body = {
        'amount':  calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${appCtrl.firebaseConfigModel!.stripeKey}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      log("RES STRIPE ${jsonDecode(response.body)}");
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("");
    }
  }

  // Stripe amount calculate
  calculateAmount(String amount) {
    double? convertPrice = double.parse(amount);
    /*if (appCtrl.priceSymbol == "\$") {
      convertPrice = (82.55 * double.parse(amount));
    }else if(appCtrl.priceSymbol == "€"){
      convertPrice = (88.69 * double.parse(amount));
    }else if(appCtrl.priceSymbol == "₹"){
      convertPrice = (1 * double.parse(amount));
    }else if(appCtrl.priceSymbol == "£"){
      convertPrice = (103.02 * double.parse(amount));
    }*/
    log("convertPrice : ${int.parse(convertPrice!.floor().toString()) * 100}");
    final a = (int.parse(convertPrice.floor().toString()) * 100);
    log("a :n$a");
    return a.toString();
  }

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };

  // Paypal Order create method
  Map<String, dynamic> getOrderParams(String data) {
    List items = [
      {
        "name": itemName,
        "quantity": quantity,
        "price": data,
        "currency": defaultCurrency["currency"]
      }
    ];

    // checkout invoice details
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = 'Gulshan';
    String userLastName = 'Yadav';
    String addressCity = 'Delhi';
    String addressStreet = 'Mathura Road';
    String addressZipCode = '110014';
    String addressCountry = 'India';
    String addressState = 'Delhi';
    String addressPhoneNumber = '+919990119091';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": data,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": data,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (isEnableShipping && isEnableAddress)
              "shipping_address": {
                "recipient_name": "$userFirstName $userLastName",
                "line1": addressStreet,
                "line2": "",
                "city": addressCity,
                "country_code": addressCountry,
                "postal_code": addressZipCode,
                "phone": addressPhoneNumber,
                "state": addressState
              }
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  onPaypalPayment({required String amount, SubscribeModel? subscribe}) async {
    try {
      final transactions = getOrderParams(amount);

      final res = await services.createPaypalPayment(transactions, accessToken);

      checkoutUrl = res["approvalUrl"];
      executeUrl = res["executeUrl"];
      update();

      Get.to(() => PaypalPayment(
            subscribe: subscribe,
            amount: int.parse(amount),
            url: checkoutUrl,
            exUrl: executeUrl,
          ));
    } catch (e) {
      showDialog(
          barrierDismissible: false,
          context: Get.context!,
          builder: (context) {
            return AlertDialogCommon(
                image: eImageAssets.paymentFailed,
                bText1: appFonts.tryAgain,
                title: appFonts.paymentFailed,
                subtext: appFonts.oppsDueTo,
                b1OnTap: () => isBack ? Get.back() : appCtrl.splashDataCheck(),
                crossOnTap: () =>
                    isBack ? Get.back() : appCtrl.splashDataCheck());
          });
    }

    update();
  }

  initPayment() {
    /// Test payment gateway
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);

    ///
  }

  // Razorpay error response
  void handlePaymentErrorResponse() {
    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) {
          return AlertDialogCommon(
              image: eImageAssets.paymentFailed,
              bText1: appFonts.tryAgain,
              title: appFonts.paymentFailed,
              subtext: appFonts.oppsDueTo,
              b1OnTap: () => isBack ? Get.back() : appCtrl.splashDataCheck(),
              crossOnTap: () =>
                  isBack ? Get.back() : appCtrl.splashDataCheck());
        });
  }

  // Razorpay success response
  handlePaymentSuccessResponse({SubscribeModel? subscribeModel}) {
    showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) {
          return AlertDialogCommon(
              image: eImageAssets.paymentSuccess,
              bText1: appFonts.okay,
              title: appFonts.paymentSuccess,
              subtext: appFonts.congratulation,
              b1OnTap: () {
                final firebaseCtrl =
                    Get.isRegistered<SubscriptionFirebaseController>()
                        ? Get.find<SubscriptionFirebaseController>()
                        : Get.put(SubscriptionFirebaseController());
                firebaseCtrl.subscribePlan(
                    subscribeModel: subscribeModel,
                    paymentMethod: "razor",
                    isBack: isBack);
              },
              crossOnTap: isBack
                  ? () {
                      final firebaseCtrl =
                          Get.isRegistered<SubscriptionFirebaseController>()
                              ? Get.find<SubscriptionFirebaseController>()
                              : Get.put(SubscriptionFirebaseController());
                      firebaseCtrl.subscribePlan(
                          subscribeModel: subscribeModel,
                          paymentMethod: "razor",
                          isBack: isBack);
                    }
                  : () => appCtrl.splashDataCheck());
        });
  }

  onPayPlan() {
    var userName = appCtrl.storage.read("userName");
    log("SELECTED PRICE $finalPrice");
    if (userName != null) {
      var argData = {
        "price": finalPrice,
        "plan": finalPlan,
      };
      paymentDialog(selectedPrice, subscribeModel,argData);
      update();
    } else {
      Get.offAllNamed(routeName.loginScreen);
    }
    update();
  }

  onSelectPlan(key, value) {
    selectedPlan = key;
    selectedPrice = value.data()["price"];
    planType = value.data()["planType"];
    finalPlan = planType;
    finalPrice = selectedPrice;
    subscribeModel = SubscribeModel.fromJson(value.data());
    update();
  }

  onTapPlan(value) {
    selectedPrice = value.data()["price"];
    subscribeModel = SubscribeModel.fromJson(value.data());
    log("SELECTED PRICE PLAN $selectedPrice");
    var argData = {
      "price": finalPrice,
      "plan": finalPlan,
    };
    paymentDialog(selectedPrice.toString(), subscribeModel,argData);
    update();
  }

  @override
  void onReady() async {
    isBack = Get.arguments ?? true;
    paymentMethods = appArray.paymentMethodList;
    subscriptionLists = appArray.subscriptionPlan
        .map((e) => SubscribeModel.fromJson(e))
        .toList();
    currencyList = appArray.currencyList;
    dynamic arg = appCtrl.storage.read("currency") ?? appArray.currencyList[0];
    if (arg["title"] == "dollar") {
      selectIndex = 0;
    } else if (arg["title"] == "euro") {
      selectIndex = 1;
    } else if (arg["title"] == "inr") {
      selectIndex = 2;
    } else {
      selectIndex = 3;
    }

    Future.delayed(Duration.zero, () async {
      // Paypal Payment Method
      try {
        accessToken = await services.getAccessToken();
      } catch (e) {
        throw Exception("exception: $e");
      }
    });
    initPayment();
    // initPayment();
    /* onPaypal(onFinish);*/
    update();
    // TODO: implement onReady
    super.onReady();
  }

  final Razorpay _razorpay = Razorpay(); //Instance of razor pay

  openSession({SubscribeModel? subscribe}) {
    createOrder().then((orderId) {
      if (orderId.toString().isNotEmpty) {
        var options = {
          'key': appCtrl.firebaseConfigModel!.razorPayKey!,
          //Razor pay API Key
          "subscription_id": "sub_LVj2COfX915tfr",
          //in the smallest currency sub-unit.
          'name': 'Company Name.',
          "recurring": true,
          "confirm_close": true,
          'order_id': orderId,
          // Generate order_id using Orders API
          'description': 'Description for order',
          //Order Description to be shown in razor pay page
          'timeout': 360,
          // in seconds
          'prefill': {
            'contact': '9123456789',
            'email': 'flutterwings304@gmail.com'
          }
          //contact number and email id of user
        };
        _razorpay.open(options);
        razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
        razorpay.on(
            Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      } else {
        log("EERRR");
      }
    });
  }

  // payments list
  paymentDialog(data, subscribe,argData) {
    if (appCtrl.isGuestLogin) {
      Get.offAllNamed(routeName.signInScreen);
    } else {
      Get.generalDialog(
        barrierDismissible: false,
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.center,
            child: PaymentList(
              argData: argData,
              data: data!.toString(),
              subscribe: subscribe,
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    }
  }

  //currency list
  currencyListDialog() {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return const Align(
          alignment: Alignment.center,
          child: CurrencyList(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
