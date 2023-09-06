import '../../../../config.dart';

class AfterSubscribe extends StatelessWidget {
  const AfterSubscribe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("plans")
          .orderBy("price", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("userSubscribe")
                  .where("email", isEqualTo: appCtrl.storage.read("userName"))
                  .limit(1)
                  .snapshots(),
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  if (snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...snapshot.data!.docs.asMap().entries.map((e) {
                          return SubscribePlanUI(
                              snapShot: snapShot, data: e.value.data());
                        }).toList()
                      ],
                    ).marginSymmetric(horizontal: Insets.i10);
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              });
        } else {
          return Container();
        }
      },
    );
  }
}
