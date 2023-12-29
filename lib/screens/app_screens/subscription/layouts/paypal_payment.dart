import 'dart:core';
import 'dart:developer';

import '../../../../config.dart';

class PaypalPayment extends StatefulWidget {
  final SubscribeModel? subscribe;
  final int? amount;
  final String? url, exUrl;
  final bool isSubscribe;

  const PaypalPayment(
      {Key? key,
      this.subscribe,
      this.amount,
      this.url,
      this.isSubscribe = true,
      this.exUrl})
      : super(key: key);

  @override
  State<PaypalPayment> createState() => _PaypalPaymentState();
}

class _PaypalPaymentState extends State<PaypalPayment> {
  final subscribeCtrl = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());
  final topUpCtrl = Get.isRegistered<TopUpController>()
      ? Get.find<TopUpController>()
      : Get.put(TopUpController());

  PaypalServices services = PaypalServices();

  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url!))
      ..setNavigationDelegate(
          NavigationDelegate(onNavigationRequest: (NavigationRequest request) {
        log("Request: ${request.url}");
        if (request.url.contains(widget.isSubscribe ? subscribeCtrl.returnURL : topUpCtrl.returnURL)) {
          final uri = Uri.parse(request.url);
          log("URI: $uri");

          final payerID = uri.queryParameters['PayerID'];
          log("payerID: $payerID");
          if (payerID != null) {
            services
                .executePayment(
                    widget.exUrl, payerID,widget.isSubscribe ? subscribeCtrl.accessToken : topUpCtrl.accessToken)
                .then((id) {
              log("Pay Id: $id");
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
                              subscribeModel: widget.subscribe,
                              paymentMethod: "payPal",
                              amountBalance: widget.amount,
                              isSubscribe: widget.isSubscribe,
                              isBack: true);
                        },
                        crossOnTap: () async {
                          final firebaseCtrl =
                          Get.isRegistered<SubscriptionFirebaseController>()
                              ? Get.find<SubscriptionFirebaseController>()
                              : Get.put(SubscriptionFirebaseController());
                          firebaseCtrl.subscribePlan(
                              subscribeModel: widget.subscribe,
                              paymentMethod: "payPal",
                              amountBalance: widget.amount,
                              isSubscribe: widget.isSubscribe,
                              isBack: true);
                        },);
                  });
            });
            Get.back();
          } else {
            showDialog(
                barrierDismissible: false,
                context: Get.context!,
                builder: (context) {
                  return AlertDialogCommon(
                      image: eImageAssets.paymentFailed,
                      bText1: appFonts.tryAgain,
                      title: appFonts.paymentFailed,
                      subtext: appFonts.oppsDueTo,
                      b1OnTap: () => Get.back(),
                      crossOnTap: () => Get.back());
                });
          }
        } else {
          log("Something went wrong");
        }
        if (request.url.contains(widget.isSubscribe ? subscribeCtrl.cancelURL : topUpCtrl.cancelURL)) {
          Get.back();
        }
        return NavigationDecision.navigate;
      }));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url != null) {
      return GetBuilder<SubscriptionController>(builder: (context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: appCtrl.appTheme.primary,
                leading: const BackButton()),
            // Start payment process
            body: WebViewWidget(controller: controller));
      });
    } else {
      return Scaffold(
          appBar: AppBar(
              leading: const BackButton(),
              backgroundColor: appCtrl.appTheme.white,
              elevation: 0.0),
          body: const Center(child: CircularProgressIndicator()));
    }
  }
}
