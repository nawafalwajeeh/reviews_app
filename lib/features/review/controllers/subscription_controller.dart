// controllers/subscription_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../models/subscription_model.dart';
import '../screens/subscription/subscription.dart';

class SubscriptionController extends GetxController {
  static SubscriptionController get instance => Get.find();

  // Subscription plans
  final RxList<SubscriptionPlan> subscriptionPlans = <SubscriptionPlan>[].obs;
  final Rx<SubscriptionPlan?> selectedPlan = Rx<SubscriptionPlan?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // In-app purchase products
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // final RxBool hasActiveSubscription = false.obs;
  final RxBool hasActiveSubscription = true.obs;
  final Rx<DateTime?> subscriptionExpiry = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeSubscriptionPlans();
    _initializeInAppPurchase();
    checkUserSubscriptionStatus();
  }

  void _initializeSubscriptionPlans() {
    subscriptionPlans.assignAll([
      SubscriptionPlan(
        id: 'premium_annual',
        name: 'Annual Plan',
        description: 'Best value for serious reviewers',
        price: 59.99,
        originalPrice: 99.99,
        period: 'year',
        savingsPercent: 40,
        features: [
          'All premium features included',
          'Save 40% compared to monthly',
          'Billed annually',
          '7-day free trial',
        ],
        isPopular: true,
      ),
      SubscriptionPlan(
        id: 'premium_monthly',
        name: 'Monthly Plan',
        description: 'Perfect for trying premium features',
        price: 9.99,
        period: 'month',
        features: [
          'All premium features included',
          'Flexible monthly billing',
          'Cancel anytime',
          '7-day free trial',
        ],
        isPopular: false,
      ),
    ]);
  }

  Future<void> _initializeInAppPurchase() async {
    try {
      // Check availability
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) return;

      // Load products
      const Set<String> productIds = {'premium_annual', 'premium_monthly'};
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      products.assignAll(response.productDetails);
    } catch (e) {
      print('In-app purchase initialization error: $e');
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Find the product for this plan
      final product = products.firstWhere(
        (p) => p.id == plan.id,
        orElse: () => throw Exception('Product not found'),
      );

      // Make purchase
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      // Handle successful purchase
      await _handleSuccessfulPurchase(plan);
    } catch (e) {
      errorMessage.value = 'Subscription failed: ${e.toString()}';
      print('Subscription error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleSuccessfulPurchase(SubscriptionPlan plan) async {
    try {
      // Update user subscription in Firestore
      final userId = AuthenticationRepository.instance.getUserID;
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'subscription': {
          'planId': plan.id,
          'planName': plan.name,
          'isActive': true,
          'purchasedAt': DateTime.now(),
          'expiresAt': _calculateExpiryDate(plan.period),
          'features': plan.features,
        },
        'updatedAt': DateTime.now(),
      });

      // Show success message
      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'You now have ${plan.name}',
      );

      // Navigate back or to premium features
      Get.back();
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  DateTime _calculateExpiryDate(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'month':
        return now.add(Duration(days: 30));
      case 'year':
        return now.add(Duration(days: 365));
      default:
        return now.add(Duration(days: 30));
    }
  }

  // Check if user has active subscription
  Future<bool> checkUserSubscription() async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final subscription = userDoc.data()?['subscription'];
        if (subscription != null) {
          final expiresAt = (subscription['expiresAt'] as Timestamp).toDate();
          return expiresAt.isAfter(DateTime.now());
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user has active subscription
  Future<void> checkUserSubscriptionStatus() async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final subscription = userDoc.data()?['subscription'];
        if (subscription != null) {
          final expiresAt = (subscription['expiresAt'] as Timestamp).toDate();
          final isActive = expiresAt.isAfter(DateTime.now());

          hasActiveSubscription.value = isActive;
          subscriptionExpiry.value = expiresAt;

          if (!isActive) {
            print('Subscription expired on: $expiresAt');
          }
        } else {
          hasActiveSubscription.value = false;
          subscriptionExpiry.value = null;
        }
      }
    } catch (e) {
      print('Error checking subscription: $e');
      hasActiveSubscription.value = false;
    }
  }

  // Check if user can create places (has active subscription)
  Future<bool> canCreatePlace() async {
    await checkUserSubscriptionStatus();
    return hasActiveSubscription.value;
  }

  // Show subscription required dialog
  void showSubscriptionRequired(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: AppColors.primaryColor),
            SizedBox(width: AppSizes.sm),
            Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message ?? 'Creating new places is a premium feature.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Upgrade to Premium to unlock:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: AppSizes.xs),
            _buildFeatureList(context),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => SubscriptionScreen());
            },
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem('Unlimited place creation'),
        _buildFeatureItem('Advanced review features'),
        _buildFeatureItem('Priority support'),
        _buildFeatureItem('Ad-free experience'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
