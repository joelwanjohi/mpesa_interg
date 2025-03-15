import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gadget_mtaa/consts/consts.dart';
import 'package:get/get.dart';

import '../views/home_screen/home.dart';

class AuthController extends GetxController {
  //login
  Future<UserCredential?> loginMethod({email, password, context}) async {
    UserCredential? userCredential;
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        VxToast.show(context, msg: "loggedin Successfull");
        Get.offAll(() => Home());
      });
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  //signup
  Future<UserCredential?> signupMethod({email, password, context}) async {
    UserCredential? userCredential;
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

//storing data
  storeUserData({name, password, email}) async {
    DocumentReference store =
        firestore1.collection(usercollection).doc(currentuser!.uid);
    store.set({
      "name": name,
      "password": password,
      "email": email,
      "imgurl": "",
      "id": currentuser!.uid,
      "order_count": "00",
      "cart_couunt": "00",
      "whishlist_count": "00"
    });
  }

//signout
  signoutMethod({context}) async {
    try {
      await auth.signOut();
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }
}
