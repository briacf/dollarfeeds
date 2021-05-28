// Packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:dollarfeeds/screens/settings_page.dart';

// Models
import '../models/offer.dart';

// Screens
import 'product_page.dart';
import 'create_account_page.dart';
import 'reset_password_page.dart';
import 'verify_email_page.dart';

// Components
import '../components/profile_page/favourites_list.dart';
import '../components/offer_container.dart';

// Services
import '../services/get_color.dart';
import '../services/auth.dart';
import '../services/fileio.dart';
import '../services/get_recents.dart';

final List<int> imgList = [1, 2, 3, 4, 5];

class ProfileTab extends StatefulWidget {
  static const title = 'Profile';
  static const androidIcon = Icon(Icons.person);
  static const iosIcon = Icon(CupertinoIcons.heart_solid);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  TabController _tabController;

  Stream _stream;
  String userID;
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _password;
  bool _signInError = false;
  String _signInErrorMsg;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseAuth.instance.onAuthStateChanged;
    _tabController = TabController(vsync: this, length: 2);
    getRecents(true);
  }

  @override
  void dispose() {
    recentsStreamController.close();
    super.dispose();
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    if (validateAndSave()) {
      try {
        FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
                email: _email, password: _password))
            .user;

        setUser(user);
      } catch (e) {
        setState(() {
          _signInError = true;

          switch (e.code) {
            case "ERROR_WRONG_PASSWORD":
              {
                _signInErrorMsg = "Incorrect password";
              }
              break;
            case "ERROR_USER_NOT_FOUND":
              {
                _signInErrorMsg = "No account found matching this email";
              }
              break;
            case "ERROR_USER_DISABLED":
              {
                _signInErrorMsg =
                    "Account has been locked. Please contact support.";
              }
              break;
            default:
              _signInErrorMsg = "Sign-in error occurred";
          }
        });
      }
    }
  }

  Widget showSignInError() {
    if (_signInError) {
      return Column(
        children: <Widget>[
          SizedBox(height: 10),
          Text(
            _signInErrorMsg,
            style: TextStyle(color: getErrorColor(context), fontSize: 14),
          )
        ],
      );
    }

    return Container();
  }

  Widget _buildSignInBody(BuildContext context) {
    return SafeArea(
      child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 70,
            ),
            Container(
              child: Text('Sign In',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                  'Sign in to your account to access your saved offers and restaurants',
                  style: TextStyle(fontSize: 18.0)),
            ),
            SizedBox(
              height: 40,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: new InputDecoration(
                          hintText: 'account@example.com',
                          fillColor: getTextFieldColor(context),
                          filled: true,
                          errorStyle: TextStyle(
                              color: getErrorColor(context), fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0)),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Enter your email";
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => _email = value.trim(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: new InputDecoration(
                          fillColor: getTextFieldColor(context),
                          filled: true,
                          errorStyle: TextStyle(
                              color: getErrorColor(context), fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0)),
                      validator: (value) =>
                          value.isEmpty ? "Password can't be empty" : null,
                      onSaved: (value) => _password = value,
                    ),
                  ),
                  showSignInError(),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: RaisedButton(
                      elevation: 0,
                      color: getColor("default"),
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(5.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      child:
                          const Text('Sign In', style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _validateAndSubmit();
                          _signInError = false;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: RaisedButton(
                elevation: 0,
                color: getTextFieldColor(context),
                padding: const EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                child: const Text('Create Account',
                    style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAccountPage(),
                      ));
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: FlatButton(
                padding: const EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                child: const Text('Reset My Password',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                onPressed: () {
                  Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResetPasswordPage(
                                email: _email,
                              )));
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ]),
    );
  }

  List<String> recentIDs = List<String>();

  void getRecents(bool refreshView) async {
    String recentsStr;
    // Check the recents file exists, if not, create it
    try {
      recentsStr = await readFile("recents.txt");
      List<String> recents = recentsStr.split(',').reversed.toList();

      for (var ID in recents) {
        if (ID == "") {
          recents.remove(ID);
        }
      }

      if (refreshView) {
        setState(() {
          recentIDs = recents;
        });
      } else {
        recentIDs = recents;
      }
    } catch (e) {
      writeFile("recents.txt", "");
    }
  }

  Widget buildRecentsList(BuildContext context) {
    var _path = Firestore.instance.collection('productsAU');

    if (recentIDs.length == 0) {
      return Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 40,),
                Text("No Recents",
                    style: TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.w600)),
                SizedBox(
                  height: 5,
                ),
                Text("You haven't recently viewed any offers",
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
        itemCount: recentIDs.length,
        itemBuilder: (context, int i) {
          return StreamBuilder(
              stream: _path.document(recentIDs[i]).snapshots(),
              builder: (context, snapshot) {
                var document = snapshot.data;

                if (document == null) {
                  return Container();
                }

                // Prevent error in recents file from crashing the view
                try {
                  return Column(
                    children: <Widget>[
                      GestureDetector(
                        child: offerContainer(
                                context,
                                false,
                                document["name"],
                                document["brand"],
                                document["percentOff"].toDouble(),
                                document["price"].toDouble(),
                                document["kj"].toDouble()),
                        onTap: () {
                          Navigator.push<Widget>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                offer: Offer(
                                    document.documentID,
                                    document["name"],
                                    document["brand"],
                                    document["imageURL"],
                                    List<String>.from(document["tags"]),
                                    document["type"],
                                    document["description"],
                                    List<String>.from(document["steps"]),
                                    document["voucherCode"],
                                    document["kj"].toDouble(),
                                    document["appExclusive"],
                                    document["url"],
                                    document["price"].toDouble(),
                                    document["percentOff"].toDouble(),
                                    document["expiry"]),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  );
                } catch (e) {
                  print(e);
                  return Container();
                }
              });
        });
  }

  Widget recentsList(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              child: StreamBuilder(
                  stream: recentsStreamController.stream.asBroadcastStream(),
                  builder: (context, snapshot) {
                    getRecents(false);
                    return buildRecentsList(context);
                  }),
            ),
          ],
        ));
  }

  Widget _buildProfileBody(BuildContext context, FirebaseUser user) {
    setUserSignedIn();

    return SafeArea(
        child: TabBarView(
      controller: _tabController,
      children: <Widget>[recentsList(context), favouritesList(user)],
    ));
  }

  @override
  Widget build(context) {
    super.build(context);

    return StreamBuilder<FirebaseUser>(
      stream: _stream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;

          if (user == null) {
            return Scaffold(
              body: _buildSignInBody(context),
            );
          } else {
            reloadUser();

            if (userIsVerified() || user.isEmailVerified) {
              Color titleColor = Colors.black;

              if (MediaQuery.of(context).platformBrightness ==
                  Brightness.dark) {
                titleColor = Colors.white;
              }

              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: getThemeColor(context),
                  brightness: MediaQuery.of(context).platformBrightness,
                  elevation: 0,
                  title:
                      Text("Favourites", style: TextStyle(color: titleColor)),
                  bottom: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: titleColor,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BubbleTabIndicator(
                      indicatorHeight: 25.0,
                      indicatorColor: getHighlightedColor(context),
                      tabBarIndicatorSize: TabBarIndicatorSize.tab,
                    ),
                    tabs: <Widget>[
                      Tab(text: "Recents"),
                      Tab(text: "Favourites")
                    ],
                  ),
                  iconTheme: new IconThemeData(color: titleColor),
                ),
                endDrawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.person_pin,
                                color: Colors.white, size: 70),
                            Text(
                              user.email,
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Color(0xFFf1c268),
                                Color(0xFFefba55),
                                Color(0xFFeeb343),
                                Color(0xFFd6a13c)
                              ]
                          ),
                          color: getColor("default"),
                        ),
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Icon(Icons.settings),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Settings',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push<Widget>(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsPage(
                                        email: user.email,
                                      )));
                        },
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Icon(Icons.exit_to_app),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Sign Out',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          setUserSignedOut();
                          FirebaseAuth.instance.signOut();
                        },
                      ),
                    ],
                  ),
                ),
                body: _buildProfileBody(context, user),
              );
            } else {
              return VerifyEmailPage(
                user: user,
              );
            }
            /*
          if (snapshot.data.providerData.length == 1) { // logged in using email and password
            return snapshot.data.isEmailVerified
                ? _buildSignedInBody(context)
                : VerifyEmailPage(user: snapshot.data);
          } else { // logged in using other providers
            return _buildSignedInBody(context);
          }
          */
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
