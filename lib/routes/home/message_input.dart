import 'package:flutter/material.dart';
import 'package:nuthoughts/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';

class MessageInput extends StatefulWidget {
  const MessageInput(this.onChanged, this.onSendPressed, {super.key});

  final ValueChanged<String> onChanged;
  final Function(String) onSendPressed;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeTextController();
  }

  void initializeTextController() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller.text = prefs.getString(constants.textKey) ?? '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    widget.onSendPressed(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'What are you thinking?',
                ),
                controller: _controller,
                onChanged: (text) {
                  setState(() {});
                  widget.onChanged(_controller.text);
                },
              ),
              // child: TextField(
              //   controller: _controller,
              //   decoration: const InputDecoration(
              //     hintText: 'What are you thinking?',
              //   ),
              //   onChanged: (text) {
              //     setState(() {});
              //     widget.onChanged(_controller.text);
              //   },
              // ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: Colors.deepPurple,
              disabledColor: Colors.grey,
              onPressed: _controller.text.isEmpty ? null : _sendMessage,
            ),
          ],
        ));
  }
}
