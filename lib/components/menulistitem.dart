import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dollarfeeds/services/get_color.dart';

Widget menuListItem(context, String name, String brand, double price) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: getColor(brand)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: MediaQuery.of(context).size.width - 150,
              child: AutoSizeText(
                name,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                maxLines: 2,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
            ),
            child: Text('\$' + price.toString(),
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
          ),
        ],
      ));
}
