import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/personalization/models/settings_tile_model.dart';
import 'package:reviews_app/features/personalization/screens/address/address.dart';
import 'package:reviews_app/features/personalization/screens/settings/upload_data.dart';

/// -- The toplevel [accountSettings] list of ListTile items
final List<SettingsTileModel> accountSettings = [
  SettingsTileModel(
    icon: Iconsax.safe_home,
    title: 'My Addresses',
    subTitle: 'Set shopping delivery address',
    onTap: () => Get.to(() => const UserAddressScreen()),
  ),
  SettingsTileModel(
    icon: Iconsax.bank,
    title: 'Bank Account',
    subTitle: 'Withdraw balance to registered bank account',
    onTap: () {},
  ),
  SettingsTileModel(
    icon: Iconsax.discount_shape,
    title: 'My Coupons',
    subTitle: 'List of all the discounted coupons',
    onTap: () {},
  ),
  SettingsTileModel(
    icon: Iconsax.notification,
    title: 'Notifications',
    subTitle: 'Set any kind of notification message',
    onTap: () {},
  ),
  SettingsTileModel(
    icon: Iconsax.security_card,
    title: 'Account Privacy',
    subTitle: 'Manage data usage and connected accounts',
    onTap: () {},
  ),
];

/// -- Define the toplevel [appSettings] list of ListTile items
final List<SettingsTileModel> appSettings = [
  SettingsTileModel(
    icon: Iconsax.document_upload,
    title: 'Load Data',
    subTitle: 'Upload Data to your Cloud Firebase',
    onTap: () => Get.to(() => const UploadDataScreen()),
  ),
  SettingsTileModel(
    icon: Iconsax.location,
    title: 'Geolocation',
    subTitle: 'Set recommendation based on location',
    onTap: () {},
    trailing: Switch(value: false, onChanged: (value) {}),
  ),
  SettingsTileModel(
    icon: Iconsax.security_user,
    title: 'Safe Mode',
    subTitle: 'Search result is safe for all ages',
    onTap: () {},
    trailing: Switch(value: false, onChanged: (value) {}),
  ),
  SettingsTileModel(
    icon: Iconsax.image,
    title: 'HD Image Quality',
    subTitle: 'Set image quality to be seen',
    onTap: () {},
    trailing: Switch(value: true, onChanged: (value) {}),
  ),
];
