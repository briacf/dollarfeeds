import 'dart:math';

/*
Get distance (in km) between 2 lat, lng coordinates
 */
double getDistance(lat1,lon1,lat2,lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = degToRad(lat2-lat1);  // deg2rad below
  var dLon = degToRad(lon2-lon1);
  var a =
      sin(dLat/2) * sin(dLat/2) +
          cos(degToRad(lat1)) * cos(degToRad(lat2)) *
              sin(dLon/2) * sin(dLon/2)
  ;
  var c = 2 * atan2(sqrt(a), sqrt(1-a));
  var d = R * c; // Distance in km
  return d;
}

/*
Convert degrees to radians
 */
double degToRad(deg) {
  return deg * (pi/180);
}