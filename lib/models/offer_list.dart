class OfferList {
  String title;
  bool includeAllBrands;
  List<String> brands;
  String tags;
  bool includeCoupons;
  bool includeVouchers;
  String linkType;
  double percentAbove;
  double priceBelow;
  String orderBy;
  bool orderByDescending;
  int limit;

  OfferList(this.title, this.includeAllBrands, this.brands, this.tags, this.includeCoupons, this.includeVouchers,
      this.linkType, this.percentAbove, this.priceBelow, this.orderBy, this.orderByDescending, this.limit);
}