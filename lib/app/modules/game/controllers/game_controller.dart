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
  final handScale = 1.0.obs;
  final showInstructions = true.obs;
  final isButtonEnabled = true.obs;

  Timer? _timer;
  Timer? _animationTimer;
  Timer? _buttonDelayTimer;

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
    _buttonDelayTimer?.cancel();
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
    _buttonDelayTimer?.cancel();
    gameState.value = GameState()
      ..isUserBatting = true
      ..timeLeft = 10;
    animationState.value = AnimationState.idle;
    showInstructions.value = true;
    isButtonEnabled.value = true;
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
    if (input < 1 || input > 6 || gameState.value.isGameOver || !isButtonEnabled.value) return;

    _timer?.cancel();
    _buttonDelayTimer?.cancel();
    isButtonEnabled.value = false;
    
    final botInput = _getBotInput();

    gameState.update((val) {
      if (val == null) return;
      
      val.userInput = input;
      val.botInput = botInput;
      val.timeLeft = 10;
      val.ballsDelivered++;

      if (input == botInput) {
        _handleOut(val);
      } else if (val.isUserBatting) {
        val.userScore += input;
        val.userScoreHistory[val.ballsDelivered - 1] = input;
        val.gameStatus = 'You scored $input runs!';
        _soundService.playButtonClick();
        _animationTimer?.cancel();
        _animationTimer = Timer(const Duration(milliseconds: 1500), () {
          gameState.update((state) {
            state?.userInput = 0;
            state?.botInput = 0;
          });
        });
        
        if (val.ballsDelivered >= 6) {
          _switchToBotBatting(val);
        }
      } else {
        val.botScore += botInput;
        val.botScoreHistory[val.ballsDelivered - 1] = botInput;
        val.gameStatus = 'Bot scored $botInput runs!';
        _soundService.playButtonClick();
        _animationTimer?.cancel();
        _animationTimer = Timer(const Duration(milliseconds: 1500), () {
          gameState.update((state) {
            state?.userInput = 0;
            state?.botInput = 0;
          });
        });
        
        if (val.ballsDelivered >= 6) {
          _endGame(val);
        }
      }

      _checkGameOver(val);
    });

    _buttonDelayTimer = Timer(const Duration(seconds: 2), () {
      isButtonEnabled.value = true;
      if (!gameState.value.isGameOver) {
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

  void _switchToBotBatting(GameState state) {
    state.isUserBatting = false;
    state.gameStatus = 'Your innings complete! Bot is batting now.';
    _soundService.playOut();
    animationState.value = AnimationState.reveal;
    state.userInput = 0;
    state.botInput = 0;
    state.timeLeft = 10;
    state.ballsDelivered = 0;
    
    // Reset animation state after showing game_defend
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(milliseconds: 1500), () {
      animationState.value = AnimationState.idle;
    });
    
    // Add 2-second delay before enabling buttons and starting timer
    _buttonDelayTimer?.cancel();
    _buttonDelayTimer = Timer(const Duration(seconds: 2), () {
      isButtonEnabled.value = true;
      _startTimer();
    });
  }

  void _handleOut(GameState state) {
    if (state.isUserBatting) {
      _switchToBotBatting(state);
    } else {
      _soundService.playWin();
      animationState.value = AnimationState.celebrate;
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
    } else if (state.userScore < state.botScore) {
      state.gameStatus = 'Bot won! Try again.';
      animationState.value = AnimationState.lose;
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

  void setHandScale(double scale) {
    handScale.value = scale;
  }

  void hideInstructions() {
    showInstructions.value = false;
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
  int ballsDelivered = 0;
  String gameStatus = 'Your turn to bat!';
  List<int> userScoreHistory = List.filled(6, 0);  // Store scores for each ball
  List<int> botScoreHistory = List.filled(6, 0);   // Store scores for each ball

  GameState copyWith({
    bool? isUserBatting,
    bool? isGameOver,
    int? userScore,
    int? botScore,
    int? userInput,
    int? botInput,
    int? timeLeft,
    int? ballsDelivered,
    String? gameStatus,
    List<int>? userScoreHistory,
    List<int>? botScoreHistory,
  }) {
    return GameState()
      ..isUserBatting = isUserBatting ?? this.isUserBatting
      ..isGameOver = isGameOver ?? this.isGameOver
      ..userScore = userScore ?? this.userScore
      ..botScore = botScore ?? this.botScore
      ..userInput = userInput ?? this.userInput
      ..botInput = botInput ?? this.botInput
      ..timeLeft = timeLeft ?? this.timeLeft
      ..ballsDelivered = ballsDelivered ?? this.ballsDelivered
      ..gameStatus = gameStatus ?? this.gameStatus
      ..userScoreHistory = userScoreHistory ?? List.from(this.userScoreHistory)
      ..botScoreHistory = botScoreHistory ?? List.from(this.botScoreHistory);
  }
}