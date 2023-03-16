import '../../../../config.dart';

class ImageLayout extends StatelessWidget {
  final dynamic data;
  final double? height, width;
  final GestureTapCallback? onTap;

  const ImageLayout({Key? key, this.data, this.onTap, this.height, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.r8)),
        child: SizedBox(
                width: width ?? Sizes.s160,
                height: height ?? Sizes.s155,
                child: Image.asset(data["image"], fit: BoxFit.fill))

      ),
      SizedBox(
              child:
                  SvgPicture.asset(eSvgAssets.download).paddingAll(Insets.i8))
          .decorated(
              color: appCtrl.appTheme.txt.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.r8),
                  topRight: Radius.circular(AppRadius.r8)))
          .inkWell(onTap: onTap)
    ]);
  }
}
