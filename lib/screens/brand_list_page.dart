import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'brand_page.dart';
import '../services/sanitize_name.dart';
import '../services/get_color.dart';
import '../services/get_brands.dart';

class BrandListPage extends StatefulWidget {
  @override
  _BrandListPageState createState() => _BrandListPageState();
}

class _BrandListPageState extends State<BrandListPage>
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

  AspectRatio brandContainer(String title) {
    return AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: getColor(title),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/brand_logos/' + sanitizeName(title) + '.png',
                height: 70,
                width: 70,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          alignment: Alignment(0, 0),
        ));
  }

  SizedBox _buildRow(String leftBrand, String rightBrand) {
    if (rightBrand == "") {
      return SizedBox(
          height: MediaQuery.of(context).size.width / 2 - 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                  child: brandContainer(leftBrand),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BrandPage(name: leftBrand)),
                    );
                  })
            ],
          ));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.width / 2 - 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              child: brandContainer(leftBrand),
              onTap: () {
                Navigator.push<Widget>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrandPage(name: leftBrand)),
                );
              }),
          GestureDetector(
              child: brandContainer(rightBrand),
              onTap: () {
                Navigator.push<Widget>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrandPage(name: rightBrand)),
                );
              })
        ],
      ),
    );
  }

  Widget _buildList() {
    List<Widget> itemList = List<Widget>();
    int length = brandNames.length;
    var _leftBrand, _rightBrand;
    int i, itemIndex = 0;

    if (length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    for (i = 0; i < length; i++) {
      _leftBrand = brandNames[itemIndex];

      if (i == --length) {
        _rightBrand = "";
      } else {
        _rightBrand = brandNames[itemIndex + 1];
      }

      itemIndex += 2;

      itemList.add(Column(
        children: <Widget>[
          _buildRow(_leftBrand, _rightBrand),
          SizedBox(
            height: 20,
          )
        ],
      ));
    }

    return Column(
      children: itemList,
    );
  }

  Widget tabTitle() {
    if (_showAppbar) {
      return Container(
        height: 60,
        child: Text('Restaurants',
            style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
        alignment: Alignment(-1, 0.0),
      );
    } else {
      return Container(
        height: 60,
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
        child: ListView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      controller: _scrollNavBarController,
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        tabTitle(),
        SizedBox(
          height: 20,
        ),
        _buildList(),
        SizedBox(
          height: 40,
        ),
        Container(
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
    ));
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: _showAppbar ? null : Text("Restaurants"),
          backgroundColor: getThemeColor(context),
          border: Border(bottom: BorderSide(color: getThemeColor(context)))),
      body: _buildBody(context),
    );
  }
}
