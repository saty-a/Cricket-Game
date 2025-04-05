class GameState {
  final int userScore;
  final int botScore;
  final int userInput;
  final int botInput;
  final int ballsDelivered;
  final bool isUserBatting;
  final bool isGameOver;
  final String gameStatus;
  final int timeLeft;

  GameState({
    this.userScore = 0,
    this.botScore = 0,
    this.userInput = 0,
    this.botInput = 0,
    this.ballsDelivered = 0,
    this.isUserBatting = true,
    this.isGameOver = false,
    this.gameStatus = '',
    this.timeLeft = 10,
  });

  GameState copyWith({
    int? userScore,
    int? botScore,
    int? userInput,
    int? botInput,
    int? ballsDelivered,
    bool? isUserBatting,
    bool? isGameOver,
    String? gameStatus,
    int? timeLeft,
  }) {
    return GameState(
      userScore: userScore ?? this.userScore,
      botScore: botScore ?? this.botScore,
      userInput: userInput ?? this.userInput,
      botInput: botInput ?? this.botInput,
      ballsDelivered: ballsDelivered ?? this.ballsDelivered,
      isUserBatting: isUserBatting ?? this.isUserBatting,
      isGameOver: isGameOver ?? this.isGameOver,
      gameStatus: gameStatus ?? this.gameStatus,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
} 