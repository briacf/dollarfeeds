import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

import '../models/offer.dart';
import '../components/offer_container.dart';
import 'product_page.dart';
import '../services/auth.dart';
import '../services/get_color.dart';
import '../services/sanitize_name.dart';

class BrandPage extends StatefulWidget {
  final String name;
  BrandPage({Key key, @required this.name}) : super(key: key);

  @override
  _BrandPageState createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _liked;
  var _likedPath = Firestore.instance
      .collection('users')
      .document(getUID())
      .collection('favBrands');

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollNavBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  void checkIfLiked() async {
    if (isSignedIn) {
      final snapshot = await _likedPath.document(widget.name).get();

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

  @override
  void initState() {
    super.initState();
    checkIfLiked();
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

  Widget _offersBody(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("productsAU")
            .where("brand", isEqualTo: widget.name)
            .limit(200)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
          var documents = snapshot.data.documents;
          var length = snapshot.data.documents.length;

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
                      Text("We couldn't find any offers",
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

          return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: length,
              itemBuilder: (context, i) {
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
                                    List<String>.from(documents[i]["steps"]),
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
              });
        });
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
          _likedPath.document(widget.name).setData(json);
        },
      );
    }

    return null;
  }

  Widget tabTitle() {
    if (_showAppbar) {
      return Container(
          height: 60,
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/brand_logos/' + sanitizeName(widget.name) + '.png',
                height: 55,
                width: 55,
              ),
              SizedBox(width: 10,),
              Text(widget.name,
                style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)
            ],
          )
      );
    } else {
      return Container(
          height: 60
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24),
            controller: _scrollNavBarController,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              tabTitle(),
              SizedBox(
                height: 20,
              ),
              _offersBody(context),
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
          ),
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
              middle: _showAppbar ? null : Text(widget.name),
              backgroundColor: getThemeColor(context),
              border: Border(bottom: BorderSide(color: getThemeColor(context))),
              trailing: heartButton()),
      body: _buildBody(context),
    );
  }
}
