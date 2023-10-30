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
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
              text: widget.text, style: const TextStyle(color: Colors.white)),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final double maxWidth = textPainter.didExceedMaxLines
            ? constraints.maxWidth * 0.75
            : textPainter.width + 30; // Adding 30 for padding

        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {},
                onLongPress: widget.onLongPress,
                child: Ink(
                  width: maxWidth,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    widget.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                )));
      },
    );
  }
}
