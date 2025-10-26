import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:reviews_app/features/review/screens/gallery/widgets/collection_section.dart';
import '../../../../utils/constants/sizes.dart';
import 'widgets/all_photos.dart';
import 'widgets/recent_photos.dart';

class ImageGalleryScreen extends StatelessWidget {
  const ImageGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => _unfocus(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            AppPrimaryHeaderContainer(
              child: Column(
                children: [
                  CustomAppBar(
                    leadingIcon: Icons.arrow_back_ios,
                    leadingOnPressed: () => Get.back(),
                    centerTitle: true,
                    title: Text(
                      'Gallery',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceBtwItems),

                  AppSearchContainer(text: 'Search photos'),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                ],
              ),
            ),
            Expanded(child: GalleryContent()),
          ],
        ),
      ),
    );
  }

  // void _unfocus(BuildContext context) {
  //   FocusScope.of(context).unfocus();
  //   FocusManager.instance.primaryFocus?.unfocus();
  // }
}

class GalleryContent extends StatelessWidget {
  const GalleryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const RecentPhotosSection(),
            const SizedBox(height: 24),
            const CollectionsSection(),
            const SizedBox(height: 24),
            const AllPhotosSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

//--------------------------
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class GalleryScreen extends StatefulWidget {
//   final int maxImages;
//   final List<XFile> initiallySelected;
//
//   const GalleryScreen({
//     super.key,
//     this.maxImages = 5,
//     this.initiallySelected = const [],
//   });
//
//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }
//
// class _GalleryScreenState extends State<GalleryScreen> {
//   final ImagePicker _picker = ImagePicker();
//   List<XFile> selectedImages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     selectedImages = [...widget.initiallySelected];
//   }
//
//   Future<void> pickImages() async {
//     final List<XFile> pickedImages = await _picker.pickMultiImage(
//       imageQuality: 80,
//     );
//     setState(() {
//       selectedImages = pickedImages.take(widget.maxImages).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Photos'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context, selectedImages);
//             },
//             child: const Text('Done', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: pickImages,
//             child: const Text('Pick Images from Gallery'),
//           ),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(8),
//               itemCount: selectedImages.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemBuilder: (context, index) {
//                 return Image.file(
//                   File(selectedImages[index].path),
//                   fit: BoxFit.cover,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
