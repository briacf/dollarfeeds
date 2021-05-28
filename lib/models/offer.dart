import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String documentID;
  final String name;
  final String brand;
  final String imageURL;
  final List<String> tags;
  final String type;
  final String description;
  final List<String> steps;
  final String voucherCode;
  final double kj;
  final bool appExclusive;
  final String url;
  final double price;
  final double percentOff;
  final Timestamp expiry;

  Offer(this.documentID, this.name, this.brand, this.imageURL, this.tags, this.type, this.description,
      this.steps, this.voucherCode, this.kj, this.appExclusive, this.url, this.price, this.percentOff,
      this.expiry);
}