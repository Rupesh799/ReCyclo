import 'package:flutter/material.dart';

class FindingBuyerAnimation extends StatefulWidget {
  @override
  _FindingBuyerAnimationState createState() => _FindingBuyerAnimationState();
}

class _FindingBuyerAnimationState extends State<FindingBuyerAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 2 * 3.14,
              // origin: Offset(50.0, 50.0),
              child: Center(
                child: Icon(
                  Icons.circle_outlined,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            );
          },
        ),
        Text("Searching for Buyers",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
      ],
    );
  }
}