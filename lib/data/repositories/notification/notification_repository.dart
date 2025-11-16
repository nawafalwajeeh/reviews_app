// data/repositories/notification_repository.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../features/review/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _serverUrl = 'https://your-backend-url.com'; // Your Node.js server URL

  // Get user notifications stream
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .doc(notificationId)
        .delete();
  }

  // Send notification via HTTP to Node.js server
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
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toUserId': toUserId,
          'type': type,
          'title': title,
          'body': body,
          'senderName': senderName,
          'senderAvatar': senderAvatar,
          'targetId': targetId,
          'targetType': targetType,
          'extraData': extraData ?? {},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Get unread count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('Notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}