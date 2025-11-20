import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/place/place_card.dart'
    show PlaceCard;

import '../../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../controllers/place_controller.dart';
import '../../../models/place_model.dart';
import '../../place/edit_place.dart';

class TrendingCard extends StatelessWidget {
  const TrendingCard({super.key, required this.place});

  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    bool isCreator =
        (place.userId == AuthenticationRepository.instance.getUserID);

    return SizedBox(
      width: 300,
      height: 200,
      child: PlaceCard(
        place: place,
        showEditOptions: isCreator,
        onEdit: () {
          if (isCreator) {
            controller.initializeEditForm(place);
            Get.to(() => EditPlaceScreen(place: place));
          }
        },
        onDelete: () {
          if (isCreator) {
            controller.deletePlaceWithConfirmation(place);
          }
        },
      ),
    );
  }
}
