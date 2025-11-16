// controllers/notification_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/features/personalization/screens/profile/profile.dart';
import 'package:reviews_app/features/review/screens/notifications/notifications.dart'
    show NotificationsScreen;
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/features/review/screens/place_reviews/place_reviews.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  // Observables
  final RxInt _unreadNotificationCount = RxInt(0);
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = false.obs;

  final storage = GetStorage();
  final userId = AuthenticationRepository.instance.getUserID;
  // Services
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  RxInt get unreadNotificationCount => _unreadNotificationCount;
  RxList<NotificationModel> get notifications => _notifications;
  RxBool get isLoading => _isLoading;
  List<NotificationModel> get mockNotifications => _createMockNotifications();

  // Subscriptions
  StreamSubscription? _unreadCountSubscription;
  StreamSubscription? _notificationsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    _initializeFCM();
    _loadCurrentUserNotifications();
  }

  @override
  void onClose() {
    _unreadCountSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initLocalNotifications() async {
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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  Future<void> _initializeFCM() async {
    await _requestNotificationPermissions();

    // Get FCM token
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      await _registerFcmToken(fcmToken);
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      _handleNewNotification(message);
    });

    // Background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['type'] ?? 'default', message.data);
    });

    // Token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await _registerFcmToken(newToken);
    });
  }

  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _registerFcmToken(String token) async {
    // final userId = storage.read('userId');
    await _firestore.collection('Users').doc(userId).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadCurrentUserNotifications() async {
    // final userId = storage.read('userId');
    _isLoading.value = true;

    try {
      _notificationsSubscription = _notificationRepository
          .getUserNotifications(userId)
          .listen((notifications) {
            _notifications.value = notifications;
            _unreadNotificationCount.value = notifications
                .where((n) => !n.isRead)
                .length;
          });
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ??
        message.data['title'] ??
        'New Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final type = message.data['type'] ?? 'default';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reviews_channel',
          'Reviews Notifications',
          channelDescription:
              'Notifications for reviews, comments, and follows',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF0066CC),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: jsonEncode({'type': type, 'data': message.data}),
    );
  }

  void _handleNewNotification(RemoteMessage message) {
    // Update local notifications list in real-time
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

    _notifications.insert(0, notification);
    _unreadNotificationCount.value++;
  }

  void _handleNotificationTap(String? payload, [Map<String, dynamic>? data]) {
    if (payload == null) return;

    try {
      final payloadData = jsonDecode(payload);
      final type = payloadData['type'] ?? 'default';
      final notificationData = payloadData['data'] ?? {};

      navigateToNotificationTarget(type, notificationData);
    } catch (e) {
      // Navigate to notifications screen as fallback
      Get.to(() => NotificationsScreen());
    }
  }

  void navigateToNotificationTarget(String type, Map<String, dynamic> data) {
    final placeId = data['placeId'];
    final reviewId = data['reviewId'];
    final userId = data['userId'];
    final commentId = data['commentId'];

    switch (type) {
      case 'new_review':
      case 'review_liked':
      case 'review_commented':
        if (placeId != null) {
          Get.to(() => PlaceDetailsScreen(place: placeId));
        }
        break;

      case 'new_comment':
      case 'comment_liked':
      case 'comment_replied':
        if (placeId != null && commentId != null) {
          Get.to(
            // () => PlaceReviewsScreen(placeId: placeId, focusCommentId: commentId),
            () => PlaceReviewsScreen(place: placeId),
          );
        }
        break;

      case 'new_follower':
        if (userId != null) {
          // Get.to(() => ProfileScreen(userId: userId));
          Get.to(() => ProfileScreen());
        }
        break;

      case 'place_featured':
        if (placeId != null) {
          Get.to(() => PlaceDetailsScreen(place: placeId));
        }
        break;

      default:
        Get.to(() => NotificationsScreen());
    }
  }

  // Notification actions
  Future<void> markAsRead(String notificationId) async {
    // final userId = storage.read('userId');
    await _notificationRepository.markAsRead(userId, notificationId);
  }

  Future<void> markAllAsRead() async {
    // final userId = storage.read('userId');
    await _notificationRepository.markAllAsRead(userId);
    _unreadNotificationCount.value = 0;
  }

  Future<void> deleteNotification(String notificationId) async {
    // final userId = storage.read('userId');
    await _notificationRepository.deleteNotification(userId, notificationId);
  }

  // Send notifications from within the app
  Future<void> sendNotification({
    required String toUserId,
    required String type,
    required String title,
    required String body,
    required String senderName,
    required String senderAvatar,
    required String targetId,
    required String targetType,
    Map<String, dynamic>? extraData,
  }) async {
    await _notificationRepository.sendNotification(
      toUserId: toUserId,
      type: type,
      title: title,
      body: body,
      senderName: senderName,
      senderAvatar: senderAvatar,
      targetId: targetId,
      targetType: targetType,
      extraData: extraData,
    );
  }

  // Mock data for development
  List<NotificationModel> _createMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        type: 'new_review',
        title: 'New Review on Your Place',
        body: 'Sarah Johnson reviewed "Central Park Cafe"',
        senderId: 'user2',
        senderName: 'Sarah Johnson',
        senderAvatar:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786',
        targetId: 'place1',
        targetType: 'place',
        isRead: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        extraData: {
          'rating': '5',
          'reviewText': 'Amazing coffee and atmosphere!',
        },
      ),
      NotificationModel(
        id: '2',
        type: 'review_liked',
        title: 'Your Review Got Liked',
        body: 'Mike Chen and 3 others liked your review',
        senderId: 'user3',
        senderName: 'Mike Chen',
        senderAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
        targetId: 'review1',
        targetType: 'review',
        isRead: false,
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        extraData: {'likeCount': '4'},
      ),
      NotificationModel(
        id: '3',
        type: 'new_follower',
        title: 'New Follower',
        body: 'Emma Davis started following you',
        senderId: 'user4',
        senderName: 'Emma Davis',
        senderAvatar:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
        targetId: 'user4',
        targetType: 'user',
        isRead: true,
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
      ),
      NotificationModel(
        id: '4',
        type: 'comment_replied',
        title: 'New Reply to Your Comment',
        body:
            'Alex Rodriguez replied to your comment on "Beachside Restaurant"',
        senderId: 'user5',
        senderName: 'Alex Rodriguez',
        senderAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        targetId: 'comment1',
        targetType: 'comment',
        isRead: true,
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
      NotificationModel(
        id: '5',
        type: 'place_featured',
        title: 'Your Place is Featured!',
        body: '"Mountain View Lodge" is now featured on the homepage',
        senderId: 'system',
        senderName: 'Reviews App',
        senderAvatar: '',
        targetId: 'place2',
        targetType: 'place',
        isRead: true,
        timestamp: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
  }
}

//-----------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../models/notification_model.dart';

// class NotificationController extends GetxController {
//   static NotificationController instance = Get.find();

//   final List<NotificationModel> mockNotifications = [
//     NotificationModel(
//       icon: Icons.star_rounded,
//       title: 'New 5-star review!',
//       timeAgo: '2m ago',
//       description:
//           'Sarah M. left an amazing review for Sunset Café. Check it out!',
//       gradientColors: const [Color(0xFFFFE7E7), Color(0xFFA8EDEA)],
//       actionText: 'View Review',
//       actionBgColor: const Color(0xFFFFE7E7),
//       actionTextColor: const Color(0xFFFF6B6B),
//     ),
//     NotificationModel(
//       icon: Icons.thumb_up_rounded,
//       title: 'Review liked!',
//       timeAgo: '15m ago',
//       description:
//           '3 people found your review of Ocean View Restaurant helpful.',
//       gradientColors: const [Color(0xFFE7F4FF), Color(0xFF4DA8FF)],
//       userAvatars: const [
//         'https://images.unsplash.com/photo-1693641059840-b2ba454dc248',
//         'https://images.unsplash.com/photo-1713720178558-5ea3c4ce79e0',
//         'https://images.unsplash.com/photo-1713720178558-5ea3c4ce79e0',
//       ],
//     ),
//     NotificationModel(
//       icon: Icons.location_on_rounded,
//       title: 'New place nearby',
//       timeAgo: '1h ago',
//       description:
//           'Mountain Peak Brewery just opened 0.5 miles from you. Be the first to review!',
//       gradientColors: const [Color(0xFFE7FFE7), Color(0xFF1C59A4)],
//       actionText: 'Explore',
//       actionBgColor: const Color(0xFFE7FFE7),
//       actionTextColor: Colors.black87,
//     ),
//     NotificationModel(
//       // icon is deliberately omitted here, so the default icon will be used
//       title: 'Reply to your review',
//       timeAgo: '3h ago',
//       description:
//           'The owner of Artisan Coffee House replied to your review. Thanks for the feedback!',
//       gradientColors: const [Color(0xFFFFF7E7), Color(0xFF6495ED)],
//       actionText: 'Read Reply',
//       actionBgColor: const Color(0xFFFFF7E7),
//       actionTextColor: Colors.black87,
//     ),
//     NotificationModel(
//       icon: Icons.trending_up_rounded,
//       title: 'Review milestone!',
//       timeAgo: '1d ago',
//       description:
//           'Congratulations! You\'ve written 50 reviews and helped the community discover great places.',
//       gradientColors: const [Color(0xFFF3E7FF), Color(0xFFADD8E6)],
//       milestoneText: 'Local Guide Badge Earned',
//       milestoneIcon: Icons.emoji_events_rounded,
//     ),
//     NotificationModel(
//       icon: Icons.group_rounded,
//       title: 'Friend activity',
//       timeAgo: '2d ago',
//       description:
//           'Alex reviewed 2 new places this week. Check out their latest discoveries!',
//       gradientColors: const [Color(0xFFB0E0FF), Color(0xFF5D6EA0)],
//       userAvatars: const [
//         'https://images.unsplash.com/photo-1740657252845-b4ccbaa65d84',
//       ],
//       followingText: 'Following',
//     ),
//   ];
// }
