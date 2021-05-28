import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dollarfeeds/screens/brand_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:typed_data';
import '../models/result.dart';
import '../models/place_response.dart';
import '../services/get_bytes_from_asset.dart';
import '../services/get_brands.dart';
import '../services/sanitize_name.dart';
import '../services/get_color.dart';
import '../services/get_distance.dart';

class NearbyTab extends StatefulWidget {
  static const title = 'Nearby';
  static const androidIcon = Icon(Icons.map);
  static const iosIcon = Icon(Icons.location_on);

  @override
  _NearbyTabState createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<int> tempList = [1, 2, 3, 4, 5];

  double _flexHeight = 1000;

  GoogleMapController _mapController;
  String _mapStyle;
  BitmapDescriptor activeMarkerIcon;
  BitmapDescriptor markerIcon;
  String activeMarkerAddress;

  // Map Filter Settings
  double _range = 2500; // metres
  var oldRange;

  List allBrands = brandNames;
  List nearbyBrands = List.from(brandNames);
  bool nearbyBrandsChanged = false;
  bool emptyOnPurpose = false;

  // User position
  LocationData currentLocation;
  var location = new Location();
  var oldLat, oldLng;
  var lat, lng;

  // Nearby locations
  List<Marker> markers = <Marker>[];
  List<Result> places = <Result>[];
  static const String _API_KEY = 'AIzaSyDAOFoHvEyHFXh8C__rcct49FQ5QU5utjg';
  static const String baseUrl =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

  // Disallow list scrolling when panel closed
  bool _allowListScrolling = false;
  bool _listItemTapped = false;
  // Scroll list to top when panel closed
  ScrollController _scrollController;
  PanelController _panelController;

  String getSanitizedBrandName(String name) {
    name = sanitizeName(name);
    for (var sanitizedBrandName in sanitizedBrandNames) {
      if (name.contains(sanitizedBrandName)) {
        return sanitizedBrandName;
      }
    }

    return "";
  }

  String getBrandName(String sanitizedName) {
    for (int i = 0; i < sanitizedBrandNames.length; i++) {
      if (sanitizedName == sanitizedBrandNames[i]) {
        return brandNames[i];
      }
    }

    return "";
  }

  void getMarker() async {
    double windowHeight = window.physicalSize.height;

    int markerSize;
    if (windowHeight < 1500) {
      markerSize = 80;
    } else if (windowHeight >= 1500 && windowHeight < 2000) {
      markerSize = 90;
    } else {
      markerSize = 100;
    }

    final Uint8List markerIconBytes =
        await getBytesFromAsset('assets/map/marker.png', markerSize);
    markerIcon = BitmapDescriptor.fromBytes(markerIconBytes);

    final Uint8List activeMarkerIconBytes =
        await getBytesFromAsset('assets/map/active_marker.png', markerSize);
    activeMarkerIcon = BitmapDescriptor.fromBytes(activeMarkerIconBytes);
  }

  @override
  void initState() {
    super.initState();
    allBrands.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    getMarker();
    _scrollController = ScrollController();
    _panelController = PanelController();
    rootBundle.loadString('assets/map/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  void _handleResponse(data) {
    // bad api key or otherwise
    if (data['status'] == "REQUEST_DENIED") {
      setState(() {
        // Error
      });
      // success
    } else if (data['status'] == "OK") {
      List<Result> brandPlaces = PlaceResponse.parseResults(data['results']);
      List<Result> placesToRemove = new List<Result>();

      for (var place in brandPlaces) {
        var distance = getDistance(place.geometry.location.lat,
            place.geometry.location.long, lat, lng);

        if ((distance * 1000) > _range) {
          placesToRemove.add(place);
        } else {
          place.setDistanceFromMe(getDistance(place.geometry.location.lat,
              place.geometry.location.long, lat, lng));
        }
      }

      for (var place in placesToRemove) {
        brandPlaces.remove(place);
      }

      if (brandPlaces.length > 5) {
        brandPlaces = brandPlaces.sublist(0, 6);
      }

      places = List.from(places)..addAll(brandPlaces);
    }
  }

  void searchNearby(double latitude, double longitude) async {
    markers.clear();

    for (var keyword in nearbyBrands) {
      if (keyword != "skip" &&
          keyword != "menulog" &&
          keyword != "deliveroo" &&
          keyword != "ubereats") {
        if (keyword == "starbucks") {
          keyword += "coffee";
        }

        String url =
            '$baseUrl?key=$_API_KEY&location=$latitude,$longitude&radius=' +
                _range.toString() +
                '&keyword=$keyword';

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _handleResponse(data);
        } else {
          throw Exception('An error occurred getting places nearby');
        }
      }
    }

    places.sort((a, b) => a.distanceFromMe.compareTo(b.distanceFromMe));

    _showMarkers();
  }

  void _showMarkers() {
    setState(() {
      for (int i = 0; i < places.length; i++) {
        markers.add(
          Marker(
            icon: activeMarkerAddress == places[i].vicinity
                ? activeMarkerIcon
                : markerIcon,
            markerId: MarkerId(places[i].placeId),
            position: LatLng(places[i].geometry.location.lat,
                places[i].geometry.location.long),
            onTap: () {
              activeMarkerAddress = places[i].vicinity;
              _scrollController.animateTo(120.0 * i,
                  duration: Duration(milliseconds: 500), curve: Curves.easeIn);

              _showMarkers();
            },
          ),
        );
      }
    });
  }

  _getLocation() async {
    try {
      currentLocation = await location.getLocation();

      setState(() {
        lat = currentLocation.latitude;
        lng = currentLocation.longitude;

        _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 14.0,
          ),
        ));

        if (nearbyBrands.length > 0) {
          if (oldLat == null && oldLng == null) {
            oldLat = lat;
            oldLng = lng;
            oldRange = _range;
            searchNearby(lat, lng);
          } else if (lat != oldLat && lng != oldLng) {
            oldLat = lat;
            oldLng = lng;

            if (_range != oldRange && oldRange != null) {
              places.clear();
            }

            oldRange = _range;
            searchNearby(lat, lng);
          } else if (_range != oldRange) {
            if (oldRange != null) {
              places.clear();
            }

            oldRange = _range;
            searchNearby(lat, lng);
          } else if (nearbyBrandsChanged) {
            places.clear();
            nearbyBrandsChanged = false;

            searchNearby(lat, lng);
          } else {
            _showMarkers();
          }
        } else {
          places.clear();
        }
      }); //rebuild the widget after getting the current location of the user
    } on Exception {
      // Couldn't get location permissions, show Sydney
      lat = 33.8688;
      lng = 151.2093;
    }
  }

  Widget nearbyListItem(BuildContext context, String name, String streetAddress,
      double lat, double lng, double rating, double distance) {
    var sanitizedName = getSanitizedBrandName(name);

    if (sanitizedName == "redrooster") {
      sanitizedName = "redrooster2";
    } else if (sanitizedName == "pizzahut") {
      sanitizedName = "pizzahut2";
    }

    return Container(
        height: 110,
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 5),
                  width: MediaQuery.of(context).size.width - 140,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        AutoSizeText(
                          streetAddress,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                      ]),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      height: 90,
                      width: 65,
                      child: Center(
                        child: Image.asset(
                          'assets/brand_logos/' + sanitizedName + '.png',
                          height: 55,
                          width: 55,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      child: Container(
                        height: 90,
                        width: 30,
                        child: Center(
                          child: Icon(
                            CupertinoIcons.right_chevron,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push<Widget>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandPage(
                                    name: getBrandName(
                                        getSanitizedBrandName(name)),
                                  )),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
            Text(distance.toStringAsFixed(2) + " km away",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
          ],
        ));
  }

  Widget listItems() {
    if (places == null) {
      return Container(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (places.length == 0 && !emptyOnPurpose) {
      return Container(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (emptyOnPurpose) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text("No Restaurants in Search",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500)),
          SizedBox(
            height: 5,
          ),
          Text("Add a restaurant to start looking",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal)),
        ],
      );
    }

    // Display containers from the list
    return ListView.builder(
        addAutomaticKeepAlives: true,
        controller: _scrollController,
        physics: scrollPhysics(),
        itemCount: places.length > 0 ? places.length + 1 : 0,
        itemBuilder: (context, int i) {
          if (i == places.length) {
            return SizedBox(
              height: _flexHeight,
            );
          }

          return Container(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: nearbyListItem(
                    context,
                    places[i].name,
                    places[i].vicinity,
                    places[i].geometry.location.lat,
                    places[i].geometry.location.long,
                    places[i].rating,
                    places[i].distanceFromMe,
                  ),
                  onTap: () {
                    _listItemTapped = true;

                    activeMarkerAddress = places[i].vicinity;
                    _showMarkers();

                    _panelController.animatePanelToPosition(0);

                    _scrollController.animateTo(120.0 * i,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                    _mapController.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(places[i].geometry.location.lat,
                            places[i].geometry.location.long),
                        zoom: 15.0,
                      ),
                    ));
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 10,
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  ScrollPhysics scrollPhysics() {
    if (_allowListScrolling) {
      return BouncingScrollPhysics();
    }
    return NeverScrollableScrollPhysics();
  }

  Widget _buildSlidingPanel(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ButtonTheme(
              padding: EdgeInsets.all(0), //adds padding inside the button
              materialTapTargetSize: MaterialTapTargetSize
                  .shrinkWrap, //limits the touch area to the button area
              minWidth: 0, //wraps child's width
              height: 0, //wraps child's height
              child: RaisedButton(
                shape: new CircleBorder(),
                elevation: 1.0,
                color: getThemeColor(context),
                padding: const EdgeInsets.all(10.0),
                child: new Icon(
                  Icons.filter_list,
                  color: getColor("default"),
                  size: 35.0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      var _tempRange = _range;
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          title: Text("Filter"),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(15))),
                          content: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Range: " +
                                    (_tempRange / 1000).toString() +
                                    " km"),
                                Slider(
                                  activeColor: getColor("default"),
                                  min: 1000.0,
                                  max: 5000.0,
                                  divisions: 4,
                                  onChanged: (value) {
                                    setState(() => _tempRange = value);
                                  },
                                  value: _tempRange,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text("Include"),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Remove All",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: getColor("default")),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          nearbyBrands.clear();
                                          nearbyBrandsChanged = true;
                                          emptyOnPurpose = true;
                                        });
                                      },
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.35,
                                  width: 250,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: allBrands.length,
                                    itemBuilder: (BuildContext context, int i) {
                                      return ListTile(
                                        title: Text(allBrands[i]),
                                        leading: Checkbox(
                                          activeColor: getColor("default"),
                                          value: nearbyBrands
                                              .contains(allBrands[i]),
                                          onChanged: (bool value) {
                                            if (value) {
                                              setState(() {
                                                nearbyBrands.add(allBrands[i]);
                                                nearbyBrandsChanged = true;
                                                emptyOnPurpose = false;
                                              });
                                            } else {
                                              setState(() {
                                                nearbyBrands
                                                    .remove(allBrands[i]);
                                                nearbyBrandsChanged = true;
                                                if (nearbyBrands.length == 0) {
                                                  emptyOnPurpose = true;
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    RaisedButton(
                                      elevation: 0,
                                      color: getTextFieldColor(context),
                                      padding: const EdgeInsets.all(5.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          new BorderRadius.circular(
                                              10.0)),
                                      child: const Text('Cancel',
                                          style: TextStyle(fontSize: 18)),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SizedBox(width: 20,),
                                    RaisedButton(
                                      elevation: 0,
                                      textColor: Colors.white,
                                      color: getColor("default"),
                                      padding: const EdgeInsets.all(5.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          new BorderRadius.circular(
                                              10.0)),
                                      child: const Text('OK',
                                          style: TextStyle(fontSize: 18)),
                                      onPressed: () {
                                        setState(() {
                                          _range = _tempRange;
                                        });
                                        _getLocation();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: 10,
            ),
            ButtonTheme(
              padding: EdgeInsets.all(0), //adds padding inside the button
              materialTapTargetSize: MaterialTapTargetSize
                  .shrinkWrap, //limits the touch area to the button area
              minWidth: 0, //wraps child's width
              height: 0, //wraps child's height
              child: RaisedButton(
                shape: CircleBorder(),
                elevation: 1.0,
                color: getThemeColor(context),
                padding: const EdgeInsets.all(10.0),
                child: new Icon(
                  Icons.gps_fixed,
                  color: getColor("default"),
                  size: 35.0,
                ),
                onPressed: () {
                  _getLocation();
                },
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Flexible(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: getThemeColor(context),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            children: <Widget>[
              Center(
                  child: Container(
                child: Icon(
                  Icons.drag_handle,
                  color: getColor("default"),
                ),
              )),
              Flexible(child: listItems())
            ],
          ),
        )),
      ],
    ));
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: SlidingUpPanel(
          controller: _panelController,
          color: Colors.transparent,
          boxShadow: null,
          parallaxEnabled: true,
          maxHeight: MediaQuery.of(context).size.height - 150,
          minHeight: 198,
          onPanelClosed: () {
            setState(() {
              _flexHeight = 1000;
              _allowListScrolling = false;
            });
            if (!_listItemTapped) {
              _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn);
            }
            _listItemTapped = false;
          },
          onPanelOpened: () {
            setState(() {
              _flexHeight = 0;
              _allowListScrolling = true;
            });
          },
          panel: _buildSlidingPanel(context),
          body: Stack(
            children: <Widget>[
              GoogleMap(
                padding: EdgeInsets.only(bottom: 100),
                minMaxZoomPreference: MinMaxZoomPreference(6, 20),
                mapType: MapType.normal,
                mapToolbarEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(33.8688, 151.2093),
                  zoom: 14.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  _mapController.setMapStyle(_mapStyle);
                  _getLocation();
                },
                myLocationEnabled: true,
                markers: Set<Marker>.of(markers),
                myLocationButtonEnabled: false,
              ),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 10),
                child: Image.asset(
                  'assets/map/logo.png',
                  height: 40,
                  width: 55,
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      body: _buildBody(context),
    );
  }
}
