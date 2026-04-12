import 'package:flutter/material.dart';

class GameIconWidget extends StatelessWidget {
  final bool isFavorite;
  final Widget destination;

  const GameIconWidget({
    super.key,
    this.isFavorite = false,
    required this.destination
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination)
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFavorite ? Colors.black : Colors.transparent,
          border: Border.all(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}