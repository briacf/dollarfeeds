// Packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:dollarfeeds/models/offer.dart';
import 'package:dollarfeeds/services/get_color.dart';

// Components
import '../components/offer_container.dart';

// Models
import '../models/offer_list.dart';
import '../models/offer.dart';

// Screens
import 'product_page.dart';

class ProductListPage extends StatefulWidget {
  final OfferList offerList;
  ProductListPage({Key key, @required this.offerList}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollNavBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    _scrollNavBarController.removeListener(() {});
    super.dispose();
  }

  void myScroll() async {
    _scrollNavBarController.addListener(() {
      if (_scrollNavBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          hideBottomBar();
        }
      }
      if (_scrollNavBarController.offset <= 50) {
        if (isScrollingDown) {
          isScrollingDown = false;
          showBottomBar();
        }
      }
    });
  }

  void showBottomBar() {
    setState(() {
      _showAppbar = true;
    });
  }

  void hideBottomBar() {
    setState(() {
      _showAppbar = false;
    });
  }

  Widget tabTitle() {
    if (_showAppbar) {
      return Container(
        child: Text(widget.offerList.title,
            style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
      );
    } else {
      return Container(
        child: Text("",
            style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    var querySnapshot;

    if (widget.offerList.tags == "") {
      if (widget.offerList.priceBelow != -1) {
        if (widget.offerList.orderBy == "") {
          querySnapshot = Firestore.instance
              .collection("productsAU")
              .where("price", isLessThanOrEqualTo: widget.offerList.priceBelow).where("price", isGreaterThanOrEqualTo: 0)
              .limit(widget.offerList.limit)
              .snapshots();
        } else {
          querySnapshot = Firestore.instance
              .collection("productsAU")
              .where("price", isLessThanOrEqualTo: widget.offerList.priceBelow).where("price", isGreaterThanOrEqualTo: 0)
              .orderBy(widget.offerList.orderBy)
              .limit(widget.offerList.limit)
              .snapshots();
        }
      } else if (widget.offerList.percentAbove != -1) {
        if (widget.offerList.orderBy == "") {
          querySnapshot = Firestore.instance
              .collection("productsAU")
              .where("percentOff", isGreaterThanOrEqualTo: widget.offerList.percentAbove).where("percentOff", isGreaterThanOrEqualTo: 0)
              .limit(widget.offerList.limit)
              .snapshots();
        } else {
          querySnapshot = Firestore.instance
              .collection("productsAU")
              .where("percentOff", isGreaterThanOrEqualTo: widget.offerList.percentAbove).where("percentOff", isGreaterThanOrEqualTo: 0)
              .orderBy(widget.offerList.orderBy)
              .limit(widget.offerList.limit)
              .snapshots();
        }
      } else {
        if (widget.offerList.orderBy == "kj") {
          querySnapshot = Firestore.instance
              .collection("productsAU")
              .where("kj", isGreaterThan: 0)
              .orderBy(widget.offerList.orderBy, descending: widget.offerList.orderByDescending)
              .limit(widget.offerList.limit)
              .snapshots();
        } else {
          querySnapshot = Firestore.instance
              .collection("productsAU")
              .orderBy(widget.offerList.orderBy, descending: widget.offerList.orderByDescending)
              .limit(widget.offerList.limit)
              .snapshots();
        }
      }
    } else {
      if (widget.offerList.orderBy == "") {
        querySnapshot = Firestore.instance
            .collection("productsAU")
            .where("tags", arrayContains: widget.offerList.tags)
            .limit(widget.offerList.limit)
            .snapshots();
      } else {
        querySnapshot = Firestore.instance
            .collection("productsAU")
            .where("tags", arrayContains: widget.offerList.tags)
            .orderBy(widget.offerList.orderBy)
            .limit(widget.offerList.limit)
            .snapshots();
      }
    }

    return SafeArea(
        child: ListView(
      physics: BouncingScrollPhysics(),
      controller: _scrollNavBarController,
      padding: EdgeInsets.symmetric(horizontal: 24),
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        tabTitle(),
        SizedBox(
          height: 20,
        ),
        StreamBuilder(
            stream: querySnapshot,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                    child: Center(child: CircularProgressIndicator()));
              }
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

              if (length == 0) {
                return Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text("No Offers Found",
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.w600)),
                          SizedBox(
                            height: 5,
                          ),
                          Text("We couldn't find offers matching this criteria",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, i) {
                    try {
                      return Column(
                        children: <Widget>[
                          GestureDetector(
                              child: offerContainer(
                                      context,
                                      false,
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
                                          List<String>.from(documents[i]["tags"]),
                                          documents[i]["type"],
                                          documents[i]["description"],
                                          List<String>.from(
                                              documents[i]["steps"]),
                                          documents[i]["voucherCode"],
                                          documents[i]["kj"].toDouble(),
                                          documents[i]["appExclusive"],
                                          documents[i]["url"],
                                          documents[i]["price"].toDouble(),
                                          documents[i]["percentOff"].toDouble(),
                                          documents[i]["expiry"]),
                                    ),
                                  ),
                                );
                              }),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    } catch(e) {
                      return Container();
                    }
                  });
            }),
        SizedBox(
          height: 40,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("All names, logos and other trademarks belong to their owners. Their use is only for informational purposes.", style: TextStyle(fontSize: 12), textAlign: TextAlign.center,),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    ));
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
              middle: _showAppbar ? null : Text(widget.offerList.title),
              backgroundColor: getThemeColor(context),
              border: Border(bottom: BorderSide(color: getThemeColor(context)))),
      body: _buildBody(context),
    );
  }
}
