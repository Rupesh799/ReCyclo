// Method for calculating distance (Haversine formula)
  import 'dart:math';

double calculateDistance(
      double startLat, double startLon, double endLat, double endLon) {
    const double earthRadius = 6371.0; // Earth radius in kilometers

    // Convert degrees to radians
    double toRadians(double degree) {
      return degree * (pi / 180.0);
    }

    // Haversine formula
    num haversine(double theta) {
      return pow(sin(theta / 2), 2);
    }

    double haversineDistance(
        double lat1, double lon1, double lat2, double lon2) {
      double dLat = toRadians(lat2 - lat1);
      double dLon = toRadians(lon2 - lon1);

      double a = haversine(dLat) +
          cos(toRadians(lat1)) * cos(toRadians(lat2)) * haversine(dLon);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));

      return earthRadius * c;
    }

    return haversineDistance(startLat, startLon, endLat, endLon);
  }