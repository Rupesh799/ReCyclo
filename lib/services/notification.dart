
// notification_provider.dart
import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  String _notification = '';

  String get notification => _notification;

  void setNotification(String notification) {
    _notification = notification;
    notifyListeners();
  }
}