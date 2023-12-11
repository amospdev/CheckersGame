import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:untitled/main.dart';

class PlayerPagerCard extends StatefulWidget {
  final String avatarPath;
  final String playerName;
  final Widget pawnStatusChange;

  const PlayerPagerCard(
      {super.key,
      required this.avatarPath,
      required this.playerName,
      required this.pawnStatusChange});

  @override
  State<PlayerPagerCard> createState() => _PlayerPagerCardState();
}

class _PlayerPagerCardState extends State<PlayerPagerCard> {
  late int selectedPage;
  late final PageController _pageController;

  @override
  void initState() {
    selectedPage = 0;
    _pageController = PageController(initialPage: selectedPage);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => _playerPager(
      avatarPath: widget.avatarPath,
      playerName: widget.playerName,
      pawnStatusChange: widget.pawnStatusChange);

  Widget _playerPager(
      {required String avatarPath,
      required String playerName,
      required Widget pawnStatusChange}) {
    return Container(
      height: 130,
      width: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameBoardState.borderRoundedPlayerCard, // Green border
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Expanded(
              flex: 4,
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    selectedPage = page;
                  });
                },
                children: [
                  _player(
                    playerName: playerName,
                    avatarPath: avatarPath,
                  ),
                  pawnStatusChange,
                  Container(
                    alignment: Alignment.center,
                    child: const Text("PLAYER DATA"),
                  )
                ],
              )),
          Expanded(
            child: PageViewDotIndicator(
              padding: EdgeInsets.zero,
              // margin: EdgeInsets.zero,
              size: const Size(10, 10),
              currentItem: selectedPage,
              count: 3,
              unselectedColor: Colors.black26,
              selectedColor: Colors.white70,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
              onItemClicked: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _player({required String avatarPath, required String playerName}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, top: 6),
            child: Text(
              playerName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          _circleAvatarPlayer(filePath: avatarPath),
        ],
      );

  Widget _circleAvatarPlayer({required filePath}) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: GameBoardState.borderCircleAvatar,
            // Set the color of the border
            width: 2, // Set the width of the border
          ),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.9), blurRadius: 3)
          ]),
      child: CircleAvatar(
        radius: 30.0, // Adjust the radius as needed
        backgroundColor: Colors.white,
        child: Image.asset(
          filePath,
          height: 50,
        ),
      ),
    );
  }
}
