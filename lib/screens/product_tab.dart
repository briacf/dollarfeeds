// Packages
import 'dart:collection';
import 'dart:math';

import 'package:dollarfeeds/services/get_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dollarfeeds/services/get_brands.dart';

// Models
import '../models/offer.dart';
import '../models/offer_list.dart';

// Screens
import 'product_list_page.dart';
import 'product_page.dart';
import 'brand_page.dart';

// Components
import '../components/brand_circle.dart';
import '../components/offer_container.dart';

// Services
import '../services/map.dart';

List<int> tempList = [0, 1];
final databaseReference = Firestore.instance;

class ProductsTab extends StatefulWidget {
  static const title = 'Deals';
  static const androidIcon = Icon(Icons.fastfood);
  static const iosIcon = Icon(Icons.home);

  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  HashMap brandOffersShown = HashMap<String, int>();
  List productsList = new List();

  List shuffle(List items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {

      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  // Sort a list in ascending order by a tag, so offers with the tag are pushed to the front
  List sortByTag(List<DocumentSnapshot> items, String tag) {
    List<DocumentSnapshot> tagsList = new List<DocumentSnapshot>(); // Items with the tag
    List<DocumentSnapshot> nonTagsList = new List<DocumentSnapshot>(); // Items that do not have the tag
    List tags = new List();

    for (var item in items) {
      tags = List<String>.from(item["tags"]);

      if (tags.contains(tag)) {
        tagsList.add(item);
      } else {
        nonTagsList.add(item);
      }

      tags.clear();
    }

    return tagsList + nonTagsList;
  }

  void getProducts() async {
    Firestore.instance
        .collection("productsAU")
        .where("expiry", isGreaterThan: DateTime.now())
        .limit(200)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) async {
        brandOffersShown.putIfAbsent(doc["brand"], () => 0);

        var value = brandOffersShown[doc["brand"]];

        if (value < 6) {
          brandOffersShown[doc["brand"]] = value + 1;
          setState(() {
            productsList = shuffle(productsList);
            productsList.add(doc);
          });
        } else {
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    brandCarouselStreamController.close();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream:
                        Firestore.instance.collection("featuredAU").snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return Container();
                      var documents = snapshot.data.documents;
                      var length = documents.length;

                      if (length == 0) {
                        return Container();
                      }

                      var indexes = Iterable<int>.generate(length).toList();
                      return GestureDetector(
                        child: CarouselSlider(
                          viewportFraction: 1.0,
                          aspectRatio: 16 / 9,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 10),
                          items: map<Widget>(indexes, (index, i) {
                            return GestureDetector(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            documents[i]["url"],
                                          ),
                                          fit: BoxFit.fill)),
                                ),
                                onTap: () {
                                  String name = documents[i]["name"];
                                  String tags = documents[i]["tags"];
                                  double percentAbove =
                                      documents[i]["percentAbove"].toDouble();
                                  double priceBelow =
                                      documents[i]["priceBelow"].toDouble();
                                  String orderBy = documents[i]["orderBy"];
                                  bool orderByDescending =
                                      documents[i]["orderByDescending"];
                                  int limit = documents[i]["limit"];

                                  if (name != null &&
                                      tags != null &&
                                      percentAbove != null &&
                                      priceBelow != null) {
                                    Navigator.push<Widget>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductListPage(
                                          offerList: OfferList(
                                              name,
                                              true,
                                              [],
                                              tags,
                                              true,
                                              true,
                                              "all",
                                              percentAbove,
                                              priceBelow,
                                              orderBy == null ? "" : orderBy,
                                              orderByDescending == null
                                                  ? false
                                                  : orderByDescending,
                                              limit == null ? 20 : limit),
                                        ),
                                      ),
                                    );
                                  }
                                });
                          }),
                        ),
                        onTap: () {},
                      );
                    })),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              height: 110,
              child: StreamBuilder(
                  stream:
                      brandCarouselStreamController.stream.asBroadcastStream(),
                  builder: (BuildContext context, snapshot) {
                    return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(5.0),
                        itemCount: carouselBrandNames.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                              child: brandCircle(carouselBrandNames[i]),
                              onTap: () {
                                Navigator.push<Widget>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BrandPage(
                                            name: carouselBrandNames[i],
                                          )),
                                );
                              });
                        });
                  })),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text('Under \$5',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w600)),
                  ),
                  GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Text('See More',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w500)),
                          Icon(Icons.chevron_right)
                        ],
                      ),
                      onTap: () {
                        Navigator.push<Widget>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListPage(
                              offerList: OfferList("Under \$5", true, [], "",
                                  true, true, "all", -1, 5, "", false, 100),
                            ),
                          ),
                        );
                      })
                ]),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              height: 190,
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("productsAU")
                      .where("price", isLessThanOrEqualTo: 5)
                      .where("price", isGreaterThan: 0)
                      .limit(40)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return Container();
                    var documents = snapshot.data.documents;
                    var length = documents.length;

                    List itemsToRemove = new List();

                    for (int i = 0; i < length; i++) {
                      try {
                        if (documents[i]["startDate"] != null &&
                            documents[i]["startDate"].toDate().isAfter(DateTime.now())) {
                          itemsToRemove.add(documents[i]);
                        } else {
                          if (documents[i]["expiry"] != null &&
                              documents[i]["expiry"].toDate().isBefore(DateTime.now())) {
                            itemsToRemove.add(documents[i]);
                          }
                        }
                      } catch (e) {}
                    }

                    for (int i = 0; i < itemsToRemove.length; i++) {
                      documents.remove(itemsToRemove[i]);
                    }

                    length = documents.length;

                    var indexes = Iterable<int>.generate(length).toList();

                    documents = sortByTag(documents, "food");

                    if (length > 0) {
                      return CarouselSlider(
                        items: map<Widget>(indexes, (index, i) {
                          try {
                            return GestureDetector(
                                child: offerContainer(
                                    context,
                                    true,
                                    documents[i]["name"],
                                    documents[i]["brand"],
                                    documents[i]["percentOff"].toDouble(),
                                    documents[i]["price"].toDouble(),
                                    documents[i]["kj"].toDouble()),
                                onTap: () {
                                  Navigator.push<Widget>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        offer: Offer(
                                            documents[i].documentID,
                                            documents[i]["name"],
                                            documents[i]["brand"],
                                            documents[i]["imageURL"],
                                            List<String>.from(
                                                documents[i]["tags"]),
                                            documents[i]["type"],
                                            documents[i]["description"],
                                            List<String>.from(
                                                documents[i]["steps"]),
                                            documents[i]["voucherCode"],
                                            documents[i]["kj"].toDouble(),
                                            documents[i]["appExclusive"],
                                            documents[i]["url"],
                                            documents[i]["price"].toDouble(),
                                            documents[i]["percentOff"]
                                                .toDouble(),
                                            documents[i]["expiry"]),
                                      ),
                                    ),
                                  );
                                });
                          } catch (e) {
                            return null;
                          }
                        }),
                      );
                    }
                    return Container();
                  })),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text('Drinks',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w600)),
                  ),
                  GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Text('See More',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w500)),
                          Icon(Icons.chevron_right)
                        ],
                      ),
                      onTap: () {
                        Navigator.push<Widget>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListPage(
                              offerList: OfferList(
                                  "Drinks",
                                  true,
                                  [],
                                  "noncoffee",
                                  true,
                                  true,
                                  "all",
                                  -1,
                                  -1,
                                  "",
                                  false,
                                  100),
                            ),
                          ),
                        );
                      })
                ]),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              height: 190,
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("productsAU")
                      .where("price", isLessThanOrEqualTo: 7)
                      .where("tags", arrayContains: "noncoffee")
                      .limit(40)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return Container();
                    var documents = snapshot.data.documents;
                    var length = documents.length;

                    List itemsToRemove = new List();

                    for (int i = 0; i < length; i++) {
                      try {
                        if (documents[i]["startDate"] != null &&
                            documents[i]["startDate"].toDate().isAfter(DateTime.now())) {
                          itemsToRemove.add(documents[i]);
                        } else {
                          if (documents[i]["expiry"] != null &&
                              documents[i]["expiry"].toDate().isBefore(DateTime.now())) {
                            itemsToRemove.add(documents[i]);
                          }
                        }
                      } catch (e) {}
                    }

                    for (int i = 0; i < itemsToRemove.length; i++) {
                      documents.remove(itemsToRemove[i]);
                    }

                    length = documents.length;

                    var indexes = Iterable<int>.generate(length).toList();

                    if (length > 0) {
                      return CarouselSlider(
                        items: map<Widget>(indexes, (index, i) {
                          try {
                            return GestureDetector(
                                child: offerContainer(
                                    context,
                                    true,
                                    documents[i]["name"],
                                    documents[i]["brand"],
                                    documents[i]["percentOff"].toDouble(),
                                    documents[i]["price"].toDouble(),
                                    documents[i]["kj"].toDouble()),
                                onTap: () {
                                  Navigator.push<Widget>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        offer: Offer(
                                            documents[i].documentID,
                                            documents[i]["name"],
                                            documents[i]["brand"],
                                            documents[i]["imageURL"],
                                            List<String>.from(
                                                documents[i]["tags"]),
                                            documents[i]["type"],
                                            documents[i]["description"],
                                            List<String>.from(
                                                documents[i]["steps"]),
                                            documents[i]["voucherCode"],
                                            documents[i]["kj"].toDouble(),
                                            documents[i]["appExclusive"],
                                            documents[i]["url"],
                                            documents[i]["price"].toDouble(),
                                            documents[i]["percentOff"]
                                                .toDouble(),
                                            documents[i]["expiry"]),
                                      ),
                                    ),
                                  );
                                });
                          } catch (e) {
                            return null;
                          }
                        }),
                      );
                    }
                    return Container();
                  })),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              child: Text('You Might Like',
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListView.builder(
              addAutomaticKeepAlives: true,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24),
              itemCount: productsList.length,
              itemBuilder: (context, i) {
                return Column(
                  children: <Widget>[
                    GestureDetector(
                        child: offerContainer(
                                context,
                                false,
                                productsList[i]["name"],
                                productsList[i]["brand"],
                                productsList[i]["percentOff"].toDouble(),
                                productsList[i]["price"].toDouble(),
                                productsList[i]["kj"].toDouble()),
                        onTap: () {
                          Navigator.push<Widget>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                offer: Offer(
                                    productsList[i].documentID,
                                    productsList[i]["name"],
                                    productsList[i]["brand"],
                                    productsList[i]["imageURL"],
                                    List<String>.from(productsList[i]["tags"]),
                                    productsList[i]["type"],
                                    productsList[i]["description"],
                                    List<String>.from(productsList[i]["steps"]),
                                    productsList[i]["voucherCode"],
                                    productsList[i]["kj"].toDouble(),
                                    productsList[i]["appExclusive"],
                                    productsList[i]["url"],
                                    productsList[i]["price"].toDouble(),
                                    productsList[i]["percentOff"].toDouble(),
                                    productsList[i]["expiry"]),
                              ),
                            ),
                          );
                        }),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              }),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
          middle: Text("Home"),
          backgroundColor: getThemeColor(context),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              
            },
          ),
      ),
      body: _buildBody(context),
    );
  }
}
