import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class TrapeziumPainter extends CustomPainter {
  final Gradient gradient;
  final bool isTransparent;

  TrapeziumPainter({
    required this.gradient,
    this.isTransparent = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    if (isTransparent) {
      paint.color = Colors.white.withAlpha(25);
    }

    final path = Path();
    // Bottom width is larger than top width for inverted trapezium effect
    final topWidth = size.width * 0.7;
    final bottomWidth = size.width;
    final height = size.height;

    path.moveTo((size.width - topWidth) / 2, 0);
    path.lineTo((size.width + topWidth) / 2, 0);
    path.lineTo((size.width + bottomWidth) / 2, height);
    path.lineTo((size.width - bottomWidth) / 2, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrapeziumPainter oldDelegate) => true;
}

class SideFillPainter extends CustomPainter {
  final Color color;
  final bool isLeft;

  SideFillPainter({
    required this.color,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(77)
      ..style = PaintingStyle.fill;

    final path = Path();
    final topWidth = size.width * 0.7;
    final bottomWidth = size.width;
    final height = size.height;

    if (isLeft) {
      // Left side fill
      path.moveTo(0, 0);
      path.lineTo((size.width - topWidth) / 2, 0);
      path.lineTo((size.width - bottomWidth) / 2, height);
      path.lineTo(0, height);
    } else {
      // Right side fill
      path.moveTo((size.width + topWidth) / 2, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, height);
      path.lineTo((size.width + bottomWidth) / 2, height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SideFillPainter oldDelegate) => true;
}

class GameView extends GetView<GameController> {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: const AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(178),
                BlendMode.darken,
              ),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: [
                          _buildStats(),
                          _buildScoreBoard(),
                          _buildTargetScore(),
                          _buildHandGestures(),
                        ],
                      ),
                    ),
                  ),
                  _buildInputArea(),
                ],
              ),
            ),
          ),
        ),
        _buildOverlayAnimation(),
        _buildGameOverOverlay(),
      ],
    );
  }

  Widget _buildOverlayAnimation() {
    return Obx(() {
      final gameState = controller.gameState.value;
      final animState = controller.animationState.value;
      final isFirstBall = gameState.ballsDelivered == 0;

      String? imageAsset;
      if (animState == AnimationState.reveal && isFirstBall) {
        if (gameState.isUserBatting) {
          imageAsset = 'assets/images/batting.png';
        } else {
          imageAsset = 'assets/images/game_defend.webp';
        }
      } else if (animState == AnimationState.lose) {
        imageAsset = 'assets/images/out.png';
      } else if (animState == AnimationState.sixer) {
        imageAsset = 'assets/images/sixer.png';
      }

      if (imageAsset == null) return const SizedBox.shrink();

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: Container(
          color: Colors.black.withAlpha(178),
          child: Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: animState == AnimationState.sixer
                  ? Container(
                      width: Get.width * 0.8,
                      height: Get.width * 0.8,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(imageAsset),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.1, 1.1),
                        duration: const Duration(milliseconds: 500),
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 300),
                      )
                  : Image.asset(
                      imageAsset,
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGameOverOverlay() {
    return Obx(() {
      if (!controller.gameState.value.isGameOver) {
        return const SizedBox.shrink();
      }

      Future.microtask(() {
        if (!Get.isDialogOpen!) {
          Get.dialog(
            GameOverOverlay(
              userWon: controller.gameState.value.userScore >
                  controller.gameState.value.botScore,
              userScore: controller.gameState.value.userScore,
              botScore: controller.gameState.value.botScore,
              highScore: controller.highScore.value,
              gamesWon: controller.gamesWon.value,
              gamesPlayed: controller.gamesPlayed.value,
              winRate: controller.winRate,
              onPlayAgain: () {
                Get.back();
                controller.startNewGame();
              },
              onExit: () {
                Get.dialog(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Exit Game',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Are you sure you want to exit the game?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (Platform.isAndroid) {
                                    SystemNavigator.pop();
                                  } else if (Platform.isIOS) {
                                    exit(0);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Yes, Exit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  barrierDismissible: false,
                );
              },
            ),
            barrierDismissible: false,
          );
        }
      });
      return const SizedBox.shrink();
    });
  }

  Widget _buildHandGestures() {
    return Container(
      height: Get.width * 0.55,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(20),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 2,
            color: Colors.yellow.withAlpha(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withAlpha(100),
              Colors.yellow.withAlpha(100),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(60),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTapDown: (_) => controller.setHandScale(0.9),
                onTapUp: (_) => controller.setHandScale(1.0),
                onTapCancel: () => controller.setHandScale(1.0),
                child: Obx(() => Transform.scale(
                      scale: controller.handScale.value,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: _buildPlayerHand(),
                      ),
                    )),
              ),
              GestureDetector(
                onTapDown: (_) => controller.setHandScale(0.9),
                onTapUp: (_) => controller.setHandScale(1.0),
                onTapCancel: () => controller.setHandScale(1.0),
                child: Obx(() => Transform.scale(
                      scale: controller.handScale.value,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: _buildBotHand(),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerHand() {
    return Obx(() {
      final input = controller.gameState.value.userInput;
      final isRevealing =
          controller.animationState.value == AnimationState.reveal;
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isRevealing ? 0.0 : 1.0,
        child: Image.asset(
          _getHandImage(input),
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      );
    });
  }

  Widget _buildBotHand() {
    return Obx(() {
      final input = controller.gameState.value.botInput;
      final isRevealing =
          controller.animationState.value == AnimationState.reveal;

      return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isRevealing ? 0.0 : 1.0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.14159),
            child: Image.asset(
              _getHandImage(input),
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ));
    });
  }

  String _getHandImage(int number) {
    switch (number) {
      case 1:
        return 'assets/images/hand_one.png';
      case 2:
        return 'assets/images/hand_two.png';
      case 3:
        return 'assets/images/hand_three.png';
      case 4:
        return 'assets/images/hand_four.png';
      case 5:
        return 'assets/images/hand_five.png';
      case 6:
        return 'assets/images/hand_six.png';
      default:
        return 'assets/images/hand_idle.png';
    }
  }

  Widget _buildStats() {
    return Center(
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.yellow.withAlpha(230), width: 2)),
              child: Text(
                "Current highest Score: ${controller.highScore.toString()}",
                style: const TextStyle(color: Colors.white),
              )),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Your weekly score: ${controller.highScore.toString()}",
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                painter: SideFillPainter(
                  color: Colors.yellowAccent.withAlpha(50),
                  isLeft: true,
                ),
                child: Container(
                  height: Get.height * .12,
                ),
              ),
              CustomPaint(
                painter: TrapeziumPainter(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(50),
                      Colors.white.withAlpha(25),
                    ],
                  ),
                  isTransparent: false,
                ),
                child: Container(
                  height: Get.height * .12,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  child: Column(
                    children: [
                      Obx(() {
                        final isBatting =
                            controller.gameState.value.isUserBatting;
                        final ballsDelivered =
                            controller.gameState.value.ballsDelivered;
                        final userScoreHistory =
                            controller.gameState.value.userScoreHistory;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final isActive = isBatting
                                    ? (ballsDelivered > index)
                                    : (ballsDelivered > index);
                                return _buildScoreBall(
                                  isActive: isActive,
                                  isBatting: isBatting,
                                  score: userScoreHistory[index],
                                  color: Colors.yellow.shade400,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            // Second Row of Balls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final isActive = isBatting
                                    ? (ballsDelivered > index + 3)
                                    : (ballsDelivered > index + 3);
                                return _buildScoreBall(
                                  isActive: isActive,
                                  isBatting: isBatting,
                                  score: userScoreHistory[index + 3],
                                  color: Colors.green.shade400,
                                );
                              }),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                painter: SideFillPainter(
                  color: Colors.redAccent,
                  isLeft: false,
                ),
                child: Container(
                  height: Get.height * .12,
                ),
              ),
              // Transparent trapezium
              CustomPaint(
                painter: TrapeziumPainter(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(25),
                      Colors.white.withAlpha(50),
                    ],
                  ),
                  isTransparent: false,
                ),
                child: Container(
                  height: Get.height * .12,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  child: Column(
                    children: [
                      Obx(() {
                        final isBatting =
                            !controller.gameState.value.isUserBatting;
                        final ballsDelivered =
                            controller.gameState.value.ballsDelivered;
                        final botScoreHistory =
                            controller.gameState.value.botScoreHistory;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final isActive = isBatting
                                    ? (ballsDelivered > index)
                                    : (ballsDelivered > index);
                                return _buildScoreBall(
                                  isActive: isActive,
                                  isBatting: isBatting,
                                  score: botScoreHistory[index],
                                  color: Colors.red.shade400,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            // Second Row of Balls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final isActive = isBatting
                                    ? (ballsDelivered > index + 3)
                                    : (ballsDelivered > index + 3);
                                return _buildScoreBall(
                                  isActive: isActive,
                                  isBatting: isBatting,
                                  score: botScoreHistory[index + 3],
                                  color: Colors.red.shade400,
                                );
                              }),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBall({
    required bool isActive,
    required bool isBatting,
    required int score,
    required Color color,
  }) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha(50),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isBatting && isActive
            ? Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : !isBatting && isActive
                ? Image.asset(
                    'assets/images/ball.png',
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.sports_cricket,
                        color: Colors.white,
                        size: 18,
                      );
                    },
                  )
                : null,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(178),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final timeLeft = controller.gameState.value.timeLeft;
            final progress = timeLeft / 10.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withAlpha(100),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.redAccent,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                Text(
                  '$timeLeft',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: timeLeft <= 3 ? Colors.red : Colors.white,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Pick a number before time runs out!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(230),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberButtons(),
        ],
      ),
    );
  }

  Widget _buildNumberButtons() {
    return Obx(() => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: List.generate(6, (index) {
            final number = index + 1;
            final isSelected = controller.gameState.value.userInput == number;
            final isEnabled = controller.isButtonEnabled.value;
            return Obx(() {
              final scale = isSelected ? 0.9 : 1.0;
              return GestureDetector(
                onTapDown:
                    isEnabled ? (_) => controller.setUserInput(number) : null,
                onTapUp: isEnabled ? (_) => controller.setUserInput(0) : null,
                onTapCancel:
                    isEnabled ? () => controller.setUserInput(0) : null,
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap:
                            controller.gameState.value.isGameOver || !isEnabled
                                ? null
                                : () => controller.setUserInput(number),
                        borderRadius: BorderRadius.circular(20),
                        child: FittedBox(
                          child: Opacity(
                            opacity: isEnabled ? 1.0 : 0.5,
                            child: Image.asset(
                              'assets/images/${_getNumberImage(number)}',
                              width: 45,
                              height: 45,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          }),
        ));
  }

  String _getNumberImage(int number) {
    switch (number) {
      case 1:
        return 'one.png';
      case 2:
        return 'two.png';
      case 3:
        return 'three.png';
      case 4:
        return 'four.png';
      case 5:
        return 'five.png';
      case 6:
        return 'six.png';
      default:
        return 'one.png';
    }
  }

  Widget _buildTargetScore() {
    return Obx(() {
      final targetScore = controller.gameState.value.isUserBatting
          ? controller.gameState.value.botScore
          : controller.gameState.value.userScore;
      return Center(
        child: CustomPaint(
          painter: TrapeziumPainter(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.yellow.withAlpha(204),
                Colors.white.withAlpha(153),
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'To win: $targetScore',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class LeftTrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height); // Top-left
    path.lineTo(size.width, size.height); // Top-right
    path.lineTo(size.width, 0); // Bottom point (center)
    path.lineTo(0, 0); // Bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RightTrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // Top-left
    path.lineTo(size.width, 0); // Top-right
    path.lineTo(size.width, size.height); // Bottom-right
    path.lineTo(size.width * 0.5, size.height); // Bottom point (center)
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GameOverOverlay extends StatelessWidget {
  final bool userWon;
  final int userScore;
  final int botScore;
  final int highScore;
  final int gamesWon;
  final int gamesPlayed;
  final double winRate;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameOverOverlay({
    Key? key,
    required this.userWon,
    required this.userScore,
    required this.botScore,
    required this.highScore,
    required this.gamesWon,
    required this.gamesPlayed,
    required this.winRate,
    required this.onPlayAgain,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: userWon ? Colors.amber : Colors.grey,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userWon ? '🎉 You Won! 🎉' : '😢 Game Over',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: userWon ? Colors.amber : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Your Score', userScore.toString()),
            _buildStatRow('Bot Score', botScore.toString()),
            _buildStatRow('High Score', highScore.toString()),
            _buildStatRow('Games Won', '$gamesWon/$gamesPlayed'),
            _buildStatRow('Win Rate', '${winRate.toStringAsFixed(1)}%'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Exit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black87),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
