import 'package:drag_speed_dial/drag_speed_dial.dart';
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
  bool isDraggable = true;
  DragSpeedDialChildrenAlignment alignment =
      DragSpeedDialChildrenAlignment.vertical;
  DragSpeedDialPosition initialPosition = DragSpeedDialPosition.bottomRight;
  bool snagOnScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('isDraggable: ')),
                      Switch(
                          value: isDraggable,
                          onChanged: (value) => {
                                setState(() {
                                  isDraggable = value;
                                })
                              }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('Snag on screen: ')),
                      Switch(
                          value: snagOnScreen,
                          onChanged: (value) => {
                                setState(() {
                                  snagOnScreen = value;
                                })
                              }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('Fab Aligment ')),
                      DropdownButton<DragSpeedDialChildrenAlignment>(
                          value: alignment,
                          items: DragSpeedDialChildrenAlignment.values
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (value) => {
                                setState(() {
                                  alignment = value!;
                                })
                              }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('Initial Position ')),
                      DropdownButton<DragSpeedDialPosition>(
                          value: initialPosition,
                          items: DragSpeedDialPosition.values
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (value) => {
                                setState(() {
                                  initialPosition = value!;
                                })
                              }),
                    ],
                  ),
                ],
              ),
            ),
            DragSpeedDial(
              isDraggable: isDraggable,
              alignment: alignment,
              initialPosition: initialPosition,
              snagOnScreen: snagOnScreen,
              fabBgColor: Colors.red,
              //actionOnPress: () => print("salut"),

              dragSpeedDialChildren: [
                DragSpeedDialChild(
                  onPressed: () {
                    print("bonjour");
                  },
                  bgColor: Colors.blue,
                  icon: const Icon(Icons.grade_outlined),
                ),
                DragSpeedDialChild(
                  onPressed: () {
                    print("salut");
                  },
                  bgColor: Colors.yellow,
                  icon: const Icon(Icons.inbox),
                ),
                DragSpeedDialChild(
                  onPressed: () {
                    print("salut");
                  },
                  bgColor: Colors.red,
                  icon: const Icon(Icons.headset_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
