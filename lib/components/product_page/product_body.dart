import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/offer.dart';
import 'package:dollarfeeds/components/product_page/product_voucher_body.dart';
import 'package:dollarfeeds/components/product_page/product_deal_body.dart';

// Create body based on type
Widget productBody(BuildContext context, Offer offer) {
  if (offer.type == "voucher") {
    return voucherBody(context, offer);
  } else if (offer.type == "deal") {
    return dealBody(context, offer);
  } else {
    return Container();
  }
}
