import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sanitize_name.dart';

List brandNames = new List();
List sanitizedBrandNames = new List();
List carouselBrandNames = new List();
StreamController<String> brandCarouselStreamController =
StreamController<String>.broadcast();

Future getBrands() async {
  brandNames.clear();
  sanitizedBrandNames.clear();
  carouselBrandNames.clear();

  Firestore.instance
      .collection("brandsAU").where("include", isEqualTo: true).orderBy("name")
      .getDocuments()
      .then((QuerySnapshot snapshot) {
    snapshot.documents.forEach((doc) async {
      var name = doc["name"];
      
      brandNames.add(name);
      sanitizedBrandNames.add(sanitizeName(name));

      var offers = await Firestore.instance.collection("productsAU").where("brand", isEqualTo: name).getDocuments();

      if (offers.documents.length > 0) {
        brandCarouselStreamController.add("");
        carouselBrandNames.add(name);
      }
    });
  });
}