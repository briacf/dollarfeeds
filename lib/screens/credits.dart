import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../services/get_color.dart';

class CreditsPage extends StatefulWidget {
  static const title = 'Create Account';



  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage>
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

  Widget navBarReplacement() {
    return _showAppbar
        ? SizedBox()
        : SizedBox(height: 44);
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
          controller: _scrollNavBarController,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24),
          children: <Widget>[
            navBarReplacement(),
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text('Credits & Attributions',
                  style:
                  TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 40,
            ),
            Text("Background vectors created by freepik - www.freepik.com"),
            SizedBox(
              height: 20,
            ),
          ]),
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      appBar: _showAppbar
          ? CupertinoNavigationBar(
          backgroundColor: getThemeColor(context),
          border: Border(bottom: BorderSide(color: getThemeColor(context))))
          : PreferredSize(
        child: Container(),
        preferredSize: Size(0.0, 0.0),
      ),
      body: _buildBody(context),
    );
  }
}
