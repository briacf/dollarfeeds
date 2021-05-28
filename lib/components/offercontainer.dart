import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../services/sanitize_name.dart';
import '../services/get_color.dart';

String getSavingsValue(double percentOff, double price) {
  if (percentOff < 0) {
    if (price == 0) {
      return "Free";
    }

    return "\$" + price.toStringAsFixed(2);
  }

  return percentOff.toString() + "% off";
}

Widget kjLabel(kj) {
  if (kj > 0.0) {
    return Text(
      kj.toString() + " kJ",
      style: TextStyle(color: Colors.white, fontSize: 14),
    );
  }
  return Container();
}

Widget offerContainer(context, bool inCarousel, String name, String brand, double percentOff,
    double price, double kj) {

  double margin = 0;
  if (inCarousel) {
    margin = 5;
  }

  return Container(
    padding: EdgeInsets.all(20),
    height: 170,
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.symmetric(horizontal: margin),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.5, 0.7, 0.9],
          colors: getGradientColors(brand)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.asset(
              'assets/brand_logos/' + sanitizeName(brand) + '.png',
              height: 55,
              width: 55,
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Color(0xFF000000).withOpacity(0.2),
              ),
              child: Text(getSavingsValue(percentOff, price),
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ],
        ),
        Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  name,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                  maxLines: 2,
                ),
                kjLabel(kj)
              ],
            ))
      ],
    ),
  );
}
