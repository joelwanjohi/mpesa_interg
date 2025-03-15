import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gadget_mtaa/consts/consts.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  var totalprice = 0.obs; // Observable for total price
  var cartCollection = FirebaseFirestore.instance.collection('cart');

  // Calculate total price based on the price and quantity
  void calculateTotalPrice(List<dynamic> items) {
    totalprice.value = 0;
    for (var item in items) {
      var qty = item['qty'] ?? 1; // Default to 1 if qty is null
      var price = item['price'] ?? 0; // Default to 0 if price is null
      totalprice.value += (price as int) * (qty as int);
    }
  }

  // Add a product to the user's cart
  Future<void> addToCart({
    required String productId,
    required String title,
    required String image,
    required int price,
    required int qty,
  }) async {
    var uid = currentuser!.uid; // Assuming you have the current user's ID

    try {
      final userCartDoc = cartCollection.doc(uid);

      // Get existing cart data
      var cartSnapshot = await userCartDoc.get();
      var cartData = cartSnapshot.exists ? cartSnapshot.data() : {};

      List<dynamic> items = cartData?['items'] ?? [];

      // Check if the product already exists in the cart
      bool productExists = items.any((item) => item['productID'] == productId);
      if (productExists) {
        // If it exists, update the quantity
        items = items.map((item) {
          if (item['productID'] == productId) {
            item['qty'] += qty; // Increase quantity
          }
          return item;
        }).toList();
      } else {
        // If not, add the new product to the cart items
        items.add({
          'productID': productId,
          'title': title,
          'image': image,
          'price': price,
          'qty': qty
        });
      }

      // Calculate the new total price
      calculateTotalPrice(items);

      // Update the user's cart with the new product
      await userCartDoc.set({
        'items': items,
        'total_price': totalprice.value,
      }, SetOptions(merge: true));

      Get.snackbar('Success', 'Product added to cart');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product to cart: $e');
    }
  }

  // Remove a product from the user's cart
  Future<void> removeFromCart(String productId) async {
    var uid = currentuser!.uid;
    final userCartDoc = cartCollection.doc(uid);

    try {
      var cartSnapshot = await userCartDoc.get();
      var cartData = cartSnapshot.data();

      List<dynamic> items = cartData?['items'] ?? [];

      // Remove the product by filtering out the product with the given ID
      items = items.where((item) => item['productID'] != productId).toList();

      // Calculate the new total price
      calculateTotalPrice(items);

      // Update the user's cart
      await userCartDoc.set({
        'items': items,
        'total_price': totalprice.value,
      }, SetOptions(merge: true));

      Get.snackbar('Success', 'Product removed from cart');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove product from cart: $e');
    }
  }
}

//cart_controller.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:gadget_mtaa/consts/consts.dart';
// import 'package:get/get.dart';

// class CartController extends GetxController {
//   var totalprice = 0.0.obs; // Observable for total price
//   var cartCollection = FirebaseFirestore.instance.collection('cart');

//   // Calculate total price based on the price and quantity
//   void calculateTotalPrice(List<dynamic> items) {
//     totalprice.value = 0;
//     for (var item in items) {
//       var qty = item['qty'] ?? 1; // Default to 1 if qty is null
//       var price = item['price'] ?? 0; // Default to 0 if price is null
//       totalprice.value += (price as num) * (qty as num);
//     }
//   }

//   // Add a product to the user's cart
//   Future<void> addToCart({
//     required String productId,
//     required String title,
//     required String image,
//     required int price,
//     required int qty,
//   }) async {
//     var uid = currentuser!.uid;
//     try {
//       final userCartDoc = cartCollection.doc(uid);
//       var cartSnapshot = await userCartDoc.get();
//       var cartData = cartSnapshot.data() ?? {'items': []};

//       List<dynamic> items = cartData['items'] ?? [];
//       bool productExists = items.any((item) => item['productID'] == productId);

//       if (productExists) {
//         items = items.map((item) {
//           if (item['productID'] == productId) {
//             item['qty'] = (item['qty'] as int) + qty;
//           }
//           return item;
//         }).toList();
//       } else {
//         items.add({
//           'productID': productId,
//           'title': title,
//           'image': image,
//           'price': price,
//           'qty': qty,
//         });
//       }

//       calculateTotalPrice(items);

//       await userCartDoc.set({
//         'items': items,
//         'total_price': totalprice.value,
//       }, SetOptions(merge: true));

//       Get.snackbar('Success', 'Product added to cart');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to add product to cart: $e');
//     }
//   }

//   // Remove a product from the user's cart
//   Future<void> removeFromCart(String productId) async {
//     var uid = currentuser!.uid;
//     final userCartDoc = cartCollection.doc(uid);
//     try {
//       var cartSnapshot = await userCartDoc.get();
//       var cartData = cartSnapshot.data();
//       List<dynamic> items = cartData?['items'] ?? [];

//       // Remove the product by filtering out the product with the given ID
//       items = items.where((item) => item['productID'] != productId).toList();

//       calculateTotalPrice(items);

//       await userCartDoc.set({
//         'items': items,
//         'total_price': totalprice.value,
//       }, SetOptions(merge: true));

//       Get.snackbar('Success', 'Product removed from cart');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to remove product from cart: $e');
//     }
//   }

//   // Clear the entire cart
//   Future<void> clearCart() async {
//     var uid = currentuser!.uid;
//     final userCartDoc = cartCollection.doc(uid);
//     try {
//       await userCartDoc.set({
//         'items': [],
//         'total_price': 0.0,
//       });
//       Get.snackbar('Success', 'Cart cleared');
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to clear cart: $e');
//     }
//   }

//   // Format price as a string
//   String formatPrice(num price) {
//     return "\$${price.toStringAsFixed(2)}";
//   }
// }
