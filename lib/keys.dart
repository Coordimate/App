import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// const apiUrl = "http://10.0.2.2:8000"; // Android emulator
// const apiUrl = "http://127.0.0.1:8000"; // iOS simulator
// const apiUrl = "http://192.168.1.7:8000"; // Physical device
final apiUrl = Platform.isIOS ?  "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
final navigatorKey = GlobalKey<NavigatorState>();
