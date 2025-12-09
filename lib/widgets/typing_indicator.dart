import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          SizedBox(width: 15),
          Text("AgroXpert AI is typing...", style: TextStyle(color: Colors.grey)),
          SizedBox(width: 10),
          AnimatedDots(),
        ],
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dots = (3 * _controller.value).round();
        return Text('.' * dots, style: const TextStyle(fontSize: 20, color: Colors.grey));
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
