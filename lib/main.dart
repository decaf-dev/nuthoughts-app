import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chisel App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Chisel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.notes,
                  color: Colors.white,
                ),
                onPressed: () {}),
            IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {}),
          ],
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('What are you thinking?',
                  style: Theme.of(context).textTheme.headlineSmall),
              Container(
                  padding: const EdgeInsets.all(20),
                  child: const TextField(
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: null)),
              MaterialButton(
                textColor: Colors.white,
                onPressed: () {},
                color: Colors.blue,
                child: const Text("Save"),
              )
            ],
          ),
        )));
  }
}
