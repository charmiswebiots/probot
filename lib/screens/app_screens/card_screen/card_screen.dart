import 'package:flutter/services.dart';
import 'package:probot/controllers/app_pages_controllers/card_controller.dart';
import '../../../config.dart';
import '../../../utils/text_input_formatter.dart';

class CardScreen extends StatelessWidget {
  final SubscribeModel? subscribeModel;

  final cardCtrl = Get.put(CardController());

  CardScreen({super.key, this.subscribeModel});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CardController>(builder: (_) {
      return Scaffold(
          appBar: AppAppBarCommon(
              title: "Make Payment",
              isBalanceShow: false,
              leadingOnTap: () => Get.back()),
          body: SingleChildScrollView(
            child: Stack(
              children: [
                SizedBox(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("Plan Details",
                          style: AppCss.outfitSemiBold18
                              .textColor(appCtrl.appTheme.darkText))
                      .alignment(Alignment.centerLeft),
                  const VSpace(Sizes.s10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cardCtrl.plan,
                            style: AppCss.outfitMedium16
                                .textColor(appCtrl.appTheme.darkText)),
                        Text("${appCtrl.priceSymbol} ${cardCtrl.price.toString()}",
                            style: AppCss.outfitMedium16
                                .textColor(appCtrl.appTheme.darkText))
                      ]),
                  const VSpace(Sizes.s30),
                  Form(
                      key: cardCtrl.globalKey,
                      child: Column(children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Card Number",
                                  style: AppCss.outfitSemiBold14
                                      .textColor(appCtrl.appTheme.darkText)),
                              const VSpace(Sizes.s10),
                              TextFieldCommon(
                                  suffixIcon:
                                      CardUtils.getCardIcon(cardCtrl.cardType),
                                  controller: cardCtrl.cardNumberController,
                                  keyboardType: TextInputType.number,
                                  validator: CardUtils.validateCardNum,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(16),
                                    CardNumberInputFormatter()
                                  ],
                                  hintText: 'Card Number')
                            ]),
                        const VSpace(Sizes.s25),
                        IntrinsicHeight(
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                  Text("CVV",
                                      style: AppCss.outfitSemiBold14
                                          .textColor(appCtrl.appTheme.darkText)),
                                  const VSpace(Sizes.s10),
                                  TextFieldCommon(
                                      controller: cardCtrl.cvvController,
                                      keyboardType: TextInputType.number,
                                      validator: CardUtils.validateCVV,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        // Limit the input
                                        LengthLimitingTextInputFormatter(4)
                                      ],
                                      hintText: 'CVV')
                                ])),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                  Text("Expiry Month",
                                      style: AppCss.outfitSemiBold14
                                          .textColor(appCtrl.appTheme.darkText)),
                                  const VSpace(Sizes.s10),
                                  TextFieldCommon(
                                      controller: cardCtrl.monthController,
                                      keyboardType: TextInputType.number,
                                      validator: CardUtils.validateDate,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4),
                                        CardMonthInputFormatter()
                                      ],
                                      hintText: 'MM/YY')
                                ]))
                          ]),
                        ),
                        const VSpace(Sizes.s40),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(Sizes.s55, Sizes.s43)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  cardCtrl.isLoading ?
                                  SizedBox(
                                      height: Sizes.s30,
                                      width: Sizes.s30,
                                      child: CircularProgressIndicator(strokeWidth: 3,color: appCtrl.appTheme.sameWhite,)
                                          .paddingAll(Insets.i5)):
                                  Icon(Icons.lock_outlined,
                                      color: appCtrl.appTheme.sameWhite,
                                      size: Sizes.s20),
                                  const HSpace(Sizes.s5),
                                  Text("Subscribe",
                                      style: AppCss.outfitSemiBold16
                                          .textColor(appCtrl.appTheme.sameWhite))
                                ]),
                            onPressed: () {
                              if (cardCtrl.globalKey.currentState!.validate()) {
                                cardCtrl.subscriptions(
                                    paymentMethod: "stripe",
                                    subscribe: subscribeModel,
                                    priceId: subscribeModel?.planId);
                              }
                            })
                      ]))
                ]).paddingAll(Insets.i20))
                    .authBoxExtension()
                    .paddingAll(Insets.i20)
              ],
            ),
          ));
    });
  }
}
