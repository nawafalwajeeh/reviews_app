class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String period;
  final int? savingsPercent;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.period,
    this.savingsPercent,
    required this.features,
    this.isPopular = false,
  });

  String get displayPrice {
    if (period == 'year') {
      return '\$$price/year';
    } else {
      return '\$$price/month';
    }
  }

  String get monthlyEquivalent {
    if (period == 'year') {
      final monthly = price / 12;
      return '\$${monthly.toStringAsFixed(2)}/month';
    }
    return displayPrice;
  }
}
