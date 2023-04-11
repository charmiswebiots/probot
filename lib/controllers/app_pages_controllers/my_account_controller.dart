import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../config.dart';
import '../../screens/app_screens/my_account_screen/layouts/delete_account_alert.dart';
import '../../screens/app_screens/my_account_screen/layouts/image_picker.dart';

class MyAccountController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  XFile? imageFile;
  bool isLoading = false;
  String? name, userName, firebaseUser, number, image;
  String? id;

  deleteAccount() async {
    try {
      /* FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
*/
      Get.offAllNamed(routeName.loginScreen);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("chats")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          value.docs.asMap().entries.forEach((element) {
            if (element.value.data()["chatId"] != null) {
              FirebaseFirestore.instance
                  .collection("chatHistory")
                  .doc(element.value.data()["chatId"])
                  .delete();
            }
          });
        }
      }).then((value) async {
        Get.offAllNamed(routeName.loginScreen);
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .delete();
      });

      await FirebaseAuth.instance.currentUser!.delete().then(
          (value) => Fluttertoast.showToast(msg: 'Delete User Successfully'));

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        log('The user must reauthenticate before this operation can be executed.');
      }
    }
  }


  //delete chat layout
  Widget buildPopupDialog() {
    return const DeleteAlert();
  }

  onUpdate() {
    log("id: $id");
    FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        if (value.docs[0].data()["logintype"] == "Number") {
          FirebaseFirestore.instance
              .collection('users')
              .doc(value.docs[0].id)
              .update({
            'nickname': firstNameController.text,
            "email": emailController.text
          });
        } else {
          FirebaseFirestore.instance
              .collection('users')
              .doc(value.docs[0].id)
              .update({
            'nickname': firstNameController.text,
            "phone": numberController.text
          });
        }
      }
    }).then((value) => Fluttertoast.showToast(msg: 'Data Upload Successfully'));
  }

  @override
  void onReady() {
    id = appCtrl.storage.read("id") ?? '';
    numberController.text = appCtrl.storage.read("number") ?? "";
    number = numberController.text;
    emailController.text = appCtrl.storage.read("userName");
    userName = emailController.text;
    firstNameController.text = appCtrl.storage.read("name") ?? "";
    name = firstNameController.text;

    // firebaseUser = appCtrl.storage.read("firebaseUser");
    log("number: $id");
    update();
    // TODO: implement onReady
    super.onReady();
  }

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () {
            getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () {
            getImage(ImageSource.gallery);
            Get.back();
          });
        });
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    log("imageFile : $imageFile");
    if (imageFile != null) {
      update();
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    isLoading = true;
    update();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    log("reference : $reference");
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);

    uploadTask.then((res) {
      log("res : $res");
      res.ref.getDownloadURL().then((downloadUrl) async {
        appCtrl.storage.write("image", downloadUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .update({'image': downloadUrl}).then((value) {});
        isLoading = false;
        update();
        Fluttertoast.showToast(msg: 'Image Upload Successfully');
      }, onError: (err) {
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }
}
