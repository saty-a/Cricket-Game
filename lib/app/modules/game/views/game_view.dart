import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart' as rive;
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
                Colors.black.withOpacity(0.7),
                BlendMode.darken,
              ),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white.withOpacity(0.9),
              title: const Text(
                'Hand Cricket',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.startNewGame,
                ),
                PopupMenuButton<Difficulty>(
                  icon: const Icon(Icons.settings),
                  onSelected: controller.setDifficulty,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: Difficulty.easy,
                      child: Text('Easy'),
                    ),
                    const PopupMenuItem(
                      value: Difficulty.medium,
                      child: Text('Medium'),
                    ),
                    const PopupMenuItem(
                      value: Difficulty.hard,
                      child: Text('Hard'),
                    ),
                  ],
                ),
              ],
            ),
            body: SafeArea(
              child: Wrap(
                children: [
                  _buildStats(),
                  _buildScoreBoard(),
                  _buildHandGestures(),
                  _buildGameStatus(),
                  _buildTimer(),
                  const Spacer(),
                  _buildInputArea(),
                ],
              ),
            ),
          ),
        ),
        _buildOverlayAnimation(),
      ],
    );
  }

  Widget _buildOverlayAnimation() {
    return Obx(() {
      final gameState = controller.gameState.value;
      final animState = controller.animationState.value;
      
      String? imageAsset;
      if (animState == AnimationState.reveal) {
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
          color: Colors.black.withOpacity(0.7),
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

  Widget _buildHandGestures() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing circle background
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerHand(),
              _buildBotHand(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHand() {
    return Obx(() {
      final input = controller.gameState.value.userInput;
      final isRevealing = controller.animationState.value == AnimationState.reveal;
      final isCelebrating = controller.animationState.value == AnimationState.celebrate;
      
      Widget handWidget;
      if (isCelebrating) {
        handWidget = Image.asset('assets/images/you_won.png', width: 120, height: 120);
      } else {
        handWidget = SizedBox(
          width: 120,
          height: 120,
          child: rive.RiveAnimation.asset(
            'assets/images/hand_cricket.riv',
            fit: BoxFit.contain,
            animations: input == 0 ? ['idle'] : ['number_$input'],
          ),
        );
      }

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isRevealing ? 0.0 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: handWidget,
        ),
      );
    });
  }

  Widget _buildBotHand() {
    return Obx(() {
      final input = controller.gameState.value.botInput;
      final isRevealing = controller.animationState.value == AnimationState.reveal;
      final isLosing = controller.animationState.value == AnimationState.lose;
      
      Widget handWidget;
      if (isLosing) {
        handWidget = Image.asset('assets/images/out.png', width: 120, height: 120);
      } else {
        handWidget = SizedBox(
          width: 120,
          height: 120,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.14159),
            child: rive.RiveAnimation.asset(
              'assets/images/hand_cricket.riv',
              fit: BoxFit.contain,
              animations: input == 0 ? ['idle'] : ['number_$input'],
            ),
          ),
        );
      }

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isRevealing ? 0.0 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: handWidget,
        ),
      );
    });
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => _buildStatItem(
            'High Score',
            controller.highScore.toString(),
          )),
          Obx(() => _buildStatItem(
            'Games Won',
            '${controller.gamesWon}/${controller.gamesPlayed}',
          )),
          Obx(() => _buildStatItem(
            'Win Rate',
            '${controller.winRate.toStringAsFixed(1)}%',
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.blue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreCard(
                'You',
                controller.gameState.value.userScore,
                controller.gameState.value.isUserBatting,
                Colors.blue,
              ),
              _buildVsWidget(),
              _buildScoreCard(
                'Bot',
                controller.gameState.value.botScore,
                !controller.gameState.value.isUserBatting,
                Colors.red,
              ),
            ],
          )),
          const SizedBox(height: 12),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Difficulty: ${controller.difficulty.value.name.capitalizeFirst}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVsWidget() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.orange.withOpacity(0.7),
            Colors.red.withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          'VS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int score, bool isBatting, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBatting ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isBatting ? 0.5 : 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
              if (isBatting)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.asset(
                    'assets/images/batting.png',
                    width: 24,
                    height: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 500),
            tween: IntTween(begin: 0, end: score),
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    return Obx(() {
      final status = controller.gameState.value.gameStatus;
      final isGameOver = controller.gameState.value.isGameOver;
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isGameOver
              ? [Colors.purple.withOpacity(0.7), Colors.blue.withOpacity(0.7)]
              : [Colors.black.withOpacity(0.6), Colors.blue.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isGameOver ? Colors.purple.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: isGameOver ? 36 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: isGameOver ? Colors.purple : Colors.blue,
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            if (isGameOver) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.startNewGame,
                icon: const Icon(Icons.replay),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() => Text(
        'Time left: ${controller.gameState.value.timeLeft}s',
        style: TextStyle(
          fontSize: 18,
          color: controller.gameState.value.timeLeft <= 3
              ? Colors.red
              : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.8)]
                  : [Colors.black.withOpacity(0.6), Colors.blue.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.black.withOpacity(0.3),
                blurRadius: isSelected ? 15 : 10,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.gameState.value.isGameOver
                  ? null
                  : () => controller.setUserInput(number),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/${_getNumberImage(number)}',
                        width: 45,
                        height: 45,
                        fit: BoxFit.contain,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ));
  }

  String _getNumberImage(int number) {
    switch (number) {
      case 1: return 'one.png';
      case 2: return 'two.png';
      case 3: return 'three.png';
      case 4: return 'four.png';
      case 5: return 'five.png';
      case 6: return 'six.png';
      default: return 'one.png';
    }
  }
} 