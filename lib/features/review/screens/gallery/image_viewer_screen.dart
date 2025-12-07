// image_viewer_screen.dart
import 'dart:io';
import 'dart:ui' as dart_ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? title;
  final String? subtitle;
  final double? rating;
  final bool isFromGallery;
  final Map<int, Map<String, dynamic>>? galleryMetadata;

  const ImageViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.title,
    this.subtitle,
    this.rating,
    this.isFromGallery = false,
    this.galleryMetadata,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late ScrollController _thumbnailController;
  late int _currentIndex;
  bool _isLoading = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _thumbnailController = ScrollController();

    // Scroll to initial thumbnail after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(_currentIndex);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _scrollToThumbnail(index);
  }

  void _scrollToThumbnail(int index) {
    if (_thumbnailController.hasClients) {
      const double thumbnailWidth = 72.0; // 60 width + 12 margin
      final double screenWidth = MediaQuery.of(context).size.width;
      final double scrollOffset =
          (index * thumbnailWidth) - (screenWidth / 2) + (thumbnailWidth / 2);

      _thumbnailController.animateTo(
        scrollOffset.clamp(0.0, _thumbnailController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<void> _downloadImage() async {
    setState(() => _isLoading = true);

    try {
      final currentImageUrl = widget.imageUrls[_currentIndex];
      final File file = await DefaultCacheManager().getSingleFile(
        currentImageUrl,
      );
      await Gal.putImage(file.path);

      if (mounted) {
        AppLoaders.successSnackBar(
          title: AppLocalizations.of(context).success,
          message: AppLocalizations.of(context).imageDownloaded,
        );
      }
    } on GalException catch (e) {
      if (mounted) {
        AppLoaders.errorSnackBar(
          title: AppLocalizations.of(context).error,
          message: e.type.message,
        );
      }
    } catch (e) {
      if (mounted) {
        AppLoaders.errorSnackBar(
          title: AppLocalizations.of(context).error,
          message: AppLocalizations.of(context).failedToDownload,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      final currentImageUrl = widget.imageUrls[_currentIndex];
      final File file = await DefaultCacheManager().getSingleFile(
        currentImageUrl,
      );
      final tempDir = await getTemporaryDirectory();
      final shareFile = File('${tempDir.path}/share_image.jpg');
      await shareFile.writeAsBytes(await file.readAsBytes());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(shareFile.path)],
          text: widget.title ?? txt.shareImage,
        ),
      );

      if (mounted) {
        AppLoaders.successSnackBar(
          title: AppLocalizations.of(context).success,
          message: AppLocalizations.of(context).imageShared,
        );
      }
    } catch (e) {
      if (mounted) {
        AppLoaders.errorSnackBar(
          title: AppLocalizations.of(context).error,
          message: AppLocalizations.of(context).failedToShare,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppHelperFunctions.isDarkMode(context);
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    // Glassmorphism background colors
    final barBackgroundColor = isDark
        ? Colors.black.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.7);

    // Determine title to display
    String? displayTitle = widget.title;
    if (widget.isFromGallery && widget.galleryMetadata != null) {
      displayTitle = widget.galleryMetadata![_currentIndex]?['placeName'];
    }

    debugPrint('place_info: $displayTitle');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main Gallery
          GestureDetector(
            onTap: _toggleControls,
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    widget.imageUrls[index],
                  ),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.imageUrls[index],
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            txt.failedToLoadImage,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              itemCount: widget.imageUrls.length,
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              backgroundDecoration: BoxDecoration(color: backgroundColor),
              pageController: _pageController,
              onPageChanged: _onPageChanged,
            ),
          ),

          // Top Bar (Glassmorphism)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showControls ? 0 : -120,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: barBackgroundColor,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + AppSizes.xs,
                    bottom: AppSizes.sm,
                    left: AppSizes.sm,
                    right: AppSizes.sm,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close Button
                        _buildActionButton(
                          icon: Icons.close_rounded,
                          onPressed: () => Get.back(),
                          backgroundColor: Colors.transparent,
                          iconColor: iconColor,
                        ),

                        // Title (Centered)
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayTitle!,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Counter
                              Text(
                                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right Actions (Share & Download)
                        Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.share_outlined,
                              onPressed: _shareImage,
                              backgroundColor: Colors.transparent,
                              iconColor: iconColor,
                            ),
                            _buildActionButton(
                              icon: Icons.download_rounded,
                              onPressed: _isLoading ? null : _downloadImage,
                              isLoading: _isLoading,
                              backgroundColor: Colors.transparent,
                              iconColor: iconColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Info Bar (Glassmorphism)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showControls ? 0 : -200,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: barBackgroundColor,
                  padding: EdgeInsets.only(
                    top: AppSizes.sm,
                    bottom: MediaQuery.of(context).padding.bottom + AppSizes.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail Strip
                      if (widget.imageUrls.length > 1)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            controller: _thumbnailController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.defaultSpace,
                            ),
                            itemCount: widget.imageUrls.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _currentIndex;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 12),
                                  width: isSelected ? 70 : 60,
                                  height: isSelected ? 70 : 60,
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrls[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.error,
                                            color: textColor.withValues(
                                              alpha: 0.5,
                                            ),
                                            size: 20,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Image Info (Subtitle & Rating)
                      if (widget.subtitle != null || widget.rating != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSizes.sm,
                            left: AppSizes.md,
                            right: AppSizes.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (widget.rating != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.rating!.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    bool isLoading = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black54,
        shape: BoxShape.circle,
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor ?? Colors.white,
                ),
              ),
            )
          : IconButton(
              icon: Icon(icon, size: 20, color: iconColor ?? Colors.white),
              onPressed: onPressed,
              padding: EdgeInsets.zero,
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }
}
