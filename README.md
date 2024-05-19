# Drag Speed Dial

This package provides a highly customizable and interactive floating action button (FAB) that not only responds to taps but also offers a dynamic drag-to-reveal feature. Perfect for apps seeking to enhance navigation efficiency and user engagement without compromising on aesthetics.

<div style="display:flex; justify-content: space-between;">
<img src="https://raw.githubusercontent.com/Tughra/drag_speed_dial/master/screenshots/demo1.gif" width="250" height="500" />
<img src="https://raw.githubusercontent.com/Tughra/drag_speed_dial/master/screenshots/demo2.gif" width="250" height="500" />
<img src="https://raw.githubusercontent.com/Tughra/drag_speed_dial/master/screenshots/demo3.gif" width="250" height="500" />
<img src="https://raw.githubusercontent.com/Tughra/drag_speed_dial/master/screenshots/demo4.gif" width="250" height="500" />
</div>

## 💻 Installation

In the dependencies: section of your pubspec.yaml, add the following line:

```yaml
dependencies:
  drag_speed_dial: <latest version>
```

## ❔ Usage

Import this class

```dart
import 'package:drag_speed_dial/drag_speed_dial.dart';
```

Simple Implementation

```dart

DragSpeeDial(
    startMessage: "Hello 👋",
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
    ],
),
```

## Main Property

| Attribute     | Type   | Default |  Description
|---------------|--------|-------------|--------------------------|
| isDraggable     | bool | true | Whether the FAB can be dragged |
| snagOnScreen      | bool | false | Whether the FAB should snap on screen. |
| aligment      | DrapSpeedDialChilrendAligment| DrapSpeedDialChilrendAligment.horizontal  | represents the aligment style of drag speed children|
| dragSpeedDialChildren  | DrapSpeedDialChild[]  | Children widgets of the FAB. |
| initialPosition | DrapSpeedDialPosition | / |  Initial position of the FAB |
