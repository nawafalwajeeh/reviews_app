import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/review/screens/notifications/notifications.dart';
// import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
// import 'package:reviews_app/features/review/screens/place_reviews/place_comments.dart';
// import 'package:reviews_app/features/personalization/screens/profile/profile.dart';
import 'package:reviews_app/utils/constants/api_constants.dart';
import '../../../utils/constants/colors.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  // Observables
  final RxString _userId = RxString('');
  final RxString _userName = RxString('');
  final RxString _userAvatar = RxString('');
  final RxInt _unreadNotificationCount = RxInt(0);
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = RxBool(false);
  final RxBool _hasNotificationPermission = RxBool(false);

  // Services
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream subscriptions
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  // Getters
  RxInt get unreadNotificationCount => _unreadNotificationCount;
  RxList<NotificationModel> get notifications => _notifications;
  RxBool get isLoading => _isLoading;
  RxBool get hasNotificationPermission => _hasNotificationPermission;
  String get userId => _userId.value;
  String get userName => _userName.value;
  String get userAvatar => _userAvatar.value;

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    _setCurrentUser();
    ever(_userId, (_) {
      if (_userId.value.isNotEmpty) {
        _initializeFCM();
        _listenForNotifications();
        _listenForUnreadCount();
      }
    });
  }

  @override
  void onClose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        // This handles notification taps and actions
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          handleNotificationAction(response);
        },
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'reviews_channel',
          'Reviews Notifications',
          description: 'Notifications for reviews, comments, and follows',
          importance: Importance.max,
          // priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      }

      debugPrint('✅ Local notifications initialized with action support');
    } catch (e) {
      debugPrint('❌ Error initializing local notifications: $e');
    }
  }

  // Set current user from authentication
  Future<void> _setCurrentUser() async {
    try {
      final authRepo = AuthenticationRepository.instance;
      final currentUser = authRepo.getUserID;

      if (currentUser.isNotEmpty) {
        _userId.value = currentUser;
        debugPrint('✅ Current user set: $currentUser');

        // Get user details from Firestore
        final userDoc = await _firestore
            .collection('Users')
            .doc(currentUser)
            .get();
        if (userDoc.exists) {
          // ignore: unnecessary_cast
          final userData = userDoc.data() as Map<String, dynamic>?;
          _userName.value = userData?['name'] ?? userData?['Username'] ?? '';
          _userAvatar.value =
              userData?['avatar'] ?? userData?['ProfilePicture'] ?? '';
          debugPrint('✅ User details loaded: ${_userName.value}');
        }
      } else {
        debugPrint('⚠️ No user logged in yet');
      }
    } catch (e) {
      debugPrint('❌ Error setting current user: $e');
    }
  }

  // Initialize FCM and request permissions
  Future<void> _initializeFCM() async {
    try {
      debugPrint('🔄 Initializing FCM...');

      // Request notification permissions
      await _requestNotificationPermissions();

      // Get current FCM token
      String? fcmToken = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $fcmToken');

      // Register token with server
      if (fcmToken != null && _userId.value.isNotEmpty) {
        await _registerFcmTokenWithServer(fcmToken);
      } else {
        debugPrint('⚠️ FCM token or userId is empty, skipping registration');
      }

      // Configure message handlers
      _configureMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        debugPrint('🔄 FCM token refreshed');
        if (_userId.value.isNotEmpty) {
          await _registerFcmTokenWithServer(newToken);
        }
      });

      debugPrint('✅ FCM initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      debugPrint('🔔 Requesting notification permissions...');

      if (Platform.isAndroid) {
        // For Android 13+
        final status = await Permission.notification.request();
        _hasNotificationPermission.value = status.isGranted;
        debugPrint('Android notification permission: $status');
      }

      // Firebase permission request
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      _hasNotificationPermission.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      debugPrint(
        'Firebase notification permission: ${settings.authorizationStatus}',
      );
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }
  }

  // Configure FCM message handlers
  void _configureMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '📨 Foreground message received: ${message.notification?.title}',
      );
      _showLocalNotification(message);
      _handleNewNotification(message);
    });

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '📱 App opened from notification: ${message.notification?.title}',
      );
      _handleNotificationTap(message.data['type'] ?? 'default', message.data);
    });

    // Handle initial notification when app is launched
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        debugPrint(
          '🚀 Initial message on app launch: ${message.notification?.title}',
        );
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(
            message.data['type'] ?? 'default',
            message.data,
          );
        });
      }
    });
  }

  // Register FCM token with server
  Future<void> _registerFcmTokenWithServer(String token) async {
    try {
      debugPrint('🔄 Registering FCM token with server...');

      final response = await http.post(
        Uri.parse('${ApiConstants.serverUrl}/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _userId.value, 'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token registered with server');

        // Also update in Firestore for backup
        await _firestore.collection('Users').doc(_userId.value).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        debugPrint(
          '❌ Failed to register FCM token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error registering FCM token: $e');
      // Fallback: save to Firestore directly
      try {
        await _firestore.collection('Users').doc(_userId.value).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ FCM token saved to Firestore as fallback');
      } catch (firestoreError) {
        debugPrint('❌ Failed to save FCM token to Firestore: $firestoreError');
      }
    }
  }

  // Listen for user notifications from Firestore
  void _listenForNotifications() {
    _notificationsSubscription?.cancel();

    if (_userId.value.isEmpty) {
      debugPrint('⚠️ Cannot listen for notifications: userId is empty');
      return;
    }

    _isLoading.value = true;
    debugPrint('🔄 Listening for notifications for user: ${_userId.value}');

    _notificationsSubscription = _firestore
        .collection('Users')
        .doc(_userId.value)
        .collection('Notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _isLoading.value = false;

            final newNotifications = <NotificationModel>[];
            for (var doc in snapshot.docs) {
              try {
                final data = doc.data();

                // Handle different timestamp formats
                DateTime timestamp;
                if (data['timestamp'] is Timestamp) {
                  timestamp = (data['timestamp'] as Timestamp).toDate();
                } else if (data['timestamp'] is String) {
                  timestamp = DateTime.parse(data['timestamp']);
                } else {
                  timestamp = DateTime.now();
                }

                // Create notification model with fallback values
                final notification = NotificationModel(
                  id: doc.id,
                  type: data['type'] ?? 'general',
                  title: data['title'] ?? '',
                  body: data['body'] ?? '',
                  senderId: data['senderId'] ?? data['senderId'] ?? '',
                  senderName: data['senderName'] ?? '',
                  senderAvatar: data['senderAvatar'] ?? '',
                  targetId: data['targetId'] ?? '',
                  targetType: data['targetType'] ?? '',
                  isRead: data['isRead'] ?? false,
                  timestamp: timestamp,
                  extraData: Map<String, dynamic>.from(data['extraData'] ?? {}),
                );

                newNotifications.add(notification);
              } catch (e) {
                debugPrint('❌ Error parsing notification ${doc.id}: $e');
              }
            }

            _notifications.value = newNotifications;
            debugPrint('✅ Loaded ${newNotifications.length} notifications');
          },
          onError: (error) {
            _isLoading.value = false;
            debugPrint('❌ Error listening to notifications: $error');
          },
        );
  }

  // Listen for unread notification count
  void _listenForUnreadCount() {
    _unreadCountSubscription?.cancel();

    if (_userId.value.isEmpty) return;

    _unreadCountSubscription = _firestore
        .collection('Users')
        .doc(_userId.value)
        .collection('Notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            _unreadNotificationCount.value = snapshot.docs.length;
            debugPrint(
              '📊 Unread notifications: ${_unreadNotificationCount.value}',
            );
          },
          onError: (error) {
            debugPrint('❌ Error listening to unread count: $error');
          },
        );
  }

  // showing the notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final data = message.data;
      final title =
          data['senderName'] ??
          message.notification?.title ??
          'New Notification';
      final body = message.notification?.body ?? data['body'] ?? '';
      final type = data['type'] ?? 'default';
      final senderAvatar = data['senderAvatar'] ?? '';
      final senderName = data['senderName'] ?? '';
      final placeId = data['placeId'] ?? '';
      final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}';

      // Check if we have an avatar
      final hasAvatar =
          senderAvatar.isNotEmpty && senderAvatar.startsWith('http');

      // Create notification channel
      if (Platform.isAndroid) {
        final AndroidNotificationChannel channel = AndroidNotificationChannel(
          'reviews_channel',
          'Reviews Notifications',
          description: 'Notifications for reviews, comments, and follows',
          importance: Importance.max,
          // priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
          enableLights: true,
          // lightColor: Color(0xFF25D366), // WhatsApp green
          ledColor: AppColors.primaryColor,
          vibrationPattern: Int64List.fromList(const [0, 500, 250, 500]),
        );

        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      }

      // Android notification details - SIMPLIFIED VERSION
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'reviews_channel',
            'Reviews Notifications',
            channelDescription:
                'Notifications for reviews, comments, and follows',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
            color: AppColors.primaryColor, // WhatsApp green
            // Use largeIcon for avatar
            largeIcon: hasAvatar ? FilePathAndroidBitmap(senderAvatar) : null,
            icon: '@mipmap/launcher_icon',
            // Use BigPictureStyle for avatar display
            styleInformation: hasAvatar
                ? BigPictureStyleInformation(
                    FilePathAndroidBitmap(senderAvatar),
                    largeIcon: FilePathAndroidBitmap(senderAvatar),
                    contentTitle: senderName.isNotEmpty ? senderName : title,
                    summaryText: body,
                    htmlFormatContentTitle: true,
                    htmlFormatSummaryText: true,
                  )
                : null,
            // Simple actions without input
            actions: [
              const AndroidNotificationAction(
                'view_action',
                'View',
                showsUserInterface: true,
              ),
              const AndroidNotificationAction('mark_read_action', 'Mark Read'),
            ],
            // Group settings
            groupKey: 'reviews_group',
            setAsGroupSummary: false,
            autoCancel: true,
          );

      // iOS notification details - SIMPLIFIED
      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        subtitle: senderName,
        threadIdentifier: 'reviews_thread',
        categoryIdentifier: 'MESSAGE_CATEGORY',
        attachments: hasAvatar
            ? [DarwinNotificationAttachment(senderAvatar)]
            : null,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        senderName.isNotEmpty ? senderName : title,
        body,
        platformDetails,
        payload: jsonEncode({
          'type': type,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
          'avatar': senderAvatar,
          'senderName': senderName,
          'placeId': placeId,
          'notificationId': notificationId,
        }),
      );

      debugPrint(
        '📱 WhatsApp-style notification shown: $title from $senderName',
      );
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  // Handle notification actions when tapped
  Future<void> handleNotificationAction(NotificationResponse response) async {
    debugPrint('🔘 Notification action tapped: ${response.actionId}');

    try {
      if (response.payload != null) {
        final payloadData = jsonDecode(response.payload!);
        final data = payloadData['data'] ?? {};
        final notificationId = payloadData['notificationId'];

        final actionId = response.actionId ?? 'default';

        switch (actionId) {
          case 'view_action':
            navigateToNotificationTarget(data['type'] ?? 'default', data);
            break;

          case 'mark_read_action':
            if (notificationId != null) {
              await markAsRead(notificationId.toString());
              // Show confirmation
              Get.snackbar(
                'Marked as Read',
                'Notification marked as read',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
            break;

          default:
            // Default tap action
            navigateToNotificationTarget(data['type'] ?? 'default', data);
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling notification action: $e');
    }
  }

  // Handle notification actions
  Future<void> _handleNotificationAction(
    String actionId,
    String? payload,
  ) async {
    debugPrint('🔘 Notification action tapped: $actionId');

    try {
      if (payload != null) {
        final payloadData = jsonDecode(payload);
        final data = payloadData['data'] ?? {};
        final notificationId = payloadData['notificationId'];

        switch (actionId) {
          case 'view_action':
            _handleNotificationTap(payload);
            break;

          case 'mark_read_action':
            if (notificationId != null) {
              await markAsRead(notificationId);
              // Show confirmation
              Get.snackbar(
                'Marked as Read',
                'Notification marked as read',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            }
            break;

          case 'reply_action':
            // Handle reply (you'll need to implement this)
            _showReplyDialog(data);
            break;

          default:
            _handleNotificationTap(payload);
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling notification action: $e');
    }
  }

  // Show reply dialog
  void _showReplyDialog(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        title: Text('Reply to ${data['senderName'] ?? 'User'}'),
        content: TextField(
          controller: TextEditingController(),
          decoration: const InputDecoration(
            hintText: 'Type your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Send reply
              Get.back();
              Get.snackbar(
                'Reply Sent',
                'Your reply has been sent',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // Handle new notification from FCM
  void _handleNewNotification(RemoteMessage message) {
    try {
      final data = message.data;
      final notification = NotificationModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        type: data['type'] ?? 'general',
        title: message.notification?.title ?? data['title'] ?? '',
        body: message.notification?.body ?? data['body'] ?? '',
        senderId: data['senderId'] ?? '',
        senderName: data['senderName'] ?? '',
        senderAvatar: data['senderAvatar'] ?? '',
        targetId: data['targetId'] ?? '',
        targetType: data['targetType'] ?? '',
        isRead: false,
        timestamp: DateTime.now(),
        extraData: data,
      );

      // Add to notifications list
      _notifications.insert(0, notification);

      // Update unread count
      _unreadNotificationCount.value++;

      debugPrint('📨 New notification handled: ${notification.title}');

      // Show in-app snackbar for important notifications
      if (data['type'] != 'general') {
        Get.snackbar(
          notification.title,
          notification.body,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
          onTap: (snack) {
            _handleNotificationTap(notification.type, notification.extraData);
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling new notification: $e');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload, [Map<String, dynamic>? data]) {
    try {
      debugPrint('👆 Notification tapped: $payload');

      if (payload == null) {
        Get.to(() => NotificationsScreen());
        return;
      }

      final payloadData = jsonDecode(payload);
      final type = payloadData['type'] ?? 'default';
      final notificationData = payloadData['data'] ?? {};

      navigateToNotificationTarget(type, notificationData);
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
      Get.to(() => NotificationsScreen());
    }
  }

  // Navigate based on notification type
  void navigateToNotificationTarget(String type, Map<String, dynamic> data) {
    debugPrint('📍 Navigating for notification type: $type');

    final placeId = data['placeId'];
    final reviewId = data['reviewId'];
    final userId = data['userId'] ?? data['senderId'];
    final commentId = data['commentId'];

    switch (type) {
      case 'new_review':
      case 'review_liked':
        if (placeId != null && placeId is String) {
          // Get.to(() => PlaceDetailsScreen(place: placeId));
        }
        break;

      case 'new_comment':
      case 'comment_replied':
        if (placeId != null && placeId is String) {
          // Get.to(() => PlaceCommentsScreen(place: placeId));
        }
        break;

      case 'new_follower':
        if (userId != null && userId is String) {
          // Get.to(() => ProfileScreen(userId: userId));
        }
        break;

      case 'place_featured':
        if (placeId != null && placeId is String) {
          // Get.to(() => PlaceDetailsScreen(place: placeId));
        }
        break;

      default:
        Get.to(() => NotificationsScreen());
    }

    // Mark notification as read if it has an ID
    if (data['notificationId'] != null) {
      markAsRead(data['notificationId'] as String);
    }
  }

  // Load user notifications (manual refresh)
  Future<void> loadUserNotifications() async {
    if (_userId.value.isEmpty) {
      debugPrint('⚠️ Cannot load notifications: userId is empty');
      return;
    }

    _isLoading.value = true;
    debugPrint('🔄 Manually loading notifications...');

    try {
      final snapshot = await _firestore
          .collection('Users')
          .doc(_userId.value)
          .collection('Notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final loadedNotifications = <NotificationModel>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Handle different timestamp formats
          DateTime timestamp;
          if (data['timestamp'] is Timestamp) {
            timestamp = (data['timestamp'] as Timestamp).toDate();
          } else if (data['timestamp'] is String) {
            timestamp = DateTime.parse(data['timestamp']);
          } else {
            timestamp = DateTime.now();
          }

          final notification = NotificationModel(
            id: doc.id,
            type: data['type'] ?? 'general',
            title: data['title'] ?? '',
            body: data['body'] ?? '',
            senderId: data['senderId'] ?? '',
            senderName: data['senderName'] ?? '',
            senderAvatar: data['senderAvatar'] ?? '',
            targetId: data['targetId'] ?? '',
            targetType: data['targetType'] ?? '',
            isRead: data['isRead'] ?? false,
            timestamp: timestamp,
            extraData: Map<String, dynamic>.from(data['extraData'] ?? {}),
          );

          loadedNotifications.add(notification);
        } catch (e) {
          debugPrint('❌ Error parsing notification ${doc.id}: $e');
        }
      }

      _notifications.value = loadedNotifications;
      debugPrint(
        '✅ Loaded ${loadedNotifications.length} notifications manually',
      );
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> sendNewReviewNotification({
    required String placeOwnerId,
    required String placeId,
    required String placeName,
    required double rating,
    required String reviewText,
  }) async {
    return await sendNotification(
      toUserId: placeOwnerId,
      type: 'new_review',
      title: 'New Review on Your Place',
      body: '${_userName.value} reviewed "$placeName"',
      targetId: placeId,
      targetType: 'place',
      extraData: {
        'placeId': placeId,
        'placeName': placeName,
        'rating': rating.toString(),
        'reviewText': reviewText,
      },
    );
  }

  Future<bool> sendReviewLikedNotification({
    required String reviewAuthorId,
    required String reviewId,
    required String placeId,
    required int likeCount,
  }) async {
    return await sendNotification(
      toUserId: reviewAuthorId,
      type: 'review_liked',
      title: 'Your Review Got Liked',
      body: '${_userName.value} liked your review',
      targetId: reviewId,
      targetType: 'review',
      extraData: {
        'reviewId': reviewId,
        'placeId': placeId,
        'likeCount': likeCount.toString(),
      },
    );
  }

  Future<bool> sendNewCommentNotification({
    required String reviewAuthorId,
    required String reviewId,
    required String placeId,
    required String commentId,
    required String commentText,
  }) async {
    return await sendNotification(
      toUserId: reviewAuthorId,
      type: 'new_comment',
      title: 'New Comment on Your Review',
      body: '${_userName.value} commented on your review',
      targetId: reviewId,
      targetType: 'review',
      extraData: {
        'reviewId': reviewId,
        'placeId': placeId,
        'commentId': commentId,
        'commentText': commentText,
      },
    );
  }

  Future<bool> sendCommentReplyNotification({
    required String parentCommentAuthorId,
    required String commentId,
    required String parentCommentId,
    required String placeId,
    required String replyText,
  }) async {
    return await sendNotification(
      toUserId: parentCommentAuthorId,
      type: 'comment_replied',
      title: 'New Reply to Your Comment',
      body: '${_userName.value} replied to your comment',
      targetId: parentCommentId,
      targetType: 'comment',
      extraData: {
        'commentId': commentId,
        'parentCommentId': parentCommentId,
        'placeId': placeId,
        'replyText': replyText,
      },
    );
  }

  Future<bool> sendNewFollowerNotification({
    required String followedUserId,
  }) async {
    return await sendNotification(
      toUserId: followedUserId,
      type: 'new_follower',
      title: 'New Follower',
      body: '${_userName.value} started following you',
      targetId: _userId.value,
      targetType: 'user',
    );
  }

  Future<bool> sendPlaceFeaturedNotification({
    required String placeOwnerId,
    required String placeId,
    required String placeName,
  }) async {
    return await sendNotification(
      toUserId: placeOwnerId,
      type: 'place_featured',
      title: 'Your Place is Featured!',
      body: '"$placeName" is now featured on the homepage',
      senderName: 'Reviews App',
      senderAvatar: '',
      targetId: placeId,
      targetType: 'place',
      extraData: {'placeId': placeId, 'placeName': placeName},
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      if (_userId.value.isEmpty) return;

      await _firestore
          .collection('Users')
          .doc(_userId.value)
          .collection('Notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _notifications.refresh();
      }

      // Update unread count
      if (_unreadNotificationCount.value > 0) {
        _unreadNotificationCount.value--;
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Mark specific notifications as read by type
  Future<void> markNotificationsAsReadByType(String type) async {
    try {
      if (_userId.value.isEmpty) return;

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('Users')
          .doc(_userId.value)
          .collection('Notifications')
          .where('type', isEqualTo: type)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].type == type && !_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      _notifications.refresh();

      // Recalculate unread count
      _unreadNotificationCount.value = _notifications
          .where((n) => !n.isRead)
          .length;
    } catch (e) {
      debugPrint('Error marking notifications by type as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      if (_userId.value.isEmpty) return;

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('Users')
          .doc(_userId.value)
          .collection('Notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      _notifications.refresh();
      _unreadNotificationCount.value = 0;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      if (_userId.value.isEmpty) return;

      await _firestore
          .collection('Users')
          .doc(_userId.value)
          .collection('Notifications')
          .doc(notificationId)
          .delete();

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      _notifications.refresh();

      // Update unread count if needed
      _unreadNotificationCount.value = _notifications
          .where((n) => !n.isRead)
          .length;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      if (_userId.value.isEmpty) return;

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('Users')
          .doc(_userId.value)
          .collection('Notifications')
          .get();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Clear local state
      _notifications.clear();
      _unreadNotificationCount.value = 0;
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  // Check if user has notification permission
  Future<void> checkNotificationPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      _hasNotificationPermission.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
    }
  }

  // Open app notification settings
  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }

  // Get notification by ID
  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get notification count by type
  int getNotificationCountByType(String type) {
    return _notifications.where((n) => n.type == type).length;
  }

  // Get unread notification count by type
  int getUnreadNotificationCountByType(String type) {
    return _notifications.where((n) => n.type == type && !n.isRead).length;
  }

  // Check if user has any unread notifications
  bool get hasUnreadNotifications {
    return _unreadNotificationCount.value > 0;
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    await _setCurrentUser();
    await loadUserNotifications();
  }

  // Check server connection
  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.serverUrl}/ping'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get latest notifications (last N)
  List<NotificationModel> getLatestNotifications(int count) {
    return _notifications.take(count).toList();
  }

  // Get notifications from specific date range
  List<NotificationModel> getNotificationsInDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _notifications
        .where((n) => n.timestamp.isAfter(start) && n.timestamp.isBefore(end))
        .toList();
  }

  // Filter notifications by search query
  List<NotificationModel> searchNotifications(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _notifications.where((notification) {
      return notification.title.toLowerCase().contains(lowercaseQuery) ||
          notification.body.toLowerCase().contains(lowercaseQuery) ||
          notification.senderName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Send notification through server
  Future<bool> sendNotification({
    required String toUserId,
    required String type,
    required String title,
    required String body,
    String senderName = '',
    String senderAvatar = '',
    String targetId = '',
    String targetType = '',
    Map<String, dynamic>? extraData,
  }) async {
    try {
      debugPrint('📤 Sending notification to user: $toUserId');

      // Don't send notification to self
      // if (toUserId == _userId.value) {
      //   debugPrint('⚠️ Skipping notification to self');
      //   return false;
      // }

      // Convert all extraData values to strings for server
      final stringExtraData = <String, String>{};
      if (extraData != null) {
        extraData.forEach((key, value) {
          if (value == null) {
            stringExtraData[key] = '';
          } else if (value is Map || value is List) {
            stringExtraData[key] = jsonEncode(value);
          } else {
            stringExtraData[key] = value.toString();
          }
        });
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.serverUrl}/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toUserId': toUserId,
          'type': type,
          'title': title,
          'body': body,
          'senderName': senderName.isNotEmpty ? senderName : _userName.value,
          'senderAvatar': senderAvatar.isNotEmpty
              ? senderAvatar
              : _userAvatar.value,
          'targetId': targetId,
          'targetType': targetType,
          'extraData': {'senderId': _userId.value, ...stringExtraData},
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('✅ Notification sent successfully: ${result['message']}');
        return result['success'] == true;
      } else {
        debugPrint(
          '❌ Failed to send notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      return false;
    }
  }

  // ... rest of your methods remain the same ...

  // Initialize controller (call this after user login)
  Future<void> initializeForUser() async {
    await _setCurrentUser();
    if (_userId.value.isNotEmpty) {
      await _initializeFCM();
      _listenForNotifications();
      _listenForUnreadCount();
    }
  }

  // Clear user data (call this on logout)
  Future<void> clearUserData() async {
    _userId.value = '';
    _userName.value = '';
    _userAvatar.value = '';
    _notifications.clear();
    _unreadNotificationCount.value = 0;
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    _notificationsSubscription = null;
    _unreadCountSubscription = null;
  }
}
