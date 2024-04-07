import 'package:get/get.dart';
import 'dart:async';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final logoScale = 0.0.obs;
  final textOpacity = 0.0.obs;
  final loadingOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      logoScale.value = 1.0;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      textOpacity.value = 1.0;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      loadingOpacity.value = 1.0;
    });

    Future.delayed(const Duration(seconds: 3), () {
      _navigateToGame();
    });
  }

  void _navigateToGame() {
    Get.offAllNamed(Routes.GAME);
  }
} 