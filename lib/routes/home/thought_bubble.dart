import 'package:flutter/material.dart';

class ThoughtBubble extends StatefulWidget {
  const ThoughtBubble(this.text, {super.key});

  final String text;

  @override
  State<ThoughtBubble> createState() => _ThoughtBubbleState();
}

class _ThoughtBubbleState extends State<ThoughtBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        widget.text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
