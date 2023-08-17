import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/game_view_model.dart';
import 'checkers_board_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameViewModel(),
      child: MaterialApp(
        title: 'Flutter Checkers',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Checkers'),
          ),
          body: CheckerBoard(),
        ),
      ),
    );
  }
}
