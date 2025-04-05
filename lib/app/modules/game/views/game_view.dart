import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
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
          child: Column(
            children: [
              _buildStats(),
              _buildScoreBoard(),
              _buildHandGestures(),
              _buildGameStatus(),
              _buildTimer(),
              const Spacer(),
              _buildInputArea(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandGestures() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPlayerHand(),
          _buildBotHand(),
        ],
      ),
    );
  }

  Widget _buildPlayerHand() {
    return Obx(() {
      final input = controller.gameState.value.userInput;
      final isRevealing = controller.animationState.value == AnimationState.reveal;
      final isCelebrating = controller.animationState.value == AnimationState.celebrate;
      
      if (isCelebrating) {
        return Image.asset('assets/images/you_won.png', width: 120, height: 120);
      }

      if (input == 0) {
        return Image.asset(
          'assets/images/batting.png',
          width: 120,
          height: 120,
        );
      }

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isRevealing ? 0.0 : 1.0,
        child: Image.asset(
          'assets/images/${_getNumberImage(input)}',
          width: 120,
          height: 120,
        ),
      );
    });
  }

  Widget _buildBotHand() {
    return Obx(() {
      final input = controller.gameState.value.botInput;
      final isRevealing = controller.animationState.value == AnimationState.reveal;
      final isLosing = controller.animationState.value == AnimationState.lose;
      
      if (isLosing) {
        return Image.asset('assets/images/out.png', width: 120, height: 120);
      }

      if (input == 0) {
        return Image.asset(
          'assets/images/ball.png',
          width: 120,
          height: 120,
        );
      }

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isRevealing ? 0.0 : 1.0,
        child: Image.asset(
          'assets/images/${_getNumberImage(input)}',
          width: 120,
          height: 120,
        ),
      );
    });
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
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
              ),
              _buildScoreCard(
                'Bot',
                controller.gameState.value.botScore,
                !controller.gameState.value.isUserBatting,
              ),
            ],
          )),
          const SizedBox(height: 8),
          Obx(() => Text(
            'Difficulty: ${controller.difficulty.value.name.capitalizeFirst}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, int score, bool isBatting) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() => Text(
        controller.gameState.value.gameStatus,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      )),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNumberButtons(),
        ],
      ),
    );
  }

  Widget _buildNumberButtons() {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(6, (index) {
        final number = index + 1;
        return ElevatedButton(
          onPressed: controller.gameState.value.isGameOver
              ? null
              : () => controller.setUserInput(number),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
          child: Image.asset(
            'assets/images/${_getNumberImage(number)}',
            width: 32,
            height: 32,
          ),
        );
      }),
    ));
  }
} 