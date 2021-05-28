import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'delete_account.dart';
import 'credits.dart';
import '../models/user.dart';
import '../services/auth.dart';
import '../services/get_color.dart';

class SettingsPage extends StatefulWidget {
  static const title = 'Settings';

  final String email;
  SettingsPage({Key key, @required this.email}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var _path = Firestore.instance.collection('users').document(getUID());
  var _sendMarketingEnabled = false;

  String version = "";

  void checkIfSendMarketingEnabled() async {
    final snapshot = await _path.get();

    if (snapshot == null || !snapshot.exists) {
      setState(() {
        _sendMarketingEnabled = false;
      });
    } else {
      if (snapshot.data["sendMarketing"] == true) {
        setState(() {
          _sendMarketingEnabled = true;
        });
      } else {
        setState(() {
          _sendMarketingEnabled = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfSendMarketingEnabled();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
    });
  }

  void changeMarketingEmailSettings(_sendMarketing) async {
    User newUser = new User(widget.email, _sendMarketing);
    Map<String, dynamic> userData = newUser.toJson();

    _path.setData(userData);
  }

  Widget _buildList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Padding(padding: EdgeInsets.only(top: 20)),
        ListTile(
          title: Text(
            "Account Settings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        ListTile(
          title: Text('Send me offers to my inbox'),
          subtitle: Text("We do not share your info with 3rd parties"),
          trailing: Switch.adaptive(
            value: _sendMarketingEnabled,
            onChanged: (value) {
              setState(() => _sendMarketingEnabled = value);

              changeMarketingEmailSettings(_sendMarketingEnabled);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            height: 1,
            color: Colors.grey[400],
          ),
        ),
        ListTile(
          title: Text(
            'App Version',
            style: TextStyle(),
          ),
          trailing: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("1.0.1")),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            height: 1,
            color: Colors.grey[400],
          ),
        ),
        ListTile(
          title: Text(
            'Credits',
          ),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreditsPage()));
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            height: 1,
            color: Colors.grey[400],
          ),
        ),
        ListTile(
          title: Text(
            'Delete my account',
            style: TextStyle(color: getErrorColor(context)),
          ),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DeleteAccountPage()));
          },
        ),
      ],
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
      body: _buildList(),
    );
  }
}
