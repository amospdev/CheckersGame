import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/game_view_model.dart';

class Features extends StatelessWidget {
  const Features({super.key});

  @override
  Widget build(BuildContext context) => _features(context);

  Widget _features(BuildContext context) {
    GameViewModel gameViewModel =
        Provider.of<GameViewModel>(context, listen: false);

    return ValueListenableBuilder<bool>(
      valueListenable: gameViewModel.isUndoEnable,
      builder: (ctx, isUndoEnable, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 80, // Adjust the width of the container
              height: 80, // Adjust the height of the container
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/button_wood.png'),
                  // Replace with your background image
                  fit: BoxFit.cover, // You can adjust the fit as needed
                ),
              ),
              child: IconButton(
                  color: Colors.white,
                  disabledColor: Colors.grey.shade400,
                  iconSize: 34,
                  onPressed: isUndoEnable ? () => gameViewModel.undo() : null,
                  icon: const Icon(Icons.undo)),
            ),
            Container(
              width: 80, // Adjust the width of the container
              height: 80, // Adjust the height of the container
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/button_wood.png'),
                  // Replace with your background image
                  fit: BoxFit.cover, // You can adjust the fit as needed
                ),
              ),
              child: IconButton(
                  color: Colors.white,
                  disabledColor: Colors.grey.shade400,
                  iconSize: 34,
                  onPressed:
                      isUndoEnable ? () => gameViewModel.resetGame() : null,
                  icon: const Icon(Icons.refresh)),
            )
          ],
        );
      },
    );
  }
}
