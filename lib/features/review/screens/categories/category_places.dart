import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/horizontal_place_card.dart';
import 'package:reviews_app/common/widgets/shimmers/horizontal_place_shimmer.dart';
import 'package:reviews_app/features/review/models/category_extension.dart';
import 'package:reviews_app/features/review/models/place_model.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';
import '../../../../common/widgets/place/category/category_card.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../controllers/place_controller.dart';
import '../../models/category_mapper.dart';
import '../place/edit_place.dart';

class CategoryPlacesScreen extends StatefulWidget {
  const CategoryPlacesScreen({super.key, required this.category});

  final CategoryModel category;

  @override
  State<CategoryPlacesScreen> createState() => _CategoryPlacesScreenState();
}

class _CategoryPlacesScreenState extends State<CategoryPlacesScreen> {
  late Stream<List<PlaceModel>> _placesStream;
  final controller = CategoryController.instance;

  @override
  void initState() {
    super.initState();
    _placesStream = controller.streamCategoryPlaces(
      categoryId: widget.category.id,
    );
  }

  Future<void> _refreshData() async {
    // Re-initialize the stream to force a re-subscription and check for new data
    setState(() {
      _placesStream = controller.streamCategoryPlaces(
        categoryId: widget.category.id,
      );
    });
    // Wait for the stream to emit a value or a timeout to dismiss the indicator nicely
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current authenticated user's ID
    final currentUserId = AuthenticationRepository.instance.getUserID;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          widget.category.getLocalizedName(context),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spaceBtwSections * 4),
                // Category Card Banner
                Center(
                  child: CategoryCard(
                    height: 120,
                    width: 120,
                    titleSize: 100,
                    title: widget.category.getLocalizedName(context),
                    icon: CategoryMapper.getIcon(widget.category.iconKey),
                    gradientColors: CategoryMapper.getGradientColors(
                      widget.category.gradientKey,
                    ),
                    iconColor: CategoryMapper.getIconColor(
                      widget.category.iconColorValue,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),

                // --- StreamBuilder for Real-Time Updates ---
                StreamBuilder<List<PlaceModel>>(
                  key: ValueKey(
                    _placesStream,
                  ), // Ensure rebuild when stream changes
                  stream: _placesStream,
                  builder: (context, snapshot) {
                    const loader = AppHorizontalPlaceShimmer();

                    final widget =
                        AppCloudHelperFunctions.checkMultiRecordState(
                          snapshot: snapshot,
                          loader: loader,
                        );
                    // If the state is loading, error, or no data, return the widget.
                    if (widget != null) return widget;

                    final categoryPlaces = snapshot.data!;

                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        itemCount: categoryPlaces.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                          left: AppSizes.defaultSpace,
                        ),
                        itemBuilder: (context, index) {
                          final place = categoryPlaces[index];

                          // Determine if the current user is the creator
                          final creatorId = place.userId;
                          final isCreator = creatorId == currentUserId;

                          return PlaceCardHorizontal(
                            place: place,
                            showEditOptions: isCreator,

                            onEdit: () {
                              if (isCreator) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPlaceScreen(place: place),
                                  ),
                                );
                              }
                            },

                            onDelete: () => isCreator
                                ? PlaceController.instance
                                      .deletePlaceWithConfirmation(place)
                                : () {},
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSizes.spaceBtwSections),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
