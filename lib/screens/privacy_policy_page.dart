import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/get_color.dart';

class PrivacyPolicyPage extends StatefulWidget {
  static const title = 'Privacy Policy';

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage>
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
    return _showAppbar ? SizedBox() : SizedBox(height: 44);
  }

  Widget subtitle(int number, String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number.toString() + '. ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget numberedSection(double number, String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number.toString() + '. ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget letterSection(double number, String letter, String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              number.toString() + '. ',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: getThemeColor(context)),
            ),
            Flexible(
              child: Text(
                '(' + letter + ') ' + text,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget indentedBodyText(String text) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 44),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 17),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget bodyText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 17),
    );
  }

  _launchURL(var url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
              child: Text('Privacy Policy',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 40,
            ),
            bodyText(
                "Dollar Feast built the Dollar Feeds app as a Free app. This SERVICE is provided by Dollar Feast at no cost and is intended for use as is.\n"
                "\nThis page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.\n"
                "\nIf you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.\n"
                "\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Dollar Feast unless otherwise defined in this Privacy Policy. "),
            SizedBox(
              height: 20,
            ),
            subtitle(1, "Information Collection and Use"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to emails and passwords. The information that we request will be retained by us and used as described in this privacy policy.\n"
                "\nThe app does use third party services that may collect information used to identify you."
                "\nLinks to privacy policies of third party service providers used by the app:"),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: Text(
                "Google Play Services",
                style: TextStyle(
                    color: getHighlightedColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () {
                _launchURL("https://policies.google.com/privacy");
              },
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: Text(
                "Firebase Analytics",
                style: TextStyle(
                    color: getHighlightedColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
              onTap: () {
                _launchURL("https://firebase.google.com/policies/analytics");
              },
            ),
            SizedBox(
              height: 20,
            ),
            subtitle(2, "Log Data"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "Whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics."),
            SizedBox(
              height: 20,
            ),
            subtitle(3, "Cookies"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.\n"
                '\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use "cookies" to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.'),
            SizedBox(
              height: 20,
            ),
            subtitle(4, "Service Providers"),
            SizedBox(
              height: 5,
            ),
            numberedSection(4.1,
                "We may employ third-party companies and individuals due to the following reasons: "),
            letterSection(4.1, "a", "To facilitate our Service;"),
            letterSection(4.1, "b", "To provide the Service on our behalf;"),
            letterSection(4.1, "c", "To perform Service-related services; or"),
            letterSection(
                4.1, "d", "To assist us in analyzing how our Service is used."),
            numberedSection(4.2,
                "We want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose."),
            SizedBox(
              height: 20,
            ),
            subtitle(5, "Security"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security."),
            SizedBox(
              height: 20,
            ),
            subtitle(6, "Links to Other Sites"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services."),
            SizedBox(
              height: 20,
            ),
            subtitle(7, "Children's Privacy"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions."),
            SizedBox(
              height: 20,
            ),
            subtitle(8, "Changes to this Privacy Policy"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page."),
            SizedBox(
              height: 20,
            ),
            subtitle(9, "Contact"),
            SizedBox(
              height: 5,
            ),
            bodyText(
                "If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at dollarfeeds@gmail.com."),
            SizedBox(
              height: 40,
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
