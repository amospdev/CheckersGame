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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            _button(Icons.menu, () {}),
            Spacer(),
            _button(Icons.chat, () {}),
            _button(
                Icons.undo, isUndoEnable ? () => gameViewModel.undo() : null),
          ],
        );
      },
    );
  }

  Widget _button(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 60, // Adjust the width of the container
      height: 60, // Adjust the height of the container
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/new_button.png'),
          // Replace with your background image
          fit: BoxFit.cover, // You can adjust the fit as needed
        ),
      ),
      child: IconButton(
          color: Colors.white,
          disabledColor: Colors.grey.shade400,
          iconSize: 24,
          onPressed: onPressed,
          icon: Icon(icon)),
    );
  }
}
