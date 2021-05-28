import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../services/sanitize_name.dart';

Widget brandCircle(String brandName) {
  var name = sanitizeName(brandName);

  if (name == "redrooster") {
    name = "redrooster2";
  } else if (name == "pizzahut") {
    name = "pizzahut2";
  }

  return Container(
    width: 90,
    padding: EdgeInsets.symmetric(horizontal: 0),
    child: Column(
      children: <Widget>[
        Container(
            height: 60.0,
            width: 60.0,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/brand_logos/' +
                    name +
                    '.png',
                height: 50,
                width: 50,
              ),
            ),),
        SizedBox(
          height: 5,
        ),
        AutoSizeText(brandName, maxLines: 2,
            style: TextStyle(fontSize: 14.0), textAlign: TextAlign.center,)
      ],
    ),
  );
}