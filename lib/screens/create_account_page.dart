import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';

import 'verify_email_page.dart';
import 'legal_terms_page.dart';
import 'privacy_policy_page.dart';
import '../models/user.dart';
import '../services/get_color.dart';

class CreateAccountPage extends StatefulWidget {
  static const title = 'Create Account';

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String userID;
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _password;
  bool _termsAccepted = false;
  bool _sendMarketing = true;
  bool _showTermsAcceptedError = false;

  // FireBase Errors
  bool _unknownError = false;
  bool _emailInUseError = false;

  bool _currentlyCreatingAccount = false;

  bool _showAppbar = true; //this is to show app bar
  ScrollController _scrollNavBarController =
      new ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height

  final pwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myScroll();
  }

  @override
  void dispose() {
    _scrollNavBarController.removeListener(() {});
    pwController.dispose();
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

  bool validateAndSave() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  void _validateAndSubmit(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    if (validateAndSave()) {
      try {
        FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .user;

        var path = Firestore.instance.collection("users");

        User newUser = new User(_email, _sendMarketing);
        Map<String, dynamic> userData = newUser.toJson();
        await path.document(user.uid).setData(userData);

        user.sendEmailVerification();

        _currentlyCreatingAccount = false;

        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => VerifyEmailPage(
                  user: user,
                )));
      } catch (e) {
        setState(() {
          switch (e.code) {
            case "ERROR_EMAIL_ALREADY_IN_USE":
              {
                _emailInUseError = true;
              }
              break;
            default:
              _unknownError = false;
          }
        });
      }
    }
  }

  Widget termsAcceptedError() {
    if (_showTermsAcceptedError && !_termsAccepted) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "You must accept the terms & conditions and privacy policy to create an account",
            style: TextStyle(color: getErrorColor(context), fontSize: 14),
          ));
    }

    return Container();
  }

  Widget showEmailError() {
    if (_emailInUseError) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                "An account with this email already exists",
                style: TextStyle(color: getErrorColor(context), fontSize: 14),
              )
            ],
          ),
        ),
      );
    } else if (_unknownError == true) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                "An error occurred. Please try again later.",
                style: TextStyle(color: getErrorColor(context), fontSize: 14),
              )
            ],
          ),
        ),
      );
    }

    return Container();
  }

  Widget navBarReplacement() {
    return _showAppbar ? SizedBox() : SizedBox(height: 44);
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
          controller: _scrollNavBarController,
          padding: EdgeInsets.symmetric(horizontal: 24),
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            navBarReplacement(),
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text('Get Started',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
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
                  showEmailError(),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('At least 8 alphanumeric characters',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: TextFormField(
                      controller: pwController,
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
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Enter a password";
                        } else if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        } else if (!RegExp(
                                r"^(?=.*[A-Z])(?=.*[a-z])(?=.*?[0-9])")
                            .hasMatch(value)) {
                          return "Must contain a mix of letters and numbers";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => _password = value,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Confirm Password',
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
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Enter your password again";
                        } else if (value != pwController.text) {
                          return "Passwords don't match";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[

              ],
            ),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              children: <Widget>[
                Checkbox(
                  activeColor: Colors.green,
                  value: _termsAccepted,
                  onChanged: (bool value) {
                    setState(() {
                      _termsAccepted = value;
                    });
                  },
                ),
                Text("I accept the "),
                GestureDetector(
                  child: Text(
                    "terms of service",
                    style: TextStyle(
                        color: getHighlightedColor(context),
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push<Widget>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LegalTermsPage()));
                  },
                ),
                Text(" and "),
                GestureDetector(
                  child: Text(
                    "privacy policy",
                    style: TextStyle(
                        color: getHighlightedColor(context),
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push<Widget>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage()));
                  },
                ),
              ],
            ),
            termsAcceptedError(),
            Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Checkbox(
                  activeColor: Colors.green,
                  value: _sendMarketing,
                  onChanged: (bool value) {
                    setState(() {
                      _sendMarketing = value;
                    });
                  },
                ),
                Text("Send me offers to my inbox")
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: _currentlyCreatingAccount == false
                    ? RaisedButton(
                  elevation: 0,
                  color: getColor("default"),
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(5.0),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      new BorderRadius.circular(10.0)),
                  child: const Text('Create Account',
                      style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    if (_formKey.currentState.validate() &&
                        _termsAccepted == true) {
                      setState(() {
                        _currentlyCreatingAccount = true;
                      });
                      _validateAndSubmit(context);
                    } else if (_termsAccepted == false) {
                      setState(() {
                        _showTermsAcceptedError = true;
                      });
                    }
                  },
                )
                    : Center(
                  child: CircularProgressIndicator(),
                )),
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
