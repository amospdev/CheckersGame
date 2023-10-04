class Player {
  static const int LOSS = -1;
  static const int TIED = 0;
  static const int WIN = 1;
  int number = 0;
  String name = "";
  String imageUrl = "";
  int score = 0;

  // Variables for statistics
  int gamePlayed = 0, moveCount = 0;
  int wins = 0, currentWinningStreak = 0, longestWinningStreak = 0;
  int losses = 0, currentLosingStreak = 0, longestLosingStreak = 0;
  int tied = 0;
  int allTimeScore = 0;
  int allTimeKings = 0, mostKings = 0, currentKingCount = 0;
  int currentJumpStreak = 0, longestJump = 0;

  Player({this.number = 1}) {
    name = "Player $number";
    score = 0;
  }

  void resetJumpStreak() {
    currentJumpStreak = 0;
  }

  void reset() {
    score = 0;
    currentJumpStreak = 0;
    currentKingCount = 0;
  }

  void increaseGameCount() {
    gamePlayed++;
  }

  void setScore() {
    score++;
    allTimeScore++;
  }

  /// Set the statistics at the end of a game.
  ///
  /// @param val if val < 0 it means a loss,if val = 0, it means a tie and if > 0
  ///            it means a win
  void setStatistics(int val) {
    if (val > TIED) {
      wins++;
      currentWinningStreak++;
      currentLosingStreak = 0;
      if (currentWinningStreak > longestWinningStreak) {
        longestWinningStreak = currentWinningStreak;
      }
    } else if (val < TIED) {
      losses++;
      currentLosingStreak++;
      currentWinningStreak = 0;
      if (currentLosingStreak > longestLosingStreak) {
        longestLosingStreak = currentLosingStreak;
      }
    } else {
      tied++;
      currentLosingStreak = 0;
      currentWinningStreak = 0;
    }
  }

  void setAllTimeKings() {
    allTimeKings++;
    currentKingCount++;
    if (currentKingCount > mostKings) {
      mostKings = currentKingCount;
    }
  }

  void increaseJumpStreak() {
    currentJumpStreak++;
    if (currentJumpStreak > longestJump) {
      longestJump = currentJumpStreak;
    }
  }

  double getAverageScore() => gamePlayed == 0 ? 0.0 : allTimeScore / gamePlayed;

  double getAvgKings() => gamePlayed == 0 ? 0.0 : allTimeKings / gamePlayed;

  double getAvgMove() => gamePlayed == 0 ? 0.0 : moveCount / gamePlayed;
}
