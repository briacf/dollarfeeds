import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flushbar/flushbar.dart';
import '../models/offer.dart';
import '../models/report.dart';
import '../components/offer_container.dart';
import '../components/product_page/product_body.dart';
import '../services/get_recents.dart';
import '../services/auth.dart';
import '../services/map.dart';
import '../services/get_color.dart';
import '../services/fileio.dart';
import '../services/sanitize_name.dart';

final List<int> imgList = [1, 2, 3, 4, 5];

class ProductPage extends StatefulWidget {
  final Offer offer;
  ProductPage({Key key, @required this.offer}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _liked = false;
  var _path = Firestore.instance
      .collection('users')
      .document(getUID())
      .collection("favProducts");

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollNavBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  List categoryTags = [
    "burgers",
    "coffee",
    "pizza",
    "drinks",
    "desserts",
    "sides",
    "snacks",
    "sandwiches",
    "subs",
    "wings",
    "chicken",
  ];

  var sharedTag;

  void getSharedTags() {
    for (var tag in widget.offer.tags) {
      if (categoryTags.contains(tag)) {
        setState(() {
          sharedTag = tag;
        });
        break;
      }
    }
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
      if (_scrollNavBarController.offset <= 0) {
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

  void checkIfLiked() async {
    if (isSignedIn) {
      final snapshot = await _path.document(widget.offer.documentID).get();

      if (snapshot == null || !snapshot.exists) {
        setState(() {
          _liked = false;
        });
      } else {
        if (snapshot.data["liked"] == true) {
          setState(() {
            _liked = true;
          });
        } else {
          setState(() {
            _liked = false;
          });
        }
      }
    }
  }

  void submitReport(String refersToID, String type, String message) async {
    var path = Firestore.instance.collection("reportsAU");
    var report = new Report(refersToID, type, message);
    Map<String, dynamic> reportData = report.toJson();

    await path.add(reportData);
  }

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    addToRecents();
    getSharedTags();
    myScroll();
  }

  @override
  void dispose() {
    _scrollNavBarController.removeListener(() {});
    super.dispose();
  }

  void addToRecents() async {
    int i;
    String recentsStr;
    // Check the recents file exists, if not, create it
    try {
      recentsStr = await readFile("recents.txt");
    } catch (e) {
      writeFile("recents.txt", "");
    }

    List<String> recents = recentsStr.split(',');

    for (i = 0; i < recents.length; i++) {
      if (recents[i] == widget.offer.documentID && recents.length > 1) {
        recents.removeAt(i);
        break;
      }
    }

    recents.add(widget.offer.documentID);
    recentsStr = "";

    // Max number of recent items is 20
    i = 0;
    if (recents.length > 20) {
      i = recents.length - 20;
    }

    for (; i < recents.length; i++) {
      if (recents[i] != "") {
        recentsStr += recents[i] + ',';
      }
    }

    // Remove last char from recentStr, which is an unnecessary comma
    recentsStr = recentsStr.substring(0, recentsStr.length - 1);

    writeFile('recents.txt', recentsStr);
    reloadRecents();
  }

  Widget expiryContainer() {
    int currentDate = new DateTime.now().millisecondsSinceEpoch;

    if (widget.offer.expiry != null) {
      int expiryDate = widget.offer.expiry.toDate().millisecondsSinceEpoch;

      if (expiryDate > currentDate) {
        Column(
          children: <Widget>[
            Container(
                color: Colors.white12,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.red),
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                        'This deal has expired and is no longer available.',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                        textAlign: TextAlign.center),
                  ),
                )),
            SizedBox(
              height: 20,
            )
          ],
        );
      }
      return Container();
    }

    return Container();
  }

  Widget couponTypeContainer() {
    if (widget.offer.appExclusive == false) {
      return Container();
    } else {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 55),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
              color: getHighlightedColor(context),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.smartphone,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                widget.offer.brand + " App Exclusive",
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                textAlign: TextAlign.center,
              )
            ],
          ));
    }
  }

  Widget kjLabel() {
    if (widget.offer.kj > 0) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(widget.offer.kj.toStringAsFixed(0) + " KJ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700))
        ],
      );
    }
    return Container();
  }

  String getSavingsValue(double percentOff, double price) {
    if (percentOff < 0) {
      if (price == 0) {
        return "Free";
      }

      return "\$" + price.toStringAsFixed(2);
    }

    return percentOff.toString() + "% off";
  }

  Widget savingsContainer() {
    Color titleColor = Colors.black;

    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      titleColor = Colors.white;
    }

    return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Text(
          getSavingsValue(widget.offer.percentOff, widget.offer.price),
          style: TextStyle(
              fontSize: 25.0, fontWeight: FontWeight.w500, color: titleColor),
          textAlign: TextAlign.left,
        ));
  }

  Widget _buildBody(BuildContext context) {
    var _reportType = "Didn't Work";
    var _reportMessageController = new TextEditingController();
    var _reportMessage = "";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          controller: _scrollNavBarController,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: getShadowColor(context),
                        blurRadius: 10.0, // soften the shadow
                        spreadRadius: 5.0, //extend the shadow
                        offset: Offset(
                          0.0, // Move to right 10  horizontally
                          1.0, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                        // Where the linear gradient begins and ends
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        // Add one stop for each color. Stops should increase from 0 to 1
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: getGradientColors(widget.offer.brand)),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        'assets/brand_logos/' +
                            sanitizeName(widget.offer.brand) +
                            '.png',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.offer.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Color(0xFF000000).withOpacity(0.2),
                        ),
                        child: Text(
                            getSavingsValue(
                                widget.offer.percentOff, widget.offer.price),
                            style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                      kjLabel(),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment(0.82, -1),
                  child: PopupMenuButton<int>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Text("Report an Issue"),
                      ),
                    ],
                    onSelected: (value) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              title: Text("Report this Offer"),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              content: Form(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Issue"),
                                    RadioListTile(
                                        title: Text("Didn't Work"),
                                        value: "Didn't Work",
                                        groupValue: _reportType,
                                        onChanged: (value) {
                                          setState(() {
                                            _reportType = value;
                                          });
                                        }),
                                    RadioListTile(
                                        title: Text("Incorrect Info"),
                                        value: "Incorrect Info",
                                        groupValue: _reportType,
                                        onChanged: (value) {
                                          setState(() {
                                            _reportType = value;
                                          });
                                        }),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Additional Info"),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: TextField(
                                        controller: _reportMessageController,
                                        decoration: InputDecoration(
                                            hintText: "Any additional details"),
                                        onChanged: (value) {
                                          setState(() {
                                            _reportMessage = value;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        RaisedButton(
                                          elevation: 0,
                                          color: getTextFieldColor(context),
                                          padding: const EdgeInsets.all(5.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      10.0)),
                                          child: const Text('Cancel',
                                              style: TextStyle(fontSize: 18)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        RaisedButton(
                                          elevation: 0,
                                          textColor: Colors.white,
                                          color: getColor("default"),
                                          padding: const EdgeInsets.all(5.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      10.0)),
                                          child: const Text('OK',
                                              style: TextStyle(fontSize: 18)),
                                          onPressed: () {
                                            submitReport(
                                                widget.offer.documentID,
                                                _reportType,
                                                _reportMessage);
                                            Navigator.pop(context);
                                            Flushbar(
                                              backgroundColor:
                                                  Color(0xFF39a065),
                                              flushbarPosition:
                                                  FlushbarPosition.BOTTOM,
                                              messageText: Text(
                                                "Report Sent",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              duration: Duration(seconds: 2),
                                            )..show(context);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            couponTypeContainer(),
            SizedBox(
              height: 20,
            ),
            productBody(context, widget.offer),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("More From " + widget.offer.brand,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                height: 190,
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("productsAU")
                        .where("brand", isEqualTo: widget.offer.brand)
                        .limit(20)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return Container();
                      var documents = snapshot.data.documents;
                      var length = documents.length;

                      // Remove this item from the list
                      for (var doc in documents) {
                        if (widget.offer.documentID == doc.documentID) {
                          documents.remove(doc);
                          break;
                        }
                      }

                      List itemsToRemove = new List();

                      for (int i = 0; i < length; i++) {
                        try {
                          if (documents[i]["startDate"] != null &&
                              documents[i]["startDate"]
                                  .toDate()
                                  .isAfter(DateTime.now())) {
                            itemsToRemove.add(documents[i]);
                          } else {
                            if (documents[i]["expiry"] != null &&
                                documents[i]["expiry"]
                                    .toDate()
                                    .isBefore(DateTime.now())) {
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
                          }),
                        );
                      }
                      return Container();
                    })),
            SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Similar Offers",
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                height: 190,
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("productsAU")
                        .where("tags", arrayContains: sharedTag)
                        .limit(20)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return Container();
                      var documents = snapshot.data.documents;
                      var length = documents.length;

                      // Remove this item from the list
                      for (var doc in documents) {
                        if (widget.offer.documentID == doc.documentID) {
                          documents.remove(doc);
                          break;
                        }
                      }

                      List itemsToRemove = new List();

                      for (int i = 0; i < length; i++) {
                        try {
                          if (documents[i]["startDate"] != null &&
                              documents[i]["startDate"]
                                  .toDate()
                                  .isAfter(DateTime.now())) {
                            itemsToRemove.add(documents[i]);
                          } else {
                            if (documents[i]["expiry"] != null &&
                                documents[i]["expiry"]
                                    .toDate()
                                    .isBefore(DateTime.now())) {
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
                          }),
                        );
                      }
                      return Container();
                    })),
            SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "All names, logos and other trademarks belong to their owners. Their use is only for informational purposes.",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget heartButton() {
    if (userIsSignedIn()) {
      Icon _heart;

      if (_liked == true) {
        _heart = Icon(CupertinoIcons.heart_solid, color: Colors.red);
      } else {
        _heart = Icon(CupertinoIcons.heart, color: Colors.red);
      }

      return CupertinoButton(
        padding: EdgeInsets.zero,
        child: _heart,
        onPressed: () {
          setState(() {
            if (_liked == true) {
              _heart = Icon(
                CupertinoIcons.heart,
                color: Colors.red,
              );
              _liked = false;
            } else {
              _heart = Icon(
                CupertinoIcons.heart_solid,
                color: Colors.red,
              );
              _liked = true;
            }
          });

          Map<String, bool> json = {'liked': _liked};
          _path.document(widget.offer.documentID).setData(json);
        },
      );
    }

    return null;
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
          middle: _showAppbar ? null : Text(widget.offer.name),
          backgroundColor: getThemeColor(context),
          border: Border(bottom: BorderSide(color: getThemeColor(context))),
          trailing: heartButton()),
      body: _buildBody(context),
    );
  }
}
