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
  DrapSpeedDialChilrendAligment aligment =
      DrapSpeedDialChilrendAligment.vertical;
  DrapSpeedDialPosition initialPosition = DrapSpeedDialPosition.bottomRight;
  bool snagOnScreen = false;
  String? startMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
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
                        child: Text('Message ')),
                        SizedBox(
                          width: 150,

                          child: TextField(
                            onChanged: (value) => {
                              setState(() {
                                startMessage = value.isEmpty ? null : value;
                              })
                            },
                          
                          ),
                        )
                    
                  ],
                ),
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
                    DropdownButton<DrapSpeedDialChilrendAligment>(
                        value: aligment,
                        items: DrapSpeedDialChilrendAligment.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ))
                            .toList(),
                        onChanged: (value) => {
                              setState(() {
                                aligment = value!;
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
                    DropdownButton<DrapSpeedDialPosition>(
                        value: initialPosition,
                        items: DrapSpeedDialPosition.values
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
          DragSpeeDial(
            isDraggable: isDraggable,
            aligment: aligment,
            initialPosition: initialPosition,
            snagOnScreen: snagOnScreen,
            startMessage: startMessage,
            fabIcon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            dragSpeedDialChildren: [
              DrapSpeedDialChild(
                onPressed: () {
                  print("bonjour");
                },
                bgColor: Colors.blue,
                icon: const Icon(Icons.grade_outlined),
              ),
              DrapSpeedDialChild(
                onPressed: () {
                  print("salut");
                },
                bgColor: Colors.yellow,
                icon: const Icon(Icons.inbox),
              ),
              DrapSpeedDialChild(
                onPressed: () {
                  print("saluoot");
                },
                bgColor: Colors.yellow,
                icon: const Icon(Icons.inbox),
              ),
              DrapSpeedDialChild(
                onPressed: () {
                  print("salutppp");
                },
                bgColor: Colors.yellow,
                icon: const Icon(Icons.inbox),
              ),
            ],
          ),
        
        
        ],
      ),
    );
  }
}

class SpeedDial extends StatefulWidget {
  @override
  _SpeedDialState createState() => _SpeedDialState();
}

class _SpeedDialState extends State<SpeedDial>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  bool _isDialOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // This is the target widget
        CompositedTransformTarget(
          link: this._layerLink,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isDialOpen = !_isDialOpen;
              });
            },
            child: const Icon(Icons.add),
            heroTag: null, // to prevent hero animation
          ),
        ),
        // This is the overlay widget
        Positioned(
          right: 20,
          bottom: 20,
          child: _isDialOpen ? _buildDial() : Container(),
        ),
      ],
    );
  }

  Widget _buildDial() {
    return CompositedTransformFollower(
      link: this._layerLink,
      showWhenUnlinked: false,
      offset:
          const Offset(0.0, -80.0), // Offset to position the dial above the FAB
      child: Material(
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Option 1'),
              onTap: () {
                // Handle option 1 tap
              },
            ),
            ListTile(
              title: const Text('Option 2'),
              onTap: () {
                // Handle option 2 tap
              },
            ),
          ],
        ),
      ),
    );
  }
}
