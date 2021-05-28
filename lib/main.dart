import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dollarfeeds/services/fileio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

import 'screens/product_tab.dart';
import 'screens/nearby_tab.dart';
import 'screens/search_tab.dart';
import 'screens/profile_tab.dart';
import 'services/get_color.dart';
import 'services/get_brands.dart';
import 'services/auth.dart';
import 'services/get_recents.dart';


void main() {
  runApp(Material(
    child: MyApp(),
  ));
}

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primaryWhite = MaterialColor(
  _whitePrimaryValue,
  <int, Color>{
    50: Color(0xFFffffff),
    100: Color(0xFFffffff),
    200: Color(0xFFffffff),
    300: Color(0xFFffffff),
    400: Color(0xFFffffff),
    500: Color(_whitePrimaryValue),
    600: Color(0xFFffffff),
    700: Color(0xFFffffff),
    800: Color(0xFFffffff),
    900: Color(0xFFffffff),
  },
);
const int _whitePrimaryValue = 0xFFffffff;

class MyApp extends StatelessWidget {
  @override
  Widget build(context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Change this value to better see animations.
    timeDilation = 1;
    // Either Material or Cupertino widgets work in either Material or Cupertino
    // Apps.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dollar Feeds',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: primaryBlack,
        accentColor: getColor("default"),
        scaffoldBackgroundColor: Color(0xFFf7f7f7),
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: primaryWhite,
          accentColor: getColor("default"),
          scaffoldBackgroundColor: Color(0xFF313131)),
      home: MainTabBar(),
    );
  }
}

// Shows a different type of scaffold depending on the platform.
//
// This file has the most amount of non-sharable code since it behaves the most
// differently between the platforms.
//
// These differences are also subjective and have more than one 'right' answer
// depending on the app and content.
class MainTabBar extends StatefulWidget {
  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  PageController pageController;

  var online = true;

  void getSystemStatus() async {
    Firestore.instance
        .collection("system")
        .document("status")
        .get()
        .then((documentSnapshot) => setState(() {
              online = documentSnapshot.data['online'];
            }));
  }

  @override
  void initState() {
    super.initState();

    getSystemStatus();
    pageController = PageController();
    getBrands();
    getUserStatus();
    reloadRecents();
  }

  @override
  Widget build(BuildContext context) {
    if (online) {
      return new Scaffold(
          body: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              Container(
                child: ProductsTab(),
              ),
              Container(
                child: NearbyTab(),
              ),
              Container(
                child: SearchTab(),
              ),
              Container(
                child: ProfileTab(),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavyBar(
            backgroundColor: getThemeColor(context),
            selectedIndex: _selectedIndex,
            showElevation: false,
            // use this to remove appBar's elevation
            onItemSelected: (index) => setState(() {
              _selectedIndex = index;
              pageController.jumpToPage(_selectedIndex);
            }),
            items: [
              BottomNavyBarItem(
                icon: Icon(Icons.fastfood),
                title: Text('Home'),
                activeColor: getColor("default"),
              ),
              BottomNavyBarItem(
                  icon: Icon(Icons.location_on),
                  title: Text('Nearby'),
                  activeColor: getColor("nearby")),
              BottomNavyBarItem(
                  icon: Icon(Icons.search),
                  title: Text('Search'),
                  activeColor: getColor("search")),
              BottomNavyBarItem(
                  icon: Icon(Icons.favorite),
                  title: Text('Favourites'),
                  activeColor: getColor("favourites")),
            ],
          ));
    } else {
      return new Scaffold(
          body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/cone.png',
              height: 90,
              width: 90,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Down for Maintenance",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 5,
            ),
            Text("Please check back later", style: TextStyle(fontSize: 18))
          ],
        ),
      ));
    }
  }
}
