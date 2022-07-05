import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'package:iot_app/device/aws.dart';
import 'package:iot_app/device/device.dart';
import 'package:iot_app/pages/login_page.dart';


final CloudConnectivity cloud = CloudConnectivity();
final DeviceInf device = DeviceInf();


void main() {
  // this is required to init sharedpreferences before runApp() is called
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AnimatedSplashScreen.withScreenFunction(
      duration: 0,
      splash: 'assets/flutter_icon.png',
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Colors.white,
      screenFunction: () async {
        return const LoginScreen();
      },
    ),
    builder: (context, child) {
      final mediaQueryData = MediaQuery.of(context);
      final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.0);
      return MediaQuery(
        child: child!,
        data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
      );
    },
  ));
}