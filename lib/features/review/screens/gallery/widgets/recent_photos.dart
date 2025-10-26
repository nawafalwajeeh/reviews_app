import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'gallery_widgets.dart';

class RecentPhotosSection extends StatelessWidget {
  const RecentPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSectionHeading(title: 'Recent Photos', onPressed: () {}),
          SizedBox(height: 16),
          FeaturedImageCarousel(),
        ],
      ),
    );
  }
}

class FeaturedImageCarousel extends StatefulWidget {
  const FeaturedImageCarousel({super.key});

  @override
  State<FeaturedImageCarousel> createState() => _FeaturedImageCarouselState();
}

class _FeaturedImageCarouselState extends State<FeaturedImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<FeaturedImage> _featuredImages = [
    FeaturedImage(
      imageUrl:
          'https://images.unsplash.com/photo-1628945647517-697bf1a7d905?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      title: 'Mountain Sunrise',
      subtitle: 'Captured at Golden Hour',
    ),
    FeaturedImage(
      imageUrl:
          'https://images.unsplash.com/photo-1563302485-df734143a240?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      title: 'Ocean Waves',
      subtitle: 'Peaceful Beach Moment',
    ),
    FeaturedImage(
      imageUrl:
          'https://images.unsplash.com/photo-1621248439845-00ad5009e2f6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      title: 'Forest Path',
      subtitle: 'Morning Adventure',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: _featuredImages
                .map((image) => FeaturedImageCard(featuredImage: image))
                .toList(),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _PageIndicator(
              controller: _pageController,
              count: _featuredImages.length,
              currentPage: _currentPage,
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedImageCard extends StatelessWidget {
  final FeaturedImage featuredImage;

  const FeaturedImageCard({super.key, required this.featuredImage});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(featuredImage.imageUrl),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
              stops: const [0, 1],
              begin: AlignmentDirectional.topCenter,
              end: AlignmentDirectional.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featuredImage.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  featuredImage.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final int currentPage;

  const _PageIndicator({
    required this.controller,
    required this.count,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        expansionFactor: 2.5,
        spacing: 8,
        radius: 12,
        dotWidth: 12,
        dotHeight: 6,
        dotColor: Colors.black.withValues(alpha: 0.3),
        activeDotColor: Theme.of(context).colorScheme.primary,
        paintStyle: PaintingStyle.fill,
      ),
    );
  }
}
