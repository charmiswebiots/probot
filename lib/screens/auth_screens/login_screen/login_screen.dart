import 'package:probot/widgets/button_common.dart';
import '../../../config.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Column( children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
                    height: Sizes.s450,
                    width: double.infinity,
                    child: Image.asset(eImageAssets.lBg, fit: BoxFit.cover))
                .decorated(
                    gradient: RadialGradient(
                        focalRadius: 1,
                        radius: 1,
                        colors: [
                          appCtrl.appTheme.primary,
                          appCtrl.appTheme.radialGradient
                        ],
                        center: const Alignment(-0.1, 0.1))),
            Image.asset(eImageAssets.loginBot,width: Sizes.s335).paddingOnly(bottom: Insets.i35)
          ]
        ),
        const VSpace(Sizes.s20),
        Column(children: [
          IntrinsicHeight(
              child: Row(children: [
            VerticalDivider(
                    thickness: 4, width: 1, color: appCtrl.appTheme.primary)
                .backgroundColor(appCtrl.appTheme.error),
            const HSpace(Sizes.s12),
            SizedBox(
                width: Sizes.s300,
                child: Text(appFonts.fastResponse,
                    style: AppCss.outfitSemiBold22
                        .textColor(appCtrl.appTheme.txt)
                        .textHeight(1.3)))
          ])),
          const VSpace(Sizes.s20),
          Text(appFonts.aBuddyWhoAvailable,
              style: AppCss.outfitMedium16
                  .textColor(appCtrl.appTheme.lightText)
                  .textHeight(1.3)),
          const VSpace(Sizes.s40),
          Row(children: [
            Expanded(child: ButtonCommon(title: appFonts.signUp)),
            const HSpace(Sizes.s15),
            Expanded(child: ButtonCommon(title: appFonts.signIn,onTap: ()=> Get.toNamed(routeName.signInScreen),))
          ]),
          SizedBox(
              width: Sizes.s90,
              child: Row(children: [
                const Expanded(child: Divider(height: 1, thickness: 2)),
                Text(appFonts.or,
                        style: AppCss.outfitMedium14
                            .textColor(appCtrl.appTheme.lightText))
                    .paddingSymmetric(horizontal: Insets.i5),
                const Expanded(child: Divider(height: 1, thickness: 2))
              ])).paddingSymmetric(vertical: Insets.i20),
          Text(appFonts.continueAsAGuest,
              style: AppCss.outfitMedium16.textColor(appCtrl.appTheme.primary))
        ]).paddingSymmetric(horizontal: Insets.i20)
      ]).paddingOnly(bottom: Insets.i10)
    );
  }
}
