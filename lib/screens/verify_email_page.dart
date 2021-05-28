import 'package:dollarfeeds/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'dart:async';

// Services
import '../services/get_color.dart';

class VerifyEmailPage extends StatefulWidget {
  static const title = 'Verify Your Email';

  final FirebaseUser user;
  VerifyEmailPage({Key key, @required this.user}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Timer timer;

  var _fireBaseAuth = FirebaseAuth.instance;

  bool _firstResend = true;
  DateTime before = DateTime.now();
  bool _verified = false;

  void checkIsVerified() async {
    if (!_verified) {
      FirebaseUser user = await _fireBaseAuth.currentUser();
      await user.reload();
      user = await _fireBaseAuth.currentUser();

      if (user.isEmailVerified) {
        setUserIsVerified();

        setState(() {
          _verified = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setUser(widget.user);
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => checkIsVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget verifiedInterface() {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                CupertinoIcons.check_mark_circled,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Verified",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
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
            child: const Text('Continue', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget unverifiedInterface() {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                CupertinoIcons.mail,
                size: 30,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Waiting for Verification",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
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
              child: const Text('Resend Link', style: TextStyle(fontSize: 18)),
              onPressed: () {
                DateTime after = DateTime.now();

                if (_firstResend ||
                    before.difference(after).inMilliseconds > 1000) {
                  _firstResend = false;

                  widget.user.sendEmailVerification();

                  Flushbar(
                    backgroundColor: Color(0xFF39a065),
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    messageText: Text("Verification Email Sent", style: TextStyle(color: Colors.white),),
                    duration: Duration(seconds: 2),
                  )..show(context);
                } else {
                  Flushbar(
                    backgroundColor: Color(0xFFfe6121),
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    messageText: Text("Please Wait 1 Minute Before Resending Link", style: TextStyle(color: Colors.white),),
                    duration: Duration(seconds: 2),
                  )..show(context);
                }
              }),
        ),
      ],
    );
  }

  Widget showInterface() {
    if (_verified) {
      return verifiedInterface();
    }
    return unverifiedInterface();
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              child: Text('Verify Your Email',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                  "Click the verification link we sent to your email. If you don't see it in your inbox, it might be in your junk folder.",
                  style: TextStyle(fontSize: 18.0)),
            ),
            SizedBox(
              height: 40,
            ),
            showInterface(),
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
      body: _buildBody(context),
    );
  }
}
