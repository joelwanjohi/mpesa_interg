import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gadget_mtaa/consts/consts.dart';
import 'package:gadget_mtaa/controller/homecontroller.dart';
import 'package:get/get.dart';

class ChatsController extends GetxController {
  @override
  void onInit() {
    getchatid();
    super.onInit();
  }

  var isloadind = false.obs;
  var chats = firestore1.collection(chatscollection);
  var friendname = Get.arguments[0];
  var friendid = Get.arguments[1];
  var sendername = Get.find<HomeController>().name;
  var currentid = currentuser!.uid;
  var msgcontroller = TextEditingController();
  dynamic chatdocid;

  getchatid() async {
    isloadind(true);
    await chats
        .where('users', isEqualTo: {
          friendid: null,
          currentid: null,
        })
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            chatdocid = snapshot.docs.single.id;
          } else {
            chats.add({
              'created_on': null,
              'last_msg': '',
              'users': {friendid: null, currentid: null},
              'toid': '',
              'fromid': '',
              'friend_name': friendname,
              'sender_name': sendername,
            }).then((value) {
              chatdocid = value.id;
            });
          }
        });
    isloadind(false);
  }

  sendmsg(String msg) async {
    if (msg.trim().isNotEmpty) {
      chats.doc(chatdocid).update({
        'created_on': FieldValue.serverTimestamp(),
        'last_msg': msg,
        'toid': friendid,
        'fromid': currentid,
      });
      chats.doc(chatdocid).collection(messagescollection).doc().set({
        'created_on': FieldValue.serverTimestamp(),
        'msg': msg,
        'uid': currentid,
      });
    }
  }
}
