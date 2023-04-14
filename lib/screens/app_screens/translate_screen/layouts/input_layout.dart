import 'package:probot/screens/app_screens/translate_screen/layouts/svg_icon_common.dart';
import '../../../../config.dart';

class InputLayout extends StatelessWidget {
  final String? title, hintText;
  final TextEditingController? controller;
  final bool? isMax;
  final GestureTapCallback? onTap;
  final Color? color,txtColor;
  final int? maxLine;

  const InputLayout(
      {Key? key,
      this.title,
      this.controller,
      this.isMax,
      this.hintText,
      this.onTap,this.color,this.txtColor,this.maxLine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title!.toString().tr,
            style: AppCss.outfitSemiBold14.textColor(txtColor ?? appCtrl.appTheme.txt)),
        if (isMax == true) SvgIconsCommon(icon: eSvgAssets.microphone),
        if (isMax != true)
          Row(children: [
            SvgIconsCommon(icon: eSvgAssets.volume),
            SvgIconsCommon(icon: eSvgAssets.share)
                .paddingSymmetric(horizontal: Insets.i10),
            SvgIconsCommon(icon: eSvgAssets.copy)
          ])
      ]),
      const VSpace(Sizes.s10),
      Stack(alignment: Alignment.bottomRight, children: [
        SizedBox(
                child: TextFieldCommon(
                    controller: controller!,
                    hintText: hintText ?? appFonts.writeAnything,
                    minLines: 8,
                    maxLines: maxLine ?? 100,
                    fillColor: color ?? appCtrl.appTheme.textField,
                    keyboardType: TextInputType.multiline))
            .authBoxExtension(),
        if (isMax == true)
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SvgPicture.asset(eSvgAssets.cancel,
                    colorFilter: ColorFilter.mode(
                        appCtrl.appTheme.lightText, BlendMode.srcIn))
                .paddingSymmetric(horizontal: Insets.i10)
                .inkWell(onTap: onTap),
            VSpace(MediaQuery.of(context).size.height * 0.09),
            Text(appFonts.max50.tr,
                    style: AppCss.outfitMedium12
                        .textColor(appCtrl.appTheme.lightText))
                .paddingAll(Insets.i10)
          ])
      ])
    ]);
  }
}