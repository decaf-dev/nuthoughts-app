import 'package:flutter/material.dart';

class ThoughtBubble extends StatefulWidget {
  const ThoughtBubble(this.text, this.onLongPress, {Key? key})
      : super(key: key);

  final Function() onLongPress;
  final String text;

  @override
  State<ThoughtBubble> createState() => _ThoughtBubbleState();
}

class _ThoughtBubbleState extends State<ThoughtBubble> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth * 0.75;

        return ConstrainedBox(
            constraints: BoxConstraints(
              // No minimum width => can shrink to fit
              minWidth: 0,
              maxWidth: maxWidth,
            ),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onLongPress: widget.onLongPress,
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        widget.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ))));
      },
    );
  }
}
