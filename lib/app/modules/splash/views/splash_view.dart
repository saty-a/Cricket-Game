import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: CricketFieldPainter(),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Transform.scale(
                        scale: controller.logoScale.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withAlpha(50),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/ball.png'),
                          )
                              .animate()
                              .rotate(duration: const Duration(seconds: 3))
                              .shake(hz: 3),
                        ),
                      )),
                  const SizedBox(height: 40),
                  // App name with animation
                  Obx(() => Opacity(
                        opacity: controller.textOpacity.value,
                        child: const Text(
                          'Hand Cricket',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  // Tagline with animation
                  Obx(() => Opacity(
                        opacity: controller.textOpacity.value,
                        child: const Text(
                          'Play Cricket Anywhere!',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )),
                  const SizedBox(height: 60),
                  // Loading indicator
                  Obx(() => Opacity(
                        opacity: controller.loadingOpacity.value,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )),
                ],
              ),
            ),
            // Version text
            Positioned(
              bottom: 20,
              right: 20,
              child: Obx(() => Opacity(
                    opacity: controller.textOpacity.value,
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class CricketFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    canvas.drawCircle(Offset(centerX, centerY), radius * 0.7, paint);
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.4, paint);

    final pitchLength = radius * 0.3;
    canvas.drawLine(
      Offset(centerX - pitchLength, centerY),
      Offset(centerX + pitchLength, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - pitchLength),
      Offset(centerX, centerY + pitchLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CricketFieldPainter oldDelegate) => false;
}
