import 'package:chisel/routes/saved_blocks/saved_blocks_route.dart';
import 'package:chisel/routes/settings/settings_route.dart';
import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.title});

  final String title;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SavedBlocksRoute()),
                  );
                }),
            IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsRoute()),
                  );
                }),
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
                  child: TextField(
                      controller: myController,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: null)),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  myController.clear();
                },
                child: const Text("Save"),
              )
            ],
          ),
        )));
  }
}
