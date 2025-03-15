import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gadget_mtaa/Modals/categorymodal.dart';
import 'package:gadget_mtaa/consts/consts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductController extends GetxController {
  var subcat = [];
  var quantity = 0.obs;
  var colorindex = 0.obs;
  var totalPrice = 0.0.obs;
  var singleItemPrice = 0.0.obs;
  var isfav = false.obs;

  // Fetch categories and subcategories
  getCategories(title) async {
    subcat.clear();
    var data = await rootBundle.loadString('lib/services/category_modal.json');
    var decode = categoryModalFromJson(data);
    var s =
        decode.categories.where((element) => element.name == title).toList();
    for (var e in s[0].subcategories) {
      subcat.add(e);
    }
  }

  var wishlist =
      <String>[].obs; // Use an observable list to store wishlisted product IDs

  // Method to check if a product is wishlisted
  bool isWishlisted(String productId) {
    return wishlist.contains(productId);
  }

  // Method to toggle the wishlist state of a product
  void toggleWishlist(String productId) {
    if (isWishlisted(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }
  }

  // Format price to KES format
  String formatPrice(dynamic price) {
    if (price == null) return 'Sh 0.00';
    final formatter = NumberFormat.currency(
      symbol: 'Sh ',
      decimalDigits: 2,
      locale: 'en_KE',
    );
    return formatter.format(price);
  }

  // Set single item price
  void setSingleItemPrice(dynamic price) {
    if (price is int) {
      singleItemPrice.value = price.toDouble();
    } else if (price is double) {
      singleItemPrice.value = price;
    } else if (price is String) {
      singleItemPrice.value = double.tryParse(price) ?? 0.0;
    } else {
      singleItemPrice.value = 0.0;
    }
    calculateTotalPrice();
  }

  // Calculate total price based on quantity
  void calculateTotalPrice() {
    totalPrice.value = singleItemPrice.value * quantity.value;
  }

  // Increment product quantity
  void incquantity(int stock) {
    if (quantity.value < stock) {
      quantity.value++;
      calculateTotalPrice();
    }
  }

  // Decrement product quantity
  void descquantity() {
    if (quantity.value > 0) {
      quantity.value--;
      calculateTotalPrice();
    }
  }

  // Add product to cart
  Future<void> addtoCart({
    required String img,
    required int qty,
    required String? title,
    required BuildContext context,
  }) async {
    if (qty > 0) {
      try {
        await firestore1.collection(cartcollection).doc().set({
          'title': title,
          'image': img,
          'qty': qty,
          'price': singleItemPrice.value,
          'tprice': totalPrice.value,
          'added_by': currentuser!.uid,
        });
        VxToast.show(context, msg: "Added to cart");
      } catch (error) {
        VxToast.show(context, msg: error.toString());
      }
    } else {
      VxToast.show(context, msg: "Please select quantity");
    }
  }

  // Reset controller values
  void resetvalue() {
    totalPrice.value = 0;
    singleItemPrice.value = 0;
    quantity.value = 0;
    colorindex.value = 0;
  }

  // Handle wishlist operations
  Future<void> addtowhishlist(docid) async {
    await firestore1.collection(productcollection).doc(docid).set({
      'p_whishlist': FieldValue.arrayUnion([currentuser!.uid])
    }, SetOptions(merge: true));
    isfav.value = true;
  }

  Future<void> removefromwhishlist(docid) async {
    await firestore1.collection(productcollection).doc(docid).set({
      'p_whishlist': FieldValue.arrayRemove([currentuser!.uid])
    }, SetOptions(merge: true));
    isfav(false);
  }

  // Check if item is in wishlist
  Future<void> checkfav(data) async {
    if (data['p_whishlist'].contains(currentuser!.uid)) {
      isfav.value = true;
    } else {
      isfav.value = false;
    }
  }
}
