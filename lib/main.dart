import 'package:floating_snap_button/floating_snap_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          FloatingSnapButton.withStartMessage(
            messageDuration: const Duration(seconds: 2),
            message: 'Hello World',
            isDraggable: true,
            childrenStyle: ChildrenStyle.horizontal,
            initialPosition: Position.topRight,
            children: [
              ActionButton(
                onPressed: () {print("bonjour");},
                icon: const Icon(Icons.format_size),
                color: Colors.red,
              ),
              ActionButton(
                onPressed: () {
                  print("salut");
                },
                icon: const Icon(Icons.insert_photo),
                color: Colors.green,
              ),
              ActionButton(
                onPressed: () {
                  print("salutoooo");
                },
                icon: const Icon(Icons.videocam),
                color: Colors.black,
              ),
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
