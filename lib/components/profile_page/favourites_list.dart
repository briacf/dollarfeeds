import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/brand_circle.dart';
import '../../components/offer_container.dart';
import '../../models/offer.dart';
import '../../screens/brand_page.dart';
import '../../screens/product_page.dart';
import '../offer_container.dart';

Widget favouriteBrandsList(FirebaseUser user) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance
        .collection("users")
        .document(user.uid)
        .collection("favBrands")
        .where("liked", isEqualTo: true)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) return Container();
      var documents = snapshot.data.documents;
      var length = documents.length;

      if (length == 0) {
        return Container();
      }

      return Container(
        height: 110,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(5.0),
            itemCount: length,
            itemBuilder: (context, i) {
              return GestureDetector(
                  child: brandCircle(documents[i].documentID),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BrandPage(
                                name: documents[i].documentID,
                              )),
                    );
                  });
            }),
      );
    },
  );
}

Widget favouriteProductsList(FirebaseUser user) {
  var _path = Firestore.instance.collection("productsAU");

  return StreamBuilder(
      stream: Firestore.instance
          .collection("users")
          .document(user.uid)
          .collection("favProducts")
          .where("liked", isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Container(child: Center(child: CircularProgressIndicator()))
            ],
          );
        }
        var documents = snapshot.data.documents;
        var length = documents.length;

        if (length == 0) {
          return Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 40,),
                    Text("No Favourites",
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Tap the heart icon on an offer to save it",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          );
        }
        return Container(
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, i) {
                return new StreamBuilder(
                    stream: _path.document(documents[i].documentID).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var productDocument = snapshot.data;

                      if (productDocument.exists == false) {
                        return Container();
                      }

                      try {
                        return Column(
                          children: <Widget>[
                            GestureDetector(
                                child: offerContainer(
                                        context,
                                        false,
                                        productDocument["name"],
                                        productDocument["brand"],
                                        productDocument["percentOff"]
                                            .toDouble(),
                                        productDocument["price"].toDouble(),
                                        productDocument["kj"].toDouble()),
                                onTap: () {
                                  Navigator.push<Widget>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        offer: Offer(
                                            productDocument.documentID,
                                            productDocument["name"],
                                            productDocument["brand"],
                                            productDocument["imageURL"],
                                            List<String>.from(
                                                productDocument["tags"]),
                                            productDocument["type"],
                                            productDocument["description"],
                                            List<String>.from(
                                                productDocument["steps"]),
                                            productDocument["voucherCode"],
                                            productDocument["kj"].toDouble(),
                                            productDocument["appExclusive"],
                                            productDocument["url"],
                                            productDocument["price"].toDouble(),
                                            productDocument["percentOff"]
                                                .toDouble(),
                                            productDocument["expiry"]),
                                      ),
                                    ),
                                  );
                                }),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        );
                      } catch (e) {
                        return Container();
                      }
                    });
              }),
        );
      });
}

Widget favouritesList(FirebaseUser user) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        favouriteBrandsList(user),
        SizedBox(
          height: 10,
        ),
        favouriteProductsList(user),
      ],
    ),
  );
}
