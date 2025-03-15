import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:gadget_mtaa/consts/consts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  var profilepath = "".obs;
  var namecontroller = TextEditingController();
  var oldpasscontroller = TextEditingController();
  var newpasscontroller = TextEditingController();
  var proflink = "";
  var isloading = false.obs;

  changeImage(context) async {
    try {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (img == null) return;
      profilepath.value = img.path;
    } on PlatformException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  uploadprofile(context) async {
    var destination = 'images?${currentuser!.uid}';
    Reference ref = FirebaseStorage.instance.ref().child(destination);
    await ref.putFile(File(profilepath.value));
    proflink = await ref.getDownloadURL();
  }

  updateProfile({name, password, imgurl}) async {
    var store = firestore1.collection(usercollection).doc(currentuser!.uid);
    await store.set({
      'name': name,
      'password': password,
      'imgurl': imgurl,
    }, SetOptions(merge: true));
    isloading(false);
  }

  changeauthpass({email, password, newpassword}) async {
    final cred = EmailAuthProvider.credential(email: email, password: password);
    await currentuser!.reauthenticateWithCredential(cred).then((value) {
      currentuser!.updatePassword(newpassword);
    }).catchError((error) {
      print(error.toString());
    });
  }
}
