import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    required this.onMus,
    required this.onCut,
    super.key,
    this.canMus = false,
    this.canCut = false,
  });

  final VoidCallback onMus;
  final VoidCallback onCut;
  final bool canMus;
  final bool canCut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: canMus ? onMus : null,
            icon: const Icon(Icons.check),
            label: const Text('MUS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: canCut ? onCut : null,
            icon: const Icon(Icons.close),
            label: const Text('NO HAY MUS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
