import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hand Cricket'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreCard('You', controller.userScore),
          _buildScoreCard('Bot', controller.botScore),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, RxInt score) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )),
      ],
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Text(
        controller.gameStatus.value,
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
        'Time left: ${controller.timeLeft}s',
        style: TextStyle(
          fontSize: 18,
          color: controller.timeLeft.value <= 3 ? Colors.red : Colors.black,
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
              _buildNumberDisplay('Your Input', controller.userInput.value),
              _buildNumberDisplay('Bot\'s Input', controller.botInput.value),
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
          onPressed: controller.isGameOver.value
              ? null
              : () => controller.setUserInput(number),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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