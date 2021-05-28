import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flushbar/flushbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/offer.dart';
import '../../services/get_color.dart';

Widget descriptionBody(String description) {
  if (description.length == 0) {
    return Container();
  }

  return Column(
    children: <Widget>[
      Text(
        description,
        style: TextStyle(fontSize: 17),
      ),
      SizedBox(
        height: 20,
      )
    ],
  );
}

// Voucher codes
Container voucherCodeContainer(BuildContext context, String voucherCode) {
  var codeBackgroundColor = Colors.white;

  if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    codeBackgroundColor = Colors.grey[800];
  }

  return Container(
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: getTextFieldColor(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 200,
            padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: codeBackgroundColor),
            child: AutoSizeText(voucherCode,
                maxLines: 1,
                style: TextStyle(fontSize: 24.0),
                textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            width: 100,
            child: RaisedButton(
              elevation: 0,
              color: getColor("default"),
              textColor: Colors.white,
              padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15.0)),
              child:
              const Text('Copy', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: voucherCode));
                Flushbar(
                  backgroundColor: Color(0xFF39a065),
                  flushbarPosition: FlushbarPosition.BOTTOM,
                  messageText: Text("Copied", style: TextStyle(color: Colors.white),),
                  duration: Duration(seconds: 2),
                )..show(context);
              },
            ),
          )
        ],
      ),
    ),
  );
}

Widget voucherCodeList(BuildContext context, String voucherCode) {
  List<String> codes = voucherCode.split(" ");

  for (int i = 0; i < codes.length; i++) {
    return Column(
      children: <Widget>[
        voucherCodeContainer(context, codes[i]),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  return null;
}

_launchURL(var url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget voucherBody(BuildContext context, Offer offer) {
  var url = offer.url;
  url = url.replaceFirst("https://", "");
  url = url.replaceFirst("www.", "");

  if (url[url.length - 1] == "/") {
    url = url.substring(0, url.length - 1);
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: <Widget>[
        descriptionBody(offer.description),
        voucherCodeList(context, offer.voucherCode),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: RaisedButton(
            elevation: 0,
            color: getColor("default"),
            textColor: Colors.white,
            padding: EdgeInsets.all(5.0),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            child: Text('Open ' + url, style: TextStyle(fontSize: 18)),
            onPressed: () {
              _launchURL(offer.url);
            },
          ),
        ),
      ],
    ),
  );
}
