// image_viewer_screen.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? title;
  final String? subtitle;
  final double? rating;
  final bool isFromGallery; // New flag to indicate gallery mode
  final Map<int, Map<String, dynamic>>?
  galleryMetadata; // Metadata for gallery images

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
  final TransformationController _transformationController =
      TransformationController();
  late PageController _pageController;
  bool _isZoomed = false;
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.white),
            const SizedBox(height: AppSizes.md),
            Text(
              txt.failedToLoadImage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInteractiveImage(String imageUrl) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      onInteractionUpdate: (details) {
        setState(() {
          _isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.0;
        });
      },
      child: _buildImage(imageUrl),
    );
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

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _isZoomed = false);
  }

  void _toggleZoom() {
    if (_isZoomed) {
      _resetZoom();
    } else {
      _transformationController.value = Matrix4.identity().scaledByDouble(
        2.0,
        0.0,
        0.0,
        0.0,
      );
      setState(() => _isZoomed = true);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Reset zoom when switching images
      if (_isZoomed) {
        _resetZoom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView for swiping between images
            GestureDetector(
              onTap: () {
                if (!_isZoomed) Get.back();
              },
              onDoubleTap: _toggleZoom,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return Center(
                    child: _buildInteractiveImage(widget.imageUrls[index]),
                  );
                },
              ),
            ),

            // Top Actions
            Positioned(
              top: AppSizes.defaultSpace,
              left: AppSizes.defaultSpace,
              right: AppSizes.defaultSpace,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Get.back(),
                  ),

                  // Page Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ),

                  // Right Actions
                  Row(
                    children: [
                      // Share Button
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        onPressed: _shareImage,
                      ),
                      const SizedBox(width: AppSizes.sm),

                      // Download Button
                      _buildActionButton(
                        icon: Icons.download_rounded,
                        onPressed: _isLoading ? null : _downloadImage,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Image Info Bottom Sheet (if provided)
            if (widget.title != null ||
                widget.subtitle != null ||
                widget.rating != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildImageInfo(),
              ),

            // Zoom Controls
            if (_isZoomed)
              Positioned(
                bottom: 100,
                right: AppSizes.defaultSpace,
                child: _buildActionButton(
                  icon: Icons.zoom_out_map_rounded,
                  onPressed: _resetZoom,
                  backgroundColor: Colors.black54,
                ),
              ),

            // Help Hint (disappears after first tap)
            if (!_isZoomed && widget.imageUrls.length > 1)
              Positioned(
                bottom: AppSizes.defaultSpace,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      txt.doubleTapToZoom,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      txt.tapToClose,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      txt.swipeLeftOrRightToViewImages,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color backgroundColor = Colors.black54,
    bool isLoading = false,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : IconButton(
              icon: Icon(icon, size: 22, color: Colors.white),
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
    );
  }

  // In _buildImageInfo() method, update to handle gallery metadata:
  Widget _buildImageInfo() {
    final txt = AppLocalizations.of(context);
    if (widget.isFromGallery && widget.galleryMetadata != null) {
      final metadata = widget.galleryMetadata![_currentIndex];
      if (metadata != null) {}
    }

    return Container(
      margin: const EdgeInsets.all(AppSizes.defaultSpace),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use gallery metadata if available, otherwise use widget properties
          if (widget.title != null)
            Text(
              widget.title.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          if (widget.subtitle != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              widget.subtitle.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (widget.rating != null) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: AppSizes.xs),
                Text(
                  (widget.rating)!.toStringAsFixed(1),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '• Image ${_currentIndex + 1} of ${widget.imageUrls.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
