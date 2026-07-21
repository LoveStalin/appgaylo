import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final bool isRight;

  const ChatBubble({super.key, required this.isRight});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Thời gian 1 vòng lặp của animation ... 
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: widget.isRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isRight ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Semantics(
              label: '\u0110ang nh\u1eadp',
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final progress = (_controller.value - index * .16) % 1;
                    final opacity = .35 + .65 * (1 - (progress - .5).abs() * 2);
                    final offset = -3 * (1 - (progress - .5).abs() * 2);

                    return Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                      child: Opacity(
                        opacity: opacity.clamp(.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, offset),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: widget.isRight
                                  ? Colors.white
                                  : Colors.black54,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
