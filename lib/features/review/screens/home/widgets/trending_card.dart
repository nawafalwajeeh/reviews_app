import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/place/place_card.dart'
    show PlaceCard;

import '../../../models/place_model.dart';

class TrendingCard extends StatelessWidget {
  const TrendingCard({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 300, height: 200, child: PlaceCard(place: place));
  }
}
