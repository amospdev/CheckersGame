import 'package:untitled/enum/game_mode_types.dart';

class SettingsRepository {
  GameMode _gameMode = GameMode.OFFLINE_MODE;

  GameMode get gameMode => _gameMode;

  int _depthLevel = 5;

  int get depthLevel => _depthLevel;

  void setGameMode(GameMode gameMode) {
    _gameMode = gameMode;
  }

  void setDepthLevel(int depthLevel) {
    _depthLevel = depthLevel;
  }

  bool get isAIMode => _gameMode == GameMode.AI_MODE;
  bool get isOnlineGameMode => _gameMode == GameMode.ONLINE_MODE;
  bool get isOfflineGameMode => _gameMode == GameMode.OFFLINE_MODE;
}
