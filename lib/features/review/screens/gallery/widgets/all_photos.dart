import 'package:flutter/material.dart';

import 'gallery_widgets.dart';

class AllPhotosSection extends StatelessWidget {
  const AllPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SectionHeader(title: 'All Photos'),
          SizedBox(height: 16),
          PhotoGrid(),
        ],
      ),
    );
  }
}

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrls = [
      'https://images.unsplash.com/photo-1716386480079-9e12aa53a9b4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1552657490-8a0cf383c33a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1599834027865-61d3931db8cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1718875727989-f0a679020075?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1714201624095-11407e335eff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1701401901550-16330a541ae3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1657665675084-2a9dec00f211?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1570922958075-787eb527f829?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
      'https://images.unsplash.com/photo-1642399403814-360bc87e12fb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: photoUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(photoUrls[index]),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
