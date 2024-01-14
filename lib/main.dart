
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled/ui/screens/game/game_view_model.dart';
import 'package:untitled/ui/screens/game/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then(run);
}

void run(void ignored) {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameViewModel(),
      child: const CheckersGameScreen(),
    ),
  );
}