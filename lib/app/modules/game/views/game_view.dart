import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            _buildGameStatus(),
            _buildTimer(),
            const Spacer(),
            _buildInputArea(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.sports_cricket, color: Colors.blue),
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
      child: Column(
        children: [
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNumberDisplay(
                'Your Input',
                controller.gameState.value.userInput,
              ),
              _buildNumberDisplay(
                'Bot\'s Input',
                controller.gameState.value.botInput,
              ),
            ],
          )),
          const SizedBox(height: 20),
          _buildNumberButtons(),
        ],
      ),
    );
  }

  Widget _buildNumberDisplay(String title, int number) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
          child: Text(
            number.toString(),
            style: const TextStyle(fontSize: 20),
          ),
        );
      }),
    ));
  }
} 