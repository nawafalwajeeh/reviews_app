import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/popups/loaders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reviews_app/common/widgets/place/category/category_tag.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../../common/widgets/list_tiles/place_meta_data_tile.dart';
import '../../../models/place_model.dart';

class PlaceMetadata extends StatelessWidget {
  const PlaceMetadata({super.key, required this.place});
  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          place.title,
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSizes.sm),

        // Category Tag
        Obx(
          () => CategoryTagWidget(text: controller.selectedCategoryName.value),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        // Location
        PlaceDetailsMetadataTile(
          text: place.address.toString(),
          icon: Iconsax.location,
        ),

        const SizedBox(height: AppSizes.spaceBtwItems),

        // Phone Number - Now clickable
        if (place.phoneNumber?.isNotEmpty ?? false)
          Column(
            children: [
              PlaceDetailsMetadataTile(
                text: place.phoneNumber!,
                icon: Iconsax.mobile,
                showTrailing: true,
                trailingIcon: Icons.phone_outlined,
                onTap: () => _launchPhone(context, place.phoneNumber!),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
            ],
          ),

        // Date - Formatted without time
        PlaceDetailsMetadataTile(
          text: 'Date: ${_formatDate(place.dateAdded)}',
          icon: Iconsax.calendar,
        ),
      ],
    );
  }

  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    try {
      // Show better looking options dialog
      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Icon(Icons.phone_rounded, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Contact Options',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  phoneNumber, // Show the actual phone number
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how to contact',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Call Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _makePhoneCall(phoneNumber); // Use original number
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // WhatsApp Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _openWhatsApp(phoneNumber); // Use original number
                    },
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Message Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _sendSMS(context, phoneNumber); // Use original number
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: 'Failed to launch phone options: $e',
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Use the phone number exactly as provided - NO MODIFICATION
      final url = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        AppLoaders.warningSnackBar(
          title: 'Oh Snap!',
          message: 'Could not make call to $phoneNumber',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: 'Failed to make call: $e',
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Use the phone number exactly as provided - NO MODIFICATION
      // WhatsApp will handle the formatting automatically
      final url = Uri.parse('https://wa.me/$phoneNumber');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        AppLoaders.warningSnackBar(
          title: 'Oh Snap!',
          message: 'WhatsApp is not installed',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: 'Failed to open WhatsApp: $e',
      );
    }
  }

  Future<void> _sendSMS(BuildContext context, String phoneNumber) async {
    try {
      // Try multiple SMS URI formats that work with different SMS apps
      final smsUris = [
        Uri.parse('sms:$phoneNumber'),
        Uri.parse('sms:$phoneNumber?body='),
        Uri.parse('smsto:$phoneNumber'),
      ];

      bool launchedSuccessfully = false;

      for (final uri in smsUris) {
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            launchedSuccessfully = true;
            break;
          }
        } catch (e) {
          continue;
        }
      }

      if (!launchedSuccessfully) {
        // Show beautiful no SMS app dialog
        await _showNoSmsAppDialog(context, phoneNumber);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Message Failed',
        message: 'Could not open messaging app: ${e.toString()}',
      );
    }
  }

  Future<void> _showNoSmsAppDialog(
    BuildContext context,
    String phoneNumber,
  ) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message_outlined,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'No Messaging App',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'We couldn\'t find a messaging app on your device. Choose an option below:',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Option 1: Install SMS App
              _buildOptionCard(
                context,
                icon: Icons.download_rounded,
                title: 'Install Messaging App',
                subtitle: 'Get a messaging app from Play Store',
                color: Colors.blue,
                onTap: () {
                  Get.back();
                  _openPlayStoreForSmsApps();
                },
              ),
              const SizedBox(height: 12),

              // Option 2: Use WhatsApp
              _buildOptionCard(
                context,
                icon: Icons.chat_rounded,
                title: 'Use WhatsApp',
                subtitle: 'Send message via WhatsApp',
                color: Colors.green,
                onTap: () {
                  Get.back();
                  _openWhatsApp(phoneNumber);
                },
              ),
              const SizedBox(height: 12),

              // Option 3: Copy Number
              _buildOptionCard(
                context,
                icon: Icons.content_copy_rounded,
                title: 'Copy Number',
                subtitle: 'Copy phone number to clipboard',
                color: Colors.orange,
                onTap: () {
                  Get.back();
                  _copyPhoneNumber(phoneNumber);
                },
              ),
              const SizedBox(height: 24),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyPhoneNumber(String phoneNumber) async {
    // You'll need to add the clipboard package: flutter pub add clipboard
    // import 'package:flutter/services.dart';
    try {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      AppLoaders.successSnackBar(
        title: 'Copied!',
        message: 'Phone number copied to clipboard',
      );
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Copy Failed',
        message: 'Could not copy phone number',
      );
    }
  }

  Future<void> _openPlayStoreForSmsApps() async {
    try {
      final uris = [
        Uri.parse(
          'https://play.google.com/store/search?q=sms%20messenger&c=apps',
        ),
        Uri.parse('market://search?q=sms messenger'),
      ];

      bool launched = false;
      for (final uri in uris) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          launched = true;
          break;
        }
      }

      if (!launched) {
        AppLoaders.warningSnackBar(
          title: 'Cannot Open Store',
          message: 'Please install a messaging app manually from Play Store',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Store Error',
        message: 'Failed to open app store: $e',
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(date);

    // If within the last 7 days, show relative time
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      // Show formatted date (DD/MM/YYYY)
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    }
  }
}
