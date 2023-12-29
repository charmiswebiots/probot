import '../../../../config.dart';

class RowCommon extends StatelessWidget {
  final String? title;

  const RowCommon({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.circle, size: Sizes.s3, color: appCtrl.appTheme.txt),
      const HSpace(Sizes.s8),
      Expanded(
          child: Text(title!.toString().tr,
              style: AppCss.outfitLight14.textColor(appCtrl.appTheme.txt)))
    ]);
  }
}
