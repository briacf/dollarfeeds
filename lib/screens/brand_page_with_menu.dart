// Packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:dollarfeeds/services/sanitize_name.dart';

//Models
import '../models/offer.dart';

// Components
import '../components/offer_container.dart';
import '../components/menu_list_item.dart';

// Screens
import 'product_page.dart';

// Services
import '../services/auth.dart';
import '../services/get_color.dart';

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

  TabController _tabController;
  var _categoryItems = new Map();
  var _categories;

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

  void getMenuCategoryItems() async {
    for (var category in _categories) {
      var query = await Firestore.instance
          .collection("brandsAU")
          .document(sanitizeName(widget.name) + 'au')
          .collection("menu")
          .where("category", isEqualTo: category["name"])
          .getDocuments();

      setState(() {
        _categoryItems[category["name"]] = query.documents;
      });
    }
  }

  void getMenuCategories() async {
    var query = await Firestore.instance
        .collection("brandsAU")
        .document(sanitizeName(widget.name) + 'au')
        .collection("menuCategories")
        .orderBy("rank")
        .getDocuments();

    setState(() {
      _categories = query.documents;
      getMenuCategoryItems();
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    _tabController = TabController(vsync: this, length: 2);
    getMenuCategories();
  }

  Widget _offersBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Flexible(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection("productsAU")
                    .where("brand", isEqualTo: widget.name)
                    .limit(200)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                        child: Center(child: CircularProgressIndicator()));
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
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(
                                height: 5,
                              ),
                              Text("We couldn't find any offers",
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
                                }),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        );
                      });
                }),
          )
        ],
      ),
    );
  }

  Widget _menuCategoryItems(BuildContext context, var category) {
    var _items = _categoryItems[category];

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _items == null ? 0 : _items.length,
        itemBuilder: (context, i) {
          return Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 5.8 / 1,
                child: menuListItem(context, _items[i]["name"], widget.name,
                    _items[i]["price"].toDouble()),
              ),
              SizedBox(
                height: 10,
              )
            ],
          );
        });
  }

  Widget _menuCategories() {
    return ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: _categories == null ? 0 : _categories.length,
        itemBuilder: (context, i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _categories[i]["name"],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: _menuCategoryItems(context, _categories[i]["name"]),
              ),
              SizedBox(
                height: 20,
              )
            ],
          );
        });
  }

  Widget _menuBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Flexible(child: _menuCategories())
        ],
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
          _likedPath.document(widget.name).setData(json);
        },
      );
    }

    return null;
  }

  Widget _buildBody(BuildContext context) {
    Color titleColor = Colors.black;

    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      titleColor = Colors.white;
    }

    return SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    child: Text(widget.name,
                        style:
                        TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
                    alignment: Alignment(-1, 0.0),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: titleColor,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: new BubbleTabIndicator(
                indicatorHeight: 25.0,
                indicatorColor: getHighlightedColor(context),
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
              ),
              tabs: <Widget>[Tab(text: "Offers"), Tab(text: "Menu")],
            ),
            Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: <Widget>[_offersBody(context), _menuBody(context)],
                ))
          ],
        ));
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
          backgroundColor: getThemeColor(context),
          border: Border(bottom: BorderSide(color: getThemeColor(context))),
          trailing: heartButton()),
      body: _buildBody(context),
    );
  }
}
