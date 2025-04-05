import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../../../data/models/game_state.dart';

class GameController extends GetxController {
  static const int maxScore = 50;
  static const int maxBalls = 6;
  static const int inputTimeLimit = 10;

  final Rx<GameState> gameState = GameState().obs;
  Timer? _timer;
  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    startNewGame();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startNewGame() {
    gameState.value = GameState(
      gameStatus: 'Your turn to bat!',
      timeLeft: inputTimeLimit,
    );
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameState.value.timeLeft > 0) {
        gameState.value = gameState.value.copyWith(
          timeLeft: gameState.value.timeLeft - 1,
        );
      } else {
        handleTimeOut();
      }
    });
  }

  void handleTimeOut() {
    _timer?.cancel();
    if (!gameState.value.isGameOver) {
      gameState.value = gameState.value.copyWith(
        isGameOver: true,
        gameStatus: 'Time out! You lose!',
      );
    }
  }

  void setUserInput(int number) {
    if (number < 1 || number > 6 || gameState.value.isGameOver) return;

    final botNumber = _random.nextInt(6) + 1;
    gameState.value = gameState.value.copyWith(
      userInput: number,
      botInput: botNumber,
    );

    processGameLogic();
  }

  void processGameLogic() {
    if (gameState.value.userInput == gameState.value.botInput) {
      handleOut();
    } else {
      if (gameState.value.isUserBatting) {
        gameState.value = gameState.value.copyWith(
          userScore: gameState.value.userScore + gameState.value.userInput,
          ballsPlayed: gameState.value.ballsPlayed + 1,
        );
      } else {
        gameState.value = gameState.value.copyWith(
          botScore: gameState.value.botScore + gameState.value.botInput,
          ballsPlayed: gameState.value.ballsPlayed + 1,
        );
      }

      if (gameState.value.ballsPlayed >= maxBalls) {
        switchInnings();
      }
    }

    startTimer();
    checkGameOver();
  }

  void handleOut() {
    final newStatus = gameState.value.isUserBatting
        ? 'Out! Bot\'s turn to bat'
        : 'Bot is out!';
    
    switchInnings();
    
    gameState.value = gameState.value.copyWith(
      gameStatus: newStatus,
    );
  }

  void switchInnings() {
    if (gameState.value.isUserBatting) {
      gameState.value = gameState.value.copyWith(
        isUserBatting: false,
        ballsPlayed: 0,
        gameStatus: 'Bot is batting!',
      );
    } else {
      checkGameOver();
    }
  }

  void checkGameOver() {
    if (!gameState.value.isUserBatting &&
        (gameState.value.botScore > gameState.value.userScore ||
            gameState.value.ballsPlayed >= maxBalls)) {
      _timer?.cancel();
      
      String finalStatus;
      if (gameState.value.userScore > gameState.value.botScore) {
        finalStatus = 'You win! 🎉';
      } else if (gameState.value.userScore < gameState.value.botScore) {
        finalStatus = 'Bot wins! 😢';
      } else {
        finalStatus = 'It\'s a tie! 🤝';
      }

      gameState.value = gameState.value.copyWith(
        isGameOver: true,
        gameStatus: finalStatus,
      );
    }
  }
} 