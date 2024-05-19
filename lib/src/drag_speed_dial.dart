import 'package:flutter/material.dart';

import 'drag_speed_dial_controller.dart';
import 'drag_speed_dial_widget.dart';

/// An enumeration representing the starting position of the `DrapSpeedDial` widget within its parent container.
///
/// This enumeration specifies where the `DrapSpeedDial` should initially appear within its parent container. 
/// Options include corners (topLeft, topRight, bottomLeft, bottomRight) and centers (topCenter, bottomCenter), 
/// allowing for flexible placement strategies based on the desired UI layout.
enum DrapSpeedDialPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
}

/// An enumeration representing the style for displaying `DrapSpeedDialChildren` within the `DrapSpeedDial` widget.
///
/// This enumeration defines how the child elements [DrapSpeedDialChildren] are organized within the `DrapSpeedDial`. 
/// It offers two options: arranging them horizontally or vertically, providing flexibility in how the UI elements are presented to the user.
enum DrapSpeedDialChilrendAligment{
  horizontal,
  vertical,
}

class DrapSpeedDialChild {
  /// Creates a new instance of `DrapSpeedDialChild`.
  ///
  /// [onPressed] is a callback that gets called when the button is pressed. It defaults to null if not provided.
  /// [icon] is the visual representation of the button. It cannot be null.
  /// [bgColor] is the background color of the button. It cannot be null.
  const DrapSpeedDialChild({
    this.onPressed,
    required this.icon,
    required this.bgColor,
  });

  final VoidCallback? onPressed;
  final Icon icon;
  final Color bgColor;
}

/// A custom widget that represents a draggable speed dial menu.
///
/// This widget allows users to interact with a floating action button (FAB)
/// that can display tomessages and perform actions when pressed. It supports
/// dragging to reveal additional options and customization through various parameters.
@immutable
class DragSpeeDial extends StatelessWidget {
  const DragSpeeDial({
    super.key,
    this.startMessageDuration = const Duration(seconds: 2),
    this.startMessage,
    this.actionOnPress,
    this.isDraggable = true,
    this.fabIcon = const Icon(Icons.menu),
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.aligment = DrapSpeedDialChilrendAligment.horizontal,
    this.dragSpeedDialChildren,
    this.snagOnScreen = false,
  })  : assert(offsetPosition != null || initialPosition != null,
            'InitialPosition or offsetPosition must be not null'),
        assert(actionOnPress != null || dragSpeedDialChildren != null,
            'ActionOnPress or dragSpeedDialChildren must be not null');

  factory DragSpeeDial.withStartMessage({
    Key? key,
    required String message,
    bool snagOnScreen = false,
    Duration startMessageDuration = const Duration(seconds: 2),
    VoidCallback? actionOnPress,
    Icon fabIcon = const Icon(Icons.menu),
    bool isDraggable = true,
    DrapSpeedDialPosition? initialPosition,
    Offset? offsetPosition,
    Color? fabBgColor,
    List<DrapSpeedDialChild>? dragSpeedDialChildren,
    DrapSpeedDialChilrendAligment aligment = DrapSpeedDialChilrendAligment.horizontal,
  }) {
    
    return DragSpeeDial(
      startMessage: message,
      startMessageDuration: startMessageDuration,
      actionOnPress: actionOnPress,
      isDraggable: isDraggable,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      aligment: aligment,
      dragSpeedDialChildren: dragSpeedDialChildren,
      snagOnScreen: snagOnScreen,
    );
  }

/// The duration for which the start message should be displayed.
final Duration startMessageDuration;

/// The message to be displayed at the start.
final String? startMessage;

/// Callback function to be executed when the FAB is pressed.
final VoidCallback? actionOnPress;

/// Whether the FAB can be dragged.
final bool isDraggable;

/// Initial position of the FAB.
/// 
/// If [offsetPosition] is not null, this property is ignored.
final DrapSpeedDialPosition? initialPosition;

/// Offset position of the FAB.
/// 
/// If [initialPosition] is not null, this property is ignored.
final Offset? offsetPosition;

/// Icon displayed on the FAB.
final Icon fabIcon;

/// Background color of the FAB.
final Color? fabBgColor;

/// Children widgets of the FAB.
final List<DrapSpeedDialChild>? dragSpeedDialChildren;

/// Style alignment of the [DrapSpeedDialChilrend] widgets.
final DrapSpeedDialChilrendAligment aligment;

/// Whether the FAB should snap on screen.
final bool snagOnScreen;

  @override
  Widget build(BuildContext context) {
    return FloatingSnapButtonView(
      actionOnPress: actionOnPress,
      messageDuration: startMessageDuration,
      startMessage: startMessage,
      isDraggable: isDraggable,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      childrenStyle: aligment,
      dragSpeedDialChildren: dragSpeedDialChildren,
      snagOnScreen: snagOnScreen,
    );
  }
}

/// The FloatingSnapButton widget.
class FloatingSnapButtonView extends StatelessWidget {
  const FloatingSnapButtonView({
    super.key,
    required this.messageDuration,
    required this.isDraggable,
    required this.fabIcon,
    required this.childrenStyle,
    required this.snagOnScreen,
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.dragSpeedDialChildren,
    this.actionOnPress,
    this.startMessage,
  });

  final bool snagOnScreen;
  final String? startMessage;
  final Duration messageDuration;
  final VoidCallback? actionOnPress;
  final bool isDraggable;
  final DrapSpeedDialPosition? initialPosition;
  final Offset? offsetPosition;
  final Icon fabIcon;
  final DrapSpeedDialChilrendAligment childrenStyle;
  final Color? fabBgColor;
  final List<DrapSpeedDialChild>? dragSpeedDialChildren;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final controller = DragSpeedDialController(
        snagOnScreen: snagOnScreen,
        isDraggable: isDraggable,
        initialPosition: initialPosition,
        offsetPosition: offsetPosition,
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        fabIcon: fabIcon,
        fabBgColor: fabBgColor ??
            Theme.of(context).floatingActionButtonTheme.backgroundColor ??
            Colors.pink,
        dragSpeedDialChildren: dragSpeedDialChildren,
        childrenStyle: childrenStyle);
    return DragSpeedDialButtonAnimation(
      startMessage: startMessage,
      messageDuration: messageDuration,
      controller: controller,
      actionOnPress: actionOnPress,
    );
  }
}

class PreferencesKeys {
  static const String isButtonCollapsed = 'isButtonCollapsed';
}

const darkLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(60, 28, 20, 1),
      Color.fromRGBO(61, 29, 18, 1),
      Color.fromRGBO(52, 23, 15, 1),
      Color.fromRGBO(46, 21, 14, 1),
      Color.fromRGBO(40, 18, 13, 1),
      Color.fromRGBO(30, 16, 11, 1),
      Color.fromRGBO(29, 14, 10, 1),
      Color.fromRGBO(16, 9, 6, 1),
    ]);

const lightLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(245, 245, 245, 1),
      Color.fromRGBO(245, 245, 245, 1),
      Color.fromRGBO(245, 245, 245, 1),
      Color.fromRGBO(245, 245, 245, 1),
    ]);
