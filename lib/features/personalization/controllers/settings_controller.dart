import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.find();

  /// Variables
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  final _storage = GetStorage();

  final recommendationValue = false.obs;
  final imageQualityValue = false.obs;
  final safeResultsValue = false.obs;

  /// get themeMode value
  ThemeMode get themeMode => _themeMode.value;

  /// read themeMode once the [SettingsController] has been injected
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// read themeMode from local storage and assign it to [_themeMode.value]
  void _loadTheme() {
    // Read the value, which can be null on the first launch.
    final themeString = _storage.read('themeMode') ?? '';
    // Use a conditional check to handle the case where the value is null.
    if (themeString.isNotEmpty) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    } else {
      // If the value is null, use the default system theme.
      _themeMode.value = ThemeMode.system;
    }
  }

  /// change themeMode and write the value to the local storage
  void toggleTheme(ThemeMode mode) async {
    if (mode != _themeMode.value) {
      _themeMode.value = mode;
      await _storage.write('themeMode', _themeMode.value.toString());
      Get.changeThemeMode(_themeMode.value);
    }
  }
}

//----------------------------------------
/*
 --is working based on bool values--
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.find();

  /// Variables
  final RxBool _themeMode = false.obs;
  final _storage = GetStorage();

  /// get themeMode value
  bool get themeMode => _themeMode.value;

  /// read themeMode onApp launch
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// read themeMode from local storage and assign it to [themeMode]
  void _loadTheme() async {
    final isDarkMode = await _storage.read('darkMode') ?? false;
    _themeMode.value = isDarkMode;
  }

  /// change themeMode and write to the local storage
  void toggleTheme(bool value) async {
    _themeMode.value = value;
    await _storage.write('darkMode', _themeMode.value);
  }
}
*/
