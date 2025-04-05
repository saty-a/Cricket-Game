import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/sound_service.dart';

enum Difficulty { easy, medium, hard }
enum AnimationState { idle, reveal, celebrate, lose }

class GameController extends GetxController {
  static const String prefHighScore = 'highScore';
  static const String prefGamesPlayed = 'gamesPlayed';
  static const String prefGamesWon = 'gamesWon';
  static const String prefDifficulty = 'difficulty';

  final _storage = GetStorage();
  final _random = Random();
  final _soundService = Get.find<SoundService>();

  final gameState = GameState().obs;
  final difficulty = Difficulty.medium.obs;
  final highScore = 0.obs;
  final gamesPlayed = 0.obs;
  final gamesWon = 0.obs;
  final animationState = AnimationState.idle.obs;

  Timer? _timer;
  Timer? _animationTimer;

  @override
  void onInit() {
    super.onInit();
    _initStorage();
    startNewGame();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _animationTimer?.cancel();
    super.onClose();
  }

  void _initStorage() {
    highScore.value = _storage.read(prefHighScore) ?? 0;
    gamesPlayed.value = _storage.read(prefGamesPlayed) ?? 0;
    gamesWon.value = _storage.read(prefGamesWon) ?? 0;
    difficulty.value = Difficulty.values[_storage.read(prefDifficulty) ?? 1];
  }

  void _updateStorage() {
    _storage.write(prefHighScore, highScore.value);
    _storage.write(prefGamesPlayed, gamesPlayed.value);
    _storage.write(prefGamesWon, gamesWon.value);
    _storage.write(prefDifficulty, difficulty.value.index);
  }

  void setDifficulty(Difficulty newDifficulty) {
    difficulty.value = newDifficulty;
    _updateStorage();
    startNewGame();
  }

  void startNewGame() {
    _timer?.cancel();
    _animationTimer?.cancel();
    gameState.value = GameState()
      ..isUserBatting = true
      ..timeLeft = 5;
    animationState.value = AnimationState.idle;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameState.value.timeLeft > 0) {
        gameState.update((val) {
          val?.timeLeft--;
        });
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    if (!gameState.value.isGameOver) {
      final botInput = _getBotInput();
      setUserInput(botInput);
    }
  }

  void setUserInput(int input) {
    if (input < 1 || input > 6 || gameState.value.isGameOver) return;

    _soundService.playButtonClick();
    _timer?.cancel();
    final botInput = _getBotInput();
    
    animationState.value = AnimationState.reveal;
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(milliseconds: 500), () {
      _soundService.playNumberReveal();
      gameState.update((val) {
        val?.userInput = input;
        val?.botInput = botInput;
        val?.timeLeft = 5;

        if (input == botInput) {
          _handleOut(val!);
        } else if (val?.isUserBatting ?? false) {
          val?.userScore += input;
        } else {
          val?.botScore += botInput;
        }

        _checkGameOver(val!);
      });

      if (!gameState.value.isGameOver) {
        animationState.value = AnimationState.idle;
        _startTimer();
      }
    });
  }

  int _getBotInput() {
    switch (difficulty.value) {
      case Difficulty.easy:
        return _random.nextInt(6) + 1;
      case Difficulty.medium:
        if (_random.nextDouble() < 0.4) {
          return gameState.value.userInput;
        }
        return _random.nextInt(6) + 1;
      case Difficulty.hard:
        if (_random.nextDouble() < 0.6) {
          return gameState.value.userInput;
        }
        if (!gameState.value.isUserBatting) {
          return _random.nextInt(3) + 4;
        }
        return _random.nextInt(6) + 1;
    }
  }

  void _handleOut(GameState state) {
    _soundService.playOut();
    if (state.isUserBatting) {
      state.isUserBatting = false;
      state.gameStatus = 'You\'re out! Bot is batting now.';
      if (state.botScore > state.userScore) {
        _endGame(state);
      }
    } else {
      _endGame(state);
    }
  }

  void _checkGameOver(GameState state) {
    if (!state.isUserBatting && state.botScore > state.userScore) {
      _endGame(state);
    }
  }

  void _endGame(GameState state) {
    state.isGameOver = true;
    _timer?.cancel();

    if (state.userScore > state.botScore) {
      state.gameStatus = 'You won! 🎉';
      gamesWon.value++;
      animationState.value = AnimationState.celebrate;
      _soundService.playWin();
    } else if (state.userScore < state.botScore) {
      state.gameStatus = 'Bot won! Try again.';
      animationState.value = AnimationState.lose;
      _soundService.playLose();
    } else {
      state.gameStatus = 'It\'s a tie!';
      animationState.value = AnimationState.idle;
    }

    if (state.userScore > highScore.value) {
      highScore.value = state.userScore;
    }

    gamesPlayed.value++;
    _updateStorage();
  }

  double get winRate {
    if (gamesPlayed.value == 0) return 0;
    return (gamesWon.value / gamesPlayed.value) * 100;
  }
}

class GameState {
  bool isUserBatting = true;
  bool isGameOver = false;
  int userScore = 0;
  int botScore = 0;
  int userInput = 0;
  int botInput = 0;
  int timeLeft = 5;
  String gameStatus = 'Your turn to bat!';
}