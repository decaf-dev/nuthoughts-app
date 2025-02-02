import 'package:flutter/material.dart';

class ThoughtBubble extends StatefulWidget {
  const ThoughtBubble(this.text, this.onLongPress, {super.key});

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
              minWidth: 0,
              maxWidth: maxWidth,
            ),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onLongPress: widget.onLongPress,
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        )))));
      },
    );
  }
}
