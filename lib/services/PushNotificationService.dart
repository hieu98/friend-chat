import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../models/PushNotificationMessage.dart';

class PushNotificationService {
  final FirebaseMessaging _fmc;

  PushNotificationService(this._fmc);

  Future initialise() async {
    if(Platform.isIOS){
      _fmc.requestPermission();
    }

    String? token = await _fmc.getToken();
    print("FirebaseMessaging token: $token");

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      PushNotificationMessage notificationMessage;
      notificationMessage  = PushNotificationMessage(
          title: message.notification?.title,
          body: message.notification?.body
      );

      print("onMessage:  ${notification?.body}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

  }
}