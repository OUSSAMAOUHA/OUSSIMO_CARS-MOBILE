import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

import 'main.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash:Lottie.asset('assets/59106-area-map.json'),




      ///TODO Add your image under assets folder

      //const Text('Cake app', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),)


      backgroundColor: Colors.white,
      nextScreen: const MyHomePage(title: 'Cars views'),
      splashIconSize: 250,
      duration: 120,
      splashTransition: SplashTransition.fadeTransition,
      //pageTransitionType: PageTransitionType.leftToRightWithFade,
      animationDuration: const Duration(seconds: 5),
    );
  }
}