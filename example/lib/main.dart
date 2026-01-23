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
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('Snag on screen: '),
                        ),
                        Switch(
                          value: snagOnScreen,
                          onChanged: (value) => {
                            setState(() {
                              snagOnScreen = value;
                            }),
                          },
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('isDraggable: '),
                        ),
                        Switch(
                          value: isDraggable,
                          onChanged: (value) => {
                            setState(() {
                              isDraggable = value;
                            }),
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('Fab Aligment '),
                        ),
                        DropdownButton<DragSpeedDialChildrenAlignment>(
                          value: alignment,
                          items: DragSpeedDialChildrenAlignment.values
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => {
                            if (value != null)
                              {
                                setState(() {
                                  alignment = value;
                                }),
                              },
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DefaultTextStyle(
                          style: TextStyle(color: Colors.black),
                          child: Text('Initial Position '),
                        ),
                        DropdownButton<DragSpeedDialPosition>(
                          value: initialPosition,
                          items: DragSpeedDialPosition.values
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => {
                            setState(() {
                              initialPosition = value!;
                            }),
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            DragSpeedDial(
              isDraggable: isDraggable,
              alignment: alignment,
              offsetPosition: const Offset(0, 0),
              snagOnScreen: snagOnScreen,
              fabBgColor: Colors.red,
              fabIcon: const Icon(Icons.add, color: Colors.white),
              actionOnPress: () => print("salut"),
            ),
          ],
        ),
      ),
    );
  }
}
