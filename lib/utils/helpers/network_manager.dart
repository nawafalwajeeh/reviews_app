import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:reviews_app/utils/popups/loaders.dart';

import '../../localization/app_localizations.dart';

/// Manages the network connectivity status and provides methods to check and handle connectivity changes.
class AppNetworkManager extends GetxController {
  static AppNetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  /// Initialize the network manager and set up a stream to continually check the connection status.
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Update the connection status based on changes in connectivity and
  /// show a relevant popup for internet connection status.
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final hasConnected = result.any(
      (status) => status != ConnectivityResult.none,
    );

    if (hasConnected) {
      // Only show the success snackbar if the previous state was disconnected.
      if (_connectionStatus.value == ConnectivityResult.none) {
        // AppLoaders.successSnackBar(title: 'Internet is Connected');
        AppLoaders.successSnackBar(
          title: AppLocalizations.of(Get.context!).internetConnected,
        );
      }
      _connectionStatus.value = result.firstWhere(
        (status) => status != ConnectivityResult.none,
        orElse: () => ConnectivityResult.none,
      );
    } else {
      // Only show the warning snackbar if the previous state was connected.
      if (_connectionStatus.value != ConnectivityResult.none) {
        // AppLoaders.warningSnackBar(title: 'No Internet Connection');
        AppLoaders.warningSnackBar(
          title: AppLocalizations.of(Get.context!).noInternetConnection,
        );
      }
      _connectionStatus.value = ConnectivityResult.none;
    }
  }

  /// Check the internet connection status.
  /// Returns `true` if connected, `false` otherwise.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // if (result == ConnectivityResult.none) {
      if (result.contains(ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Dispose or close the active connectivity stream.
  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
