import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';

import 'gallery_widgets.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSectionHeading(
            title: 'Collections',
            buttonTitle: 'Manage',
            onPressed: () {},
          ),
          SizedBox(height: 16),
          CollectionsGrid(),
        ],
      ),
    );
  }
}

class CollectionsGrid extends StatelessWidget {
  const CollectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = [
      CollectionItem(
        imageUrl:
            'https://images.unsplash.com/photo-1592211801285-1353c35743a7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
        title: 'Travel',
        photoCount: 24,
      ),
      CollectionItem(
        imageUrl:
            'https://images.unsplash.com/photo-1673465792556-e9545649b179?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
        title: 'Food',
        photoCount: 18,
      ),
      CollectionItem(
        imageUrl:
            'https://images.unsplash.com/photo-1619856266537-0111fc5a4c67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=500',
        title: 'Portraits',
        photoCount: 32,
      ),
    ];

    return Row(
      children: collections
          .map(
            (collection) =>
                Expanded(child: CollectionCard(collection: collection)),
          )
          .toList(),
      // .separate(const SizedBox(width: 16)),
    );
  }
}

class CollectionCard extends StatelessWidget {
  final CollectionItem collection;

  const CollectionCard({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(collection.imageUrl),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
            stops: const [0, 1],
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                collection.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${collection.photoCount} photos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
