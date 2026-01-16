import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/game/models/card.dart';
import '../core/game/models/player.dart';
import '../core/utils/audio_generator.dart';
import 'playing_card_widget.dart';

class MusTable extends StatefulWidget {
  const MusTable({
    required this.players,
    required this.onCardTap,
    super.key,
    this.selectedCards = const {},
    this.animationDuration = const Duration(milliseconds: 600),
  });

  final List<Player> players;
  final Function(int playerIndex, MusCard card) onCardTap;
  final Set<MusCard> selectedCards;
  final Duration animationDuration;

  @override
  State<MusTable> createState() => _MusTableState();
}

class _MusTableState extends State<MusTable> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playDealSound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playDealSound() async {
    // Generate sound once or check existence
    final String soundPath = await AudioGenerator.generateDealSound();
    await _audioPlayer.play(DeviceFileSource(soundPath));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );

        // Define positions: Bottom (User), Right, Top, Left
        final positions = [
          Offset(
            center.dx,
            constraints.maxHeight - 100,
          ), // Player 0 (Bottom/User)
          Offset(constraints.maxWidth - 60, center.dy), // Player 1 (Right)
          Offset(center.dx, 60), // Player 2 (Top)
          Offset(60, center.dy), // Player 3 (Left)
        ];

        return Stack(
          children: [
            // Felt Background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  radius: 0.8,
                ),
              ),
            ),

            // Central Deck / Pot Area
            Positioned(
              left: center.dx - 40,
              top: center.dy - 60,
              child: _buildDeckArea(),
            ),

            // Players
            for (int i = 0; i < 4; i++)
              _buildPlayerArea(i, positions[i], constraints),
          ],
        );
      },
    );
  }

  Widget _buildDeckArea() {
    return DragTarget<MusCard>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (card) {
        // Handle discount/play logic here
        // For visual feedback, we might want to animate the card into the pile
        debugPrint('Accepted card drop: $card');
        // Trigger generic callback or stream
        // widget.onCardDrop(card); // Need to add this to widget props if we want to use it
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.yellow : Colors.white24,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.change_history, color: Colors.white24, size: 40),
          ),
        );
      },
    );
  }

  Widget _buildPlayerArea(
    int index,
    Offset position,
    BoxConstraints constraints,
  ) {
    // Determine alignment based on index
    // 0: Bottom Center, 1: Right Center, 2: Top Center, 3: Left Center

    final player = widget.players.length > index ? widget.players[index] : null;
    if (player == null) {
      return const SizedBox();
    }

    double angle = 0;
    if (index == 1) {
      angle = -1.57; // 90 deg left
    }
    if (index == 2) {
      angle = 3.14; // 180 deg
    }
    if (index == 3) {
      angle = 1.57; // 90 deg right
    }

    final bool isCurrentUser = index == 0;

    return Positioned(
      left: index == 1 ? null : (index == 3 ? 0 : position.dx - 150),
      right: index == 1 ? 0 : null,
      top: index == 0 ? null : (index == 2 ? 0 : position.dy - 100),
      bottom: index == 0 ? 0 : null,
      child: Transform.rotate(
        angle: isCurrentUser ? 0 : angle,
        child: Container(
          width: 300,
          height: 180,
          // color: Colors.red.withOpacity(0.1), // Debug area
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isCurrentUser) _buildOpponentCards(player.hand.length),
              if (isCurrentUser) _buildUserHand(player, index),
              const SizedBox(height: 8),
              if (index != 0) // Avatar/Name placeholder
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: Text('P$index'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHand(Player player, int playerIndex) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: player.hand.asMap().entries.map((entry) {
          final idx = entry.key;
          final card = entry.value;

          // Fan effect
          final total = player.hand.length;
          final centerIdx = (total - 1) / 2;
          final offset = idx - centerIdx;
          final angle = offset * 0.1;
          final transX = offset * 40.0;
          final transY = offset.abs() * 5.0;

          return Positioned(
            bottom: 0,
            left: 150 + transX - 30, // center - half card width
            child: Transform.translate(
              offset: Offset(0, transY),
              child: Transform.rotate(
                angle: angle,
                child: Draggable<MusCard>(
                  data: card,
                  feedback: Material(
                    color: Colors.transparent,
                    child: PlayingCardWidget(
                      card: card,
                      width: 70,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: PlayingCardWidget(
                      card: card,
                      width: 70,
                    ),
                  ),
                  child: PlayingCardWidget(
                    card: card,
                    width: 70,
                    isSelected: widget.selectedCards.contains(card),
                    onTap: () => widget.onCardTap(playerIndex, card),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOpponentCards(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white),
            ),
          ),
        );
      }),
    );
  }
}
