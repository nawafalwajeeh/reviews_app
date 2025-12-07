import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/personalization/models/settings_tile_model.dart';
import 'package:reviews_app/features/personalization/screens/address/address.dart';
import 'package:reviews_app/features/personalization/screens/settings/upload_data.dart';
import 'package:reviews_app/localization/app_localizations.dart';

/// -- The toplevel [accountSettings] list of ListTile items
List<SettingsTileModel> accountSettings(BuildContext context) => [
  SettingsTileModel(
    icon: Iconsax.safe_home,
    title: AppLocalizations.of(context).myAddresses,
    subTitle: AppLocalizations.of(context).setDeliveryAddress,
    onTap: () => Get.to(() => const UserAddressScreen()),
  ),
  SettingsTileModel(
    icon: Iconsax.bank,
    title: AppLocalizations.of(context).bankAccount,
    subTitle: AppLocalizations.of(context).withdrawBalance,
    onTap: () {},
  ),
  SettingsTileModel(
    icon: Iconsax.discount_shape,
    title: AppLocalizations.of(context).myCoupons,
    subTitle: AppLocalizations.of(context).discountedCoupons,
    onTap: () {},
  ),
  SettingsTileModel(
    icon: Iconsax.notification,
    title: AppLocalizations.of(context).notifications,
    subTitle: AppLocalizations.of(context).setNotifications,
    onTap: () {},
  ),
  SettingsTileModel(
    icon: Iconsax.security_card,
    title: AppLocalizations.of(context).accountPrivacy,
    subTitle: AppLocalizations.of(context).manageDataUsage,
    onTap: () {},
  ),
];

/// -- Define the toplevel [appSettings] list of ListTile items
List<SettingsTileModel> appSettings(BuildContext context) => [
  SettingsTileModel(
    icon: Iconsax.document_upload,
    title: AppLocalizations.of(context).loadData,
    subTitle: AppLocalizations.of(context).uploadDataToCloud,
    onTap: () => Get.to(() => const UploadDataScreen()),
  ),
  SettingsTileModel(
    icon: Iconsax.location,
    title: AppLocalizations.of(context).geolocation,
    subTitle: AppLocalizations.of(context).recommendationBasedOnLocation,
    onTap: () {},
    trailing: Switch(value: true, onChanged: (value) {}),
  ),
  SettingsTileModel(
    icon: Iconsax.security_user,
    title: AppLocalizations.of(context).safeMode,
    subTitle: AppLocalizations.of(context).safeForAllAges,
    onTap: () {},
    trailing: Switch(value: true, onChanged: (value) {}),
  ),
  SettingsTileModel(
    icon: Iconsax.image,
    title: AppLocalizations.of(context).hdImageQuality,
    subTitle: AppLocalizations.of(context).setImageQuality,
    onTap: () {},
    trailing: Switch(value: true, onChanged: (value) {}),
  ),
];

//---------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:reviews_app/features/personalization/models/settings_tile_model.dart';
// import 'package:reviews_app/features/personalization/screens/address/address.dart';
// import 'package:reviews_app/features/personalization/screens/settings/upload_data.dart';

// /// -- The toplevel [accountSettings] list of ListTile items
// final List<SettingsTileModel> accountSettings = [
//   SettingsTileModel(
//     icon: Iconsax.safe_home,
//     title: 'My Addresses',
//     subTitle: 'Set shopping delivery address',
//     onTap: () => Get.to(() => const UserAddressScreen()),
//   ),
//   SettingsTileModel(
//     icon: Iconsax.bank,
//     title: 'Bank Account',
//     subTitle: 'Withdraw balance to registered bank account',
//     onTap: () {},
//   ),
//   SettingsTileModel(
//     icon: Iconsax.discount_shape,
//     title: 'My Coupons',
//     subTitle: 'List of all the discounted coupons',
//     onTap: () {},
//   ),
//   SettingsTileModel(
//     icon: Iconsax.notification,
//     title: 'Notifications',
//     subTitle: 'Set any kind of notification message',
//     onTap: () {},
//   ),
//   SettingsTileModel(
//     icon: Iconsax.security_card,
//     title: 'Account Privacy',
//     subTitle: 'Manage data usage and connected accounts',
//     onTap: () {},
//   ),
// ];

// /// -- Define the toplevel [appSettings] list of ListTile items
// final List<SettingsTileModel> appSettings = [
//   SettingsTileModel(
//     icon: Iconsax.document_upload,
//     title: 'Load Data',
//     subTitle: 'Upload Data to your Cloud Firebase',
//     onTap: () => Get.to(() => const UploadDataScreen()),
//   ),
//   SettingsTileModel(
//     icon: Iconsax.location,
//     title: 'Geolocation',
//     subTitle: 'Set recommendation based on location',
//     onTap: () {},
//     trailing: Switch(value: false, onChanged: (value) {}),
//   ),
//   SettingsTileModel(
//     icon: Iconsax.security_user,
//     title: 'Safe Mode',
//     subTitle: 'Search result is safe for all ages',
//     onTap: () {},
//     trailing: Switch(value: false, onChanged: (value) {}),
//   ),
//   SettingsTileModel(
//     icon: Iconsax.image,
//     title: 'HD Image Quality',
//     subTitle: 'Set image quality to be seen',
//     onTap: () {},
//     trailing: Switch(value: true, onChanged: (value) {}),
//   ),
// ];
