import 'package:firebase_auth/firebase_auth.dart';

import '../../config.dart';
import '../../widgets/scaffold_messenger.dart';

class SignUpController extends GetxController {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> signUpGlobalKey = GlobalKey<FormState>();

  String? firebaseUser = '';

  bool obscureText = true;
  bool obscureText2 = true;

  onObscure() {
    obscureText = !obscureText;
    update();
  }
  onObscure2() {
    obscureText2 = !obscureText2;
    update();
  }

  // Firebase Register With Email & Password
  signUpMethod() async {
    if (signUpGlobalKey.currentState!.validate()) {
      isLoading = true;
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passwordController.text.toString());
        var user = FirebaseAuth.instance.currentUser;
        firebaseUser = user?.email;
        update();
        isLoading = false;
        emailController.text = "";
        passwordController.text = "";
        appCtrl.storage.write("firebaseUser", firebaseUser);
        Get.offAllNamed(routeName.signInScreen);
      } on FirebaseAuthException catch (e) {
        if (e.code == "email-already-in-use") {
          isLoading = false;
          snackBarMessengers(message: appFonts.emailAlreadyUse.tr);
        }
      } catch (e) {
        isLoading = false;
        snackBarMessengers(message: appFonts.unknownError.tr);
      }
    }
  }
}
