import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/game/models/card.dart';
import '../core/game/models/player.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/audio_generator.dart';
import 'playing_card_widget.dart';

class MusTable extends StatefulWidget {
  const MusTable({
    required this.players,
    required this.onCardTap,
    super.key,
    this.selectedCards = const {},
    this.animationDuration = const Duration(milliseconds: 600),
    this.manoIndex = 0,
    this.currentTurn = -1,
    this.lastAction = '',
    this.lastActionPlayerIndex = -1,
    this.declarations = const {},
  });

  final List<Player> players;
  final Function(int playerIndex, MusCard card) onCardTap;
  final Set<MusCard> selectedCards;
  final Duration animationDuration;
  final int manoIndex;
  final int currentTurn;
  final String lastAction;
  final int lastActionPlayerIndex;
  final Map<int, String> declarations;

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
            constraints.maxHeight - 80,
          ), // Player 0 (Bottom/User)
          Offset(constraints.maxWidth - 50, center.dy), // Player 1 (Right)
          Offset(center.dx, 60), // Player 2 (Top)
          Offset(50, center.dy), // Player 3 (Left)
        ];

        return Stack(
          children: [
            // Felt Background (Using AppColors)
            Container(color: AppColors.tableGreenClassic),

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
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(50), width: 1),
      ),
      child: const Center(
        child: Icon(Icons.style, color: Colors.white24, size: 40),
      ),
    );
  }

  Widget _buildPlayerArea(
    int index,
    Offset position,
    BoxConstraints constraints,
  ) {
    final player = widget.players.length > index ? widget.players[index] : null;
    if (player == null) {
      return const SizedBox();
    }

    final bool isCurrentUser = index == 0;
    final bool isRight = index == 1;
    final bool isTop = index == 2;
    final bool isLeft = index == 3;

    final bool isMano = widget.manoIndex == index;
    final bool isTurn = widget.currentTurn == index;

    // Avatar Position
    double? left, top, right, bottom;

    if (isCurrentUser) {
      left = position.dx - 150;
      bottom = 20;
    } else if (isTop) {
      left = position.dx - 150;
      top = 20;
    } else if (isRight) {
      right = 20;
      top = position.dy - 100;
    } else if (isLeft) {
      left = 20;
      top = position.dy - 100;
    }

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: SizedBox(
        width: 300,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cards
            if (isCurrentUser)
              Positioned(
                bottom: 0,
                child: _buildUserHand(player, index),
              )
            else
              Positioned(
                top: isTop ? 60 : 40,
                left: isLeft ? 60 : null,
                right: isRight ? 60 : null,
                child: _buildOpponentCards(player.hand.length),
              ),

            // Avatar & Name & Indicators
            Positioned(
              top: isCurrentUser ? null : (isTop ? 0 : 60),
              bottom: isCurrentUser ? 130 : null,
              left: isLeft ? 0 : (isRight ? null : 110),
              right: isRight ? 0 : (isLeft ? null : 110),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                       // Turn Glow
                       if (isTurn)
                        Container(
                          width: isCurrentUser ? 74 : 64,
                          height: isCurrentUser ? 74 : 64,
                           decoration: BoxDecoration(
                            shape: BoxShape.circle,
                             boxShadow: [
                               BoxShadow(
                                 color: AppColors.accentGold,
                                 blurRadius: 15,
                                 spreadRadius: 2,
                               ),
                             ],
                           ),
                        ),
                      Container(
                        width: isCurrentUser ? 60 : 50,
                        height: isCurrentUser ? 60 : 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isTurn ? AppColors.accentGold : (isMano ? Colors.white : AppColors.border),
                            width: isTurn ? 3 : 2,
                          ),
                          color: AppColors.backgroundCard,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            player.name[0],
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: isCurrentUser ? 24 : 18,
                            ),
                          ),
                        ),
                      ),
                      if (isMano)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              'M',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      border: isTurn ? Border.all(color: AppColors.accentGold, width: 1) : null,
                    ),
                    child: Text(
                      player.name,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Speech Bubble (Last Action)
            if (widget.lastActionPlayerIndex == index &&
                widget.lastAction.isNotEmpty)
               _buildPositionedBubble(
                text: widget.lastAction,
                isTop: isTop,
                isBottom: isCurrentUser,
                isLeft: isLeft,
                isRight: isRight,
                type: BubbleType.action,
               ),

            // Declaration Bubble (Persistent)
            if (widget.declarations.containsKey(index))
                _buildPositionedBubble(
                  text: widget.declarations[index]!,
                  isTop: isTop,
                  isBottom: isCurrentUser,
                  isLeft: isLeft,
                  isRight: isRight,
                  type: BubbleType.declaration,
                ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionedBubble({
      required String text,
      required bool isTop,
      required bool isBottom,
      required bool isLeft,
      required bool isRight,
      required BubbleType type,
  }) {
      double shiftY = type == BubbleType.declaration ? -35 : 0;
      if (isLeft || isRight) shiftY = type == BubbleType.declaration ? 35 : 0;
      
      // Closer positioning
      double? top, bottom, left, right;
      
      if (isBottom) {
         bottom = 190 + shiftY;
         // Center horizontally
      } else if (isTop) {
         top = 85 - shiftY;
      } else if (isLeft) {
         top = 80 + shiftY;
         left = 85; 
      } else if (isRight) {
         top = 80 + shiftY;
         right = 85;
      }
      
      return Positioned(
         top: top,
         bottom: bottom,
         left: left,
         right: right,
         child: Center(child: _buildSpeechBubble(text, type)),
      );
  }

  Widget _buildSpeechBubble(String text, BubbleType type) {
    Color bg = Colors.white;
    Color txt = Colors.black87;
    
    if (type == BubbleType.declaration) {
       if (text == 'NO') {
          bg = Colors.grey.shade300;
          txt = Colors.grey.shade700;
       } else {
          bg = AppColors.accentGold;
          txt = Colors.black;
       }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: txt,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ... (rest of methods)

  Widget _buildUserHand(Player player, int playerIndex) {
    return SizedBox(
      height: 120,
      width: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: player.hand.asMap().entries.map((entry) {
          final idx = entry.key;
          final card = entry.value;
          final total = player.hand.length;
          final centerIdx = (total - 1) / 2;
          final offset = idx - centerIdx;
          final angle = offset * 0.1;
          final transX = offset * 35.0;
          final transY = offset.abs() * 5.0;

          return Positioned(
            bottom: 30, // Raise cards a bit
            left: 100 + transX - 35, // center (100) - half width (35)
            child: Transform.translate(
              offset: Offset(0, transY),
              child: Transform.rotate(
                angle: angle,
                child: PlayingCardWidget(
                  card: card,
                  width: 70,
                  isSelected: widget.selectedCards.contains(card),
                  onTap: () => widget.onCardTap(playerIndex, card),
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
            width: 30, // Smaller for opponents
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 2,
                   offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

enum BubbleType { action, declaration }
