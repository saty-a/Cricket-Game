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

  void setUserInput(int number) {
    if (gameState.value.isGameOver || gameState.value.userInput != 0) return;

    gameState.value = gameState.value.copyWith(userInput: number);
    _soundService.playButtonClick();

    // Show batting/defending animation
    animationState.value = AnimationState.reveal;
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(milliseconds: 2000), () {
      animationState.value = AnimationState.idle;
      _processTurn();
    });
  }

  void _processTurn() {
    final state = gameState.value;
    final botInput = _getBotInput();
    
    if (state.isUserBatting) {
      if (state.userInput == botInput) {
        // User is out
        _soundService.playOut();
        animationState.value = AnimationState.lose;
        _animationTimer?.cancel();
        _animationTimer = Timer(const Duration(milliseconds: 2000), () {
          _handleOut();
        });
      } else {
        _soundService.playButtonClick();
        gameState.value = state.copyWith(
          userScore: state.userScore + state.userInput,
          userInput: 0,
          botInput: botInput,
          gameStatus: 'You scored ${state.userInput} runs!',
        );
      }
    } else {
      if (state.userInput == botInput) {
        // Bot is out
        _soundService.playWin();
        animationState.value = AnimationState.celebrate;
        _animationTimer?.cancel();
        _animationTimer = Timer(const Duration(milliseconds: 2000), () {
          _handleBotOut();
        });
      } else {
        _soundService.playButtonClick();
        gameState.value = state.copyWith(
          botScore: state.botScore + botInput,
          userInput: 0,
          botInput: botInput,
          gameStatus: 'Bot scored $botInput runs!',
        );
      }
    }
  }

  void _handleOut() {
    final state = gameState.value;
    if (state.isUserBatting) {
      // User's innings is over, bot starts batting
      gameState.value = state.copyWith(
        isUserBatting: false,
        userInput: 0,
        botInput: 0,
        gameStatus: 'You are OUT! Bot is batting now.',
      );
      animationState.value = AnimationState.idle;
    }
  }

  void _handleBotOut() {
    final state = gameState.value;
    if (!state.isUserBatting) {
      // Bot's innings is over
      final userWon = state.userScore > state.botScore;
      gameState.value = state.copyWith(
        isGameOver: true,
        userInput: 0,
        botInput: 0,
        gameStatus: userWon ? 'You Won! 🎉' : 'Bot Won! 😢',
      );
      animationState.value = userWon ? AnimationState.celebrate : AnimationState.lose;
      
      // Update stats
      if (userWon) {
        gamesWon.value++;
      }
      gamesPlayed.value++;
      if (state.userScore > highScore.value) {
        highScore.value = state.userScore;
      }
      
      // Save stats
      _updateStorage();
    }
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

  GameState copyWith({
    bool? isUserBatting,
    bool? isGameOver,
    int? userScore,
    int? botScore,
    int? userInput,
    int? botInput,
    int? timeLeft,
    String? gameStatus,
  }) {
    return GameState()
      ..isUserBatting = isUserBatting ?? this.isUserBatting
      ..isGameOver = isGameOver ?? this.isGameOver
      ..userScore = userScore ?? this.userScore
      ..botScore = botScore ?? this.botScore
      ..userInput = userInput ?? this.userInput
      ..botInput = botInput ?? this.botInput
      ..timeLeft = timeLeft ?? this.timeLeft
      ..gameStatus = gameStatus ?? this.gameStatus;
  }
}