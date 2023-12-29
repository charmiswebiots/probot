import 'dart:convert';
import 'dart:developer';

import '../../config.dart';
import 'package:http/http.dart' as http;

class CardController extends GetxController {

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController monthController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final client = http.Client();
 bool isBack = true;
  CardType cardType = CardType.Invalid;
 bool isLoading = false;
 int price = 0;
 String plan = '';
  Map<String, String> headers = {
    'Authorization': 'Bearer ${appCtrl.firebaseConfigModel!.stripeKey}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  Future<Map<String, dynamic>> createSubscriptions(String customerId, String priceId) async {
    const String url = 'https://api.stripe.com/v1/subscriptions';

    Map<String, dynamic> body = {
      'customer': customerId,
      'items[0][price]': priceId,

    };

    var response = await client.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      log("SUBSCRIPTION RES ${json.decode(response.body)}");
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a subscriber.';
    }
  }

  Future<Map<String, dynamic>> createCustomer() async {


    const String url = 'https://api.stripe.com/v1/customers';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'description': 'new customer'
      },
    );
    if (response.statusCode == 200) {
      log("RESPONSE ${json.decode(response.body)['id']}");
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a customer.';
    }
  }


  Future<Map<String, dynamic>> createPaymentMethod() async {
    const String url = 'https://api.stripe.com/v1/payment_methods';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'type': 'card',
        'card[number]': cardNumberController.text,
        'card[exp_month]': monthController.text.substring(0,2),
        'card[exp_year]': monthController.text.substring(3,5),
        'card[cvc]': cvvController.text,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      return json.decode(response.body);
    }
  }


  Future<Map<String, dynamic>> attachPaymentMethod(String paymentMethodId, String customerId) async {
    final String url = 'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'customer': customerId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to attach PaymentMethod.';
    }
  }

  Future<Map<String, dynamic>> updateCustomer(
      String paymentMethodId, String customerId) async {
    final String url = 'https://api.stripe.com/v1/customers/$customerId';

    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'invoice_settings[default_payment_method]': paymentMethodId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to update Customer.';
    }
  }


  Future<void> subscriptions({subscribe,paymentMethod,priceId}) async {
    isLoading = true;
    update();
    final _customer = await createCustomer();
    isLoading = true;
    update();
    final _paymentMethod = await createPaymentMethod();
    log("_paymentMethod :: $_paymentMethod");
    if(_paymentMethod["error"] == null) {
      await attachPaymentMethod(_paymentMethod['id'], _customer['id']);
      isLoading = true;
      update();
      await updateCustomer(_paymentMethod['id'], _customer['id']);
      isLoading = true;
      update();
      final invoice = await createSubscriptions(_customer['id'],priceId);
      log("INVOICE ID ${invoice["latest_invoice"]}");
      isLoading = true;
      update();
      final invoiceRes = await invoicePay(
          invoice["latest_invoice"], _paymentMethod['id']);
      log("invoiceRes ${invoiceRes["subscription"]}");
      log("_paymentMethod ${_paymentMethod["id"]}");
      isLoading = false;
      update();
      if (invoiceRes["subscription"] != null) {
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
                        subscriptionId: invoiceRes["subscription"],
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
                        subscriptionId: invoiceRes["subscription"],
                        isBack: isBack);
                  }
                      : () => appCtrl.splashDataCheck());
            });
      } else {
        isLoading = false;
        update();
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
    } else {
      isLoading = false;
      update();
      snackBarMessengers(message: _paymentMethod["error"]["message"]);
    }
  }
  Future<Map<String, dynamic>>  invoicePay(String invoiceId, String paymentMethodId) async{
    String url = 'https://api.stripe.com/v1/invoices/$invoiceId/pay';
    var response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'payment_method': paymentMethodId
      },
    );
    if (response.statusCode == 200) {
      log("RESPONSE INVOICE ${json.decode(response.body)}");
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to open invoice';
    }
  }

  void getCardTypeFrmNumber() {
    if (cardNumberController.text.length <= 6) {
      String input = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardTypeFrmNumber(input);
      if (type != cardType) {
          cardType = type;
          update();
      }
    }
  }

  @override
  void onReady() {
      var data = Get.arguments;
      price = data["price"] ?? 0;
      plan = data["plan"] ?? '';
    log("ARG DATA ${Get.arguments}");

    cardNumberController.addListener(() {getCardTypeFrmNumber();});
    monthController.addListener(() {getCardTypeFrmNumber();});
    cvvController.addListener(() {getCardTypeFrmNumber();});

    update();
    // TODO: implement onReady
    super.onReady();
  }

}
