import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import '../config.dart';

class CommonStream extends StatelessWidget {
  final Widget? child;

  const CommonStream({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("config").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {

              appCtrl.commonThemeChange();
              appCtrl.firebaseConfigModel =
                  FirebaseConfigModel.fromJson(snapshot.data!.docs[0].data());
              Stripe.publishableKey =
              appCtrl.firebaseConfigModel!.stripePublishKey!;
              appCtrl.storage
                  .write(session.firebaseConfig, snapshot.data!.docs[0].data());
            }
          }
          return child!;
        });
  }
}
