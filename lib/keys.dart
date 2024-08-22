import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// const apiUrl = "http://10.0.2.2:8000"; // Android emulator
// const apiUrl = "http://127.0.0.1:8000"; // iOS simulator
// const apiUrl = "http://192.168.1.7:8000"; // Physical device
final apiUrl =
    Platform.isIOS ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
final wsUrl = Platform.isIOS
    ? "ws://127.0.0.1:8000/websocket"
    : "ws://10.0.2.2:8000/websocket";
final navigatorKey = GlobalKey<NavigatorState>();
final googleClientId = Platform.isIOS
    ? "317991147959-640akvpitg1mt6ln0bgskj840vvk4sj0.apps.googleusercontent.com"
    : "317991147959-et9m50dppk3k0ujl01dhc2huv41r2m3g.apps.googleusercontent.com";
