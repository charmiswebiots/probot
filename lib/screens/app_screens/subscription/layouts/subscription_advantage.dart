import '../../../../config.dart';

class SubscriptionAdvantage extends StatelessWidget {
  const SubscriptionAdvantage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(builder: (subscribeCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("planAdvantage")
              .snapshots(),
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              return  TableCommon(snapShot: snapShot);
            } else {
              return Container();
            }
          });
    });
  }
}
