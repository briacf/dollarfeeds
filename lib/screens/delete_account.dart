import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dollarfeeds/screens/profile_tab.dart';
import 'package:dollarfeeds/screens/settings_page.dart';

// Services
import '../services/auth.dart';
import '../services/get_color.dart';

class DeleteAccountPage extends StatefulWidget {
  static const title = 'Delete Your Account';

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var _userPath = Firestore.instance.collection('users').document(getUID());
  var _user = getUser();

  void deleteAccount() async {
    await _userPath.delete();
    await _user.delete();
    FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ProfileTab()));
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: ListView(padding: EdgeInsets.symmetric(horizontal: 24), children: <
          Widget>[
        SizedBox(
          height: 20,
        ),
        Container(
          child: Text('Remove Your Account',
              style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
          alignment: Alignment(-1, 0.0),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Text(
              "Deleting your account is permanent and cannot be undone. You'll lose access to your favourites, but still have access to the app.",
              style: TextStyle(fontSize: 18.0)),
        ),
        SizedBox(
          height: 40,
        ),
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: RaisedButton(
            elevation: 0,
            color: getErrorColor(context),
            textColor: Colors.white,
            padding: const EdgeInsets.all(5.0),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            child: const Text('Confirm Delete', style: TextStyle(fontSize: 18)),
            onPressed: () {
              deleteAccount();
            },
          ),
        ),
        SizedBox(height: 10,),
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: RaisedButton(
            elevation: 0,
            color: getTextFieldColor(context),
            textColor: Colors.black,
            padding: const EdgeInsets.all(5.0),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            child: const Text('Cancel', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SettingsPage(email: _user.email,)));
            },
          ),
        ),
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
      appBar: CupertinoNavigationBar(
        backgroundColor: getThemeColor(context),
        border: Border(bottom: BorderSide(color: getThemeColor(context))),
      ),
      body: _buildBody(context),
    );
  }
}
