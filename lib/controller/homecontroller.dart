// import 'package:gadget_mtaa/consts/consts.dart';
// import 'package:get/get.dart';

// class HomeController extends GetxController {
//   @override
//   void onInit() {
//     getusername();
//     super.onInit();
//   }

//   var currentNavIndex = 0.obs;
//   var name = "";
//   var searchcontroller = TextEditingController();

//   getusername() async {
//     var n = await firestore1
//         .collection(usercollection)
//         .where('id', isEqualTo: currentuser!.uid)
//         .get()
//         .then((value) {
//       if (value.docs.isNotEmpty) {
//         return value.docs.single['name'];
//       }
//     });
//     name = n;
//   }
// }

import 'package:gadget_mtaa/consts/consts.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    getusername();
    super.onInit();
  }

  var currentNavIndex = 0.obs;
  var name = "".obs; // Use RxString for reactive updates
  var searchcontroller = TextEditingController();

  Future<void> getusername() async {
    // Try to fetch the username from Firestore
    var n = await firestore1
        .collection(usercollection)
        .where('id', isEqualTo: currentuser!.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return value.docs.single['name'] as String?;
      }
      return null; // Explicitly return null if no document is found
    });

    // Assign a default value if `n` is null
    name.value = n ?? 'Guest User';
  }
}
