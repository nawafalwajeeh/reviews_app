import 'package:get/get.dart';

import '../models/place_model.dart';

class PlaceController extends GetxController {
  static PlaceController get instance => Get.find();

  //   final demoPlaces = [
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1470338745628-171cf53de3a8?auto=format&fit=crop&w=800&q=80',
  //     title: 'Bella Vista Restaurant',
  //     location: 'Downtown • 2.5 km away',
  //     category: 'Italian Cuisine',
  //     subtitle: 'Open until 11:00 PM',
  //     rating: 4.8,
  //   ),
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1468273519810-d3fe4c125cdb?auto=format&fit=crop&w=800&q=80',
  //     title: 'Riverside Elementary School',
  //     location: 'Westside • 1.8 km away',
  //     category: 'Public School',
  //     subtitle: 'Grades K-5 • Excellent Rating',
  //     rating: 4.6,
  //   ),
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
  //     title: 'The Coffee Corner',
  //     location: 'City Center • 0.8 km away',
  //     category: 'Coffee & Pastries',
  //     subtitle: 'Open 24/7 • Free WiFi',
  //     rating: 4.9,
  //     isFavorite: true,
  //   ),
  //   Place(
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1614957004131-9e8f2a13123c?auto=format&fit=crop&w=800&q=80',
  //     title: 'Grand Plaza Hotel',
  //     location: 'Business District • 3.2 km away',
  //     category: 'Luxury Hotel',
  //     subtitle: '5-Star • Pool & Spa',
  //     rating: 4.7,
  //   ),
  // ];

  // Demo place data (NOTE: These asset paths must exist in your Flutter project)
  final demoPlaces = [
    PlaceModel(
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      category: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
      pricePerNight: 450.00,
    ),
    PlaceModel(
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      category: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
      pricePerNight: 450.00,
    ),
    PlaceModel(
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      category: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
      pricePerNight: 450.00,
    ),
    PlaceModel(
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      category: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
      pricePerNight: 450.00,
    ),
  ];

  final List<String> categories = const [
    'All',
    'Restaurant',
    'Hotel',
    'School',
    'Cafe',
    'Park',
  ];
}
