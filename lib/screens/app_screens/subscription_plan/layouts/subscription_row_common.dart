import '../../../../config.dart';

class CommonRow extends StatelessWidget {
  final String? title, price;
  final Color? color;

  const CommonRow({Key? key, this.title, this.price,this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title!.toString().tr,
          style: AppCss.outfitRegular12.textColor(color ?? appCtrl.appTheme.lightText)),
      Text(price!,
          style: AppCss.outfitSemiBold12.textColor( color ?? appCtrl.appTheme.txt))
    ]);
  }
}
