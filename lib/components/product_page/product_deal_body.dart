import 'package:flutter/material.dart';
import 'package:dollarfeeds/services/get_color.dart';

import '../../models/offer.dart';

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

Widget stepsBody(BuildContext context, List<String> steps) {
  if (steps.length < 2) {
    return Container();
  }

  return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: getTextFieldColor(context),
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Column(
        children: <Widget>[
          Text(
            "Use this Offer",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 10,
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, i) {
                return Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (i + 1).toString() + '. ',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        Flexible(
                          child: Text(
                            steps[i],
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
              }),
        ],
      ));
}

Widget dealBody(BuildContext context, Offer offer) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        descriptionBody(offer.description),
        stepsBody(context, offer.steps),
      ],
    ),
  );
}
