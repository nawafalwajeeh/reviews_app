// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:reviews_app/features/review/controllers/map_controller.dart';

// class GooglePlacesService {
//   static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
//   static final http.Client _client = http.Client();

//   // Search places with filters
//   static Future<List<SearchSuggestion>> searchPlaces(
//     String query, {
//     LatLng? location,
//     MapFilter? filter,
//   }) async {
//     try {
//       final params = {
//         'input': query,
//         'key': 'YOUR_GOOGLE_API_KEY',
//         'types': 'establishment|geocode',
//         'language': 'en',
//       };

//       if (location != null) {
//         params['location'] = '${location.latitude},${location.longitude}';
//         params['radius'] = '50000';
//       }

//       if (filter != null && filter.category != 'all') {
//         params['type'] = filter.category;
//       }

//       final uri = Uri.parse('$_baseUrl/autocomplete/json').replace(queryParameters: params);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           return _parsePredictions(data['predictions']);
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Places search error: $e');
//       return await _fallbackGeocodingSearch(query);
//     }
//   }

//   // Search nearby places
//   static Future<List<PlaceDetails>> searchNearbyPlaces(
//     LatLng location, {
//     required String category,
//     double radius = 5000.0,
//   }) async {
//     try {
//       final params = {
//         'location': '${location.latitude},${location.longitude}',
//         'radius': radius.toString(),
//         'key': 'YOUR_GOOGLE_API_KEY',
//         'type': category,
//       };

//       final uri = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           return await _parseNearbyResults(data['results']);
//         }
//       }
//       return [];
//     } catch (e) {
//       print('Nearby search error: $e');
//       return [];
//     }
//   }

//   // Get directions
//   static Future<Direction?> getDirections(LatLng origin, LatLng destination) async {
//     try {
//       final params = {
//         'origin': '${origin.latitude},${origin.longitude}',
//         'destination': '${destination.latitude},${destination.longitude}',
//         'key': 'YOUR_GOOGLE_API_KEY',
//         'mode': 'driving',
//       };

//       final uri = Uri.parse('https://maps.googleapis.com/maps/api/directions/json')
//           .replace(queryParameters: params);
//       final response = await _client.get(uri);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'OK') {
//           return _parseDirection(data);
//         }
//       }
//       return null;
//     } catch (e) {
//       print('Directions error: $e');
//       return null;
//     }
//   }

//   // Parse methods would go here...
//   static List<SearchSuggestion> _parsePredictions(List predictions) {
//     return predictions.map((prediction) {
//       return SearchSuggestion(
//         id: prediction['place_id'] ?? const Uuid().v4(),
//         title: prediction['description'],
//         type: 'place',
//         placeId: prediction['place_id'],
//       );
//     }).toList();
//   }

//   static Future<List<PlaceDetails>> _parseNearbyResults(List results) async {
//     final places = <PlaceDetails>[];
    
//     for (final result in results) {
//       final geometry = result['geometry']['location'];
//       places.add(PlaceDetails(
//         name: result['name'] ?? 'Unknown Place',
//         address: result['vicinity'],
//         location: LatLng(geometry['lat'], geometry['lng']),
//         rating: result['rating']?.toDouble(),
//         totalRatings: result['user_ratings_total'],
//         placeId: result['place_id'],
//         types: List<String>.from(result['types'] ?? []),
//         businessStatus: result['business_status'],
//         priceLevel: result['price_level'],
//       ));
//     }
    
//     return places;
//   }

//   static Direction _parseDirection(Map<String, dynamic> data) {
//     final route = data['routes'][0];
//     final leg = route['legs'][0];
    
//     final points = _decodePolyline(route['overview_polyline']['points']);
    
//     return Direction(
//       polylinePoints: points,
//       distance: leg['distance']['text'],
//       duration: leg['duration']['text'],
//       instructions: leg['steps'][0]['html_instructions'],
//       travelMode: 'driving',
//     );
//   }

//   static List<LatLng> _decodePolyline(String encoded) {
//     // Polyline decoding logic
//     return [];
//   }

//   static Future<List<SearchSuggestion>> _fallbackGeocodingSearch(String query) async {
//     try {
//       final locations = await locationFromAddress(query);
//       return locations.map((location) {
//         return SearchSuggestion(
//           id: const Uuid().v4(),
//           title: query,
//           location: LatLng(location.latitude, location.longitude),
//           type: 'address',
//         );
//       }).toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   // Existing methods...
//   static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
//     // Implementation
//     return null;
//   }

//   static Future<String?> getAddressFromLatLng(LatLng location) async {
//     // Implementation
//     return null;
//   }
// }