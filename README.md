# Drag Speed Dial

This package provides a highly customizable and interactive floating action button (FAB) that not only responds to taps but also offers a dynamic drag-to-reveal feature. Perfect for apps seeking to enhance navigation efficiency and user engagement without compromising on aesthetics.

<div style="display:flex; justify-content: space-between; gap: 20px;">
    <img src="https://raw.githubusercontent.com/warrenrhodes/drag_speed_dial/master/screenshots/demo1.gif" width="250" height="450" />
    <img src="https://raw.githubusercontent.com/warrenrhodes/drag_speed_dial/master/screenshots/demo3.gif" width="250" height="450" />
    <img src="https://raw.githubusercontent.com/warrenrhodes/drag_speed_dial/master/screenshots/demo4.gif" width="250" height="450" />
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

DragSpeedDial(
    isDraggable: false,
    fabIcon: const Icon(
        Icons.add,
        color: Colors.white,
    ),
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
    ],
),
```

## Main Properties

| Attribute             | Type                          | Default                                   | Description                                           |
| --------------------- | ----------------------------- | ----------------------------------------- | ----------------------------------------------------- |
| isDraggable           | bool                          | true                                      | Whether the FAB can be dragged                        |
| snagOnScreen          | bool                          | false                                     | Whether the FAB should snap on screen.                |
| alignment             | DragSpeedDialChilrenAlignment | DragSpeedDialChildrenAlignment.horizontal | represents the alignment style of drag speed children |
| dragSpeedDialChildren | DragSpeedDialChild[]          | Children widgets of the FAB.              |
| initialPosition       | DragSpeedDialPosition         | /                                         | Initial position of the FAB                           |
