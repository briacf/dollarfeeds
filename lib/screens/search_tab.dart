import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dollarfeeds/models/offer_list.dart';
import 'package:dollarfeeds/services/sanitize_name.dart';

// Screens
import 'brand_list_page.dart';
import 'brand_page.dart';
import 'product_list_page.dart';
import 'search_results_page.dart';

// Services
import '../services/get_brands.dart';
import '../services/get_color.dart';

class SearchTab extends StatefulWidget {
  static const title = 'Search';
  static const androidIcon = Icon(Icons.search);
  static const iosIcon = Icon(Icons.search);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = TextEditingController();
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();

  _SearchTabState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this._getNames();
    super.initState();
  }

  AspectRatio categoryContainer(String title) {
    return AspectRatio(
        aspectRatio: 1 / 1.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: getColor(title),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/brand_logos/' + sanitizeName(title) + '.png',
                height: 100,
                width: 100,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          alignment: Alignment(0, 0),
        ));
  }

  SizedBox _buildRow(
      Widget leftCategoryContainer, Widget rightCategoryContainer) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 2 - 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[leftCategoryContainer, rightCategoryContainer],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text('Categories',
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.w600)),
              alignment: Alignment(-1, 0.0),
            ),
            SizedBox(
              height: 30,
            ),
            _buildRow(
              GestureDetector(
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [
                                0.1,
                                0.5,
                                0.7,
                                0.9
                              ],
                              colors: [
                                Colors.green[800],
                                Colors.green[700],
                                Colors.green[600],
                                Colors.green[400],
                              ]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("🍴",
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Restaurants",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        alignment: Alignment(0, 0),
                      )),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrandListPage(),
                      ),
                    );
                  }),
              GestureDetector(
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [
                                0.1,
                                0.5,
                                0.7,
                                0.9
                              ],
                              colors: [
                                Colors.orange[800],
                                Colors.orange[700],
                                Colors.orange[600],
                                Colors.orange[400],
                              ]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("🍔",
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Burgers",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        alignment: Alignment(0, 0),
                      )),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          offerList: OfferList("Burgers", true, [], "burgers",
                              true, true, "all", 0, 1000, "", false, 100),
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 20,
            ),
            _buildRow(
              GestureDetector(
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [
                                0.1,
                                0.5,
                                0.7,
                                0.9
                              ],
                              colors: [
                                Color(0xFFc0281c),
                                Color(0xFFd62d20),
                                Color(0xFFda4236),
                                Color(0xFFde564c),
                              ]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("🍕",
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Pizza",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        alignment: Alignment(0, 0),
                      )),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          offerList: OfferList("Pizza", true, [], "pizza", true,
                              true, "all", -1, -1, "", false, 100),
                        ),
                      ),
                    );
                  }),
              GestureDetector(
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [
                                0.1,
                                0.5,
                                0.7,
                                0.9
                              ],
                              colors: [
                                Color(0xFFFFB703),
                                Color(0xFFffbe1c),
                                Color(0xFFffc535),
                                Color(0xFFffcc4e),
                              ]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("🍟",
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Sides",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        alignment: Alignment(0, 0),
                      )),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          offerList: OfferList("Sides", true, [], "sides", true,
                              true, "all", -1, -1, "", false, 100),
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 20,
            ),
            _buildRow(
              GestureDetector(
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [
                                0.1,
                                0.5,
                                0.7,
                                0.9
                              ],
                              colors: [
                                Color(0xFF2e41c5),
                                Color(0xFF4254ca),
                                Color(0xFF5766d0),
                                Color(0xFF6c7ad6),
                              ]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("🥤",
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Drinks",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        alignment: Alignment(0, 0),
                      )),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          offerList: OfferList("Drinks", true, [], "noncoffee",
                              true, true, "all", -1, -1, "", false, 100),
                        ),
                      ),
                    );
                  }),
              GestureDetector(
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [
                                0.1,
                                0.5,
                                0.7,
                                0.9
                              ],
                              colors: [
                                Color(0xFFb2783b),
                                Color(0xFFc68642),
                                Color(0xFFcb9254),
                                Color(0xFFd19e67),
                              ]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("☕",
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Coffee",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        alignment: Alignment(0, 0),
                      )),
                  onTap: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          offerList: OfferList("Coffee", true, [], "coffee",
                              true, true, "all", -1, -1, "", false, 100),
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;

      return Container(
          color: getThemeColor(context),
          child: ListView.builder(
            itemCount: names == null ? 0 : filteredNames.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                title: Text(filteredNames[index]),
                onTap: () => _filter.text = filteredNames[index],
              );
            },
          ));
    }

    return Container();
  }

  void _getNames() async {
    List tempList = [
      "Pizza",
      "Burgers",
      "Sides",
      "Drinks",
      "Vouchers",
      "Coffee",
      "Meals",
      "Kids",
      "Value",
      "Chips",
      "Cheeseburger",
      "Hamburger",
      "Birthday"
    ];
    setState(() {
      names = tempList + brandNames;
      names.sort();
      filteredNames = names;
    });
  }

  void executeSearch(var value) {
    if (sanitizedBrandNames.contains(sanitizeName(value))) {
      Navigator.push<Widget>(
          context,
          MaterialPageRoute(
              builder: (context) => BrandPage(
                    name: brandNames[
                        sanitizedBrandNames.indexOf(sanitizeName(value))],
                  )));
    } else {
      Navigator.push<Widget>(
          context,
          MaterialPageRoute(
              builder: (context) => SearchResultsPage(
                    queryString: value,
                  )));
    }
  }

  @override
  Widget build(context) {
    super.build(context);

    Color titleColor = Colors.black;

    if (MediaQuery.of(context).platformBrightness ==
        Brightness.dark) {
      titleColor = Colors.white;
    }
    
    Color textFieldColor = Colors.white;

    if (MediaQuery.of(context).platformBrightness ==
        Brightness.dark) {
      textFieldColor = Colors.grey[800];
    }

    return Scaffold(
      appBar: PreferredSize(
        child: Padding(
          padding: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
          child: Card(
            elevation: 2.0,
            child: Container(
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: TextField(
                style: TextStyle(
                  fontSize: 15.0,
                  color: titleColor,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: textFieldColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: textFieldColor,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  hintText: "Search..",
                  prefixIcon: Icon(
                    Icons.search,
                    color: titleColor,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: titleColor,
                  ),
                ),
                maxLines: 1,
                controller: _filter,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    executeSearch(value);
                  }
                },
              ),
            ),
          ),
        ),
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          60.0,
        ),
      ),
      body: Stack(
        children: <Widget>[_buildBody(context), _buildList()],
      ),
    );
  }
}
