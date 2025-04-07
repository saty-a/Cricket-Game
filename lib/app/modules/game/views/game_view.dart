import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

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
              child: Image.asset(
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

      final userWon = controller.gameState.value.userScore >
          controller.gameState.value.botScore;

      return Container(
        color: Colors.black.withAlpha(178),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: userWon
                    ? Colors.amber.withAlpha(230)
                    : Colors.grey.withAlpha(178),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userWon ? '🎉 You Won! 🎉' : '😢 Game Over',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: userWon
                        ? Colors.amber.withAlpha(230)
                        : Colors.white.withAlpha(230),
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatRow('Your Score',
                    controller.gameState.value.userScore.toString()),
                _buildStatRow('Bot Score',
                    controller.gameState.value.botScore.toString()),
                _buildStatRow('High Score', controller.highScore.toString()),
                _buildStatRow('Games Won',
                    '${controller.gamesWon}/${controller.gamesPlayed}'),
                _buildStatRow(
                    'Win Rate', '${controller.winRate.toStringAsFixed(1)}%'),
                const SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.startNewGame,
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.withAlpha(230),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Exit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withAlpha(230),
                        side: BorderSide(color: Colors.white.withAlpha(230)),
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
        ),
      );
    });
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
            color: Colors.transparent,
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
        // Player side (Left trapezoid)
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.amber.withAlpha(230),
                  Colors.amber.withAlpha(220),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withAlpha(90),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final isBatting = controller.gameState.value.isUserBatting;
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
                              ? (ballsDelivered >
                                  index) // Show score when batting
                              : (ballsDelivered >
                                  index); // Show ball when bowling

                          return Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? Colors.green.withAlpha(204)
                                  : Colors.grey.shade800.withAlpha(230),
                            ),
                            child: Center(
                              child: isBatting && isActive
                                  ? Text(
                                      '${userScoreHistory[index]}',
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.sports_cricket,
                                              color: Colors.white,
                                              size: 24,
                                            );
                                          },
                                        )
                                      : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = isBatting
                              ? (ballsDelivered >
                                  index + 3) // Show score when batting
                              : (ballsDelivered >
                                  index + 3); // Show ball when bowling

                          return Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? Colors.green.withAlpha(204)
                                  : Colors.grey.shade800.withAlpha(230),
                            ),
                            child: Center(
                              child: isBatting && isActive
                                  ? Text(
                                      '${userScoreHistory[index + 3]}',
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.sports_cricket,
                                              color: Colors.white,
                                              size: 24,
                                            );
                                          },
                                        )
                                      : null,
                            ),
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
        // Space between trapezoids
        const SizedBox(width: 20),
        // Bot side (Right trapezoid)
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.amber.withAlpha(230),
                  Colors.amber.withAlpha(220),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Bot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withAlpha(90),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final isBatting = !controller.gameState.value.isUserBatting;
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
                              ? (ballsDelivered >
                                  index) // Show score when batting
                              : (ballsDelivered >
                                  index); // Show ball when bowling

                          return Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? Colors.red.withAlpha(204)
                                  : Colors.grey.shade800.withAlpha(230),
                            ),
                            child: Center(
                              child: isBatting && isActive
                                  ? Text(
                                      '${botScoreHistory[index]}',
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.sports_cricket,
                                              color: Colors.white,
                                              size: 24,
                                            );
                                          },
                                        )
                                      : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = isBatting
                              ? (ballsDelivered >
                                  index + 3) // Show score when batting
                              : (ballsDelivered >
                                  index + 3); // Show ball when bowling

                          return Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? Colors.red.withAlpha(204)
                                  : Colors.grey.shade800.withAlpha(230),
                            ),
                            child: Center(
                              child: isBatting && isActive
                                  ? Text(
                                      '${botScoreHistory[index + 3]}',
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.sports_cricket,
                                              color: Colors.white,
                                              size: 24,
                                            );
                                          },
                                        )
                                      : null,
                            ),
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
          ? controller.gameState.value.botScore + 1
          : controller.gameState.value.userScore + 1;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'To win: $targetScore',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }

  Widget _buildInstructionStep(
    String number,
    String title,
    String subtitle,
    List<int>? buttons, {
    bool showHands = false,
    bool showPrize = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (buttons != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buttons.map((number) {
                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: number == 3 ? Colors.amber : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            number == 3 ? Colors.black : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (showHands) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/hand_four.png',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle.split('\n')[0],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/hand_one.png',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle.split('\n')[1],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          if (showPrize) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/rcb_jersey.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/images/bat.png',
                  width: 60,
                  height: 60,
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
