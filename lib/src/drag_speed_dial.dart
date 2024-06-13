import 'package:flutter/material.dart';

import 'drag_speed_dial_controller.dart';
import 'drag_speed_dial_widget.dart';

/// An enumeration representing the starting position of the `DragSpeedDial` widget within its parent container.
///
/// This enumeration specifies where the `DragSpeedDial` should initially appear within its parent container.
/// Options include corners (topLeft, topRight, bottomLeft, bottomRight) and centers (topCenter, bottomCenter),
/// allowing for flexible placement strategies based on the desired UI layout.
enum DragSpeedDialPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
}

/// An enumeration representing the style for displaying `DragSpeedDialChildren` within the `DragSpeedDial` widget.
///
/// This enumeration defines how the child elements [DragSpeedDialChildren] are organized within the `DragSpeedDial`.
/// It offers two options: arranging them horizontally or vertically, providing flexibility in how the UI elements are presented to the user.
enum DragSpeedDialChildrenAlignment {
  horizontal,
  vertical,
}

class DragSpeedDialChild {
  /// Creates a new instance of `DragSpeedDialChild`.
  ///
  /// [onPressed] is a callback that gets called when the button is pressed. It defaults to null if not provided.
  /// [icon] is the visual representation of the button. It cannot be null.
  /// [bgColor] is the background color of the button. It cannot be null.
  const DragSpeedDialChild({
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
/// that can display tooltip  and perform actions when pressed. It supports
/// dragging to reveal additional options and customization through various parameters.
@immutable
class DragSpeedDial extends StatelessWidget {
  const DragSpeedDial({
    super.key,
    this.tooltipMessage,
    this.actionOnPress,
    this.isDraggable = true,
    this.fabIcon = const Icon(Icons.menu),
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.alignment = DragSpeedDialChildrenAlignment.horizontal,
    this.dragSpeedDialChildren,
    this.snagOnScreen = false,
  })  : assert(offsetPosition != null || initialPosition != null,
            '`InitialPosition` or `offsetPosition` must be specified'),
        assert((actionOnPress == null) != (dragSpeedDialChildren == null),
            'Either `ActionOnPress` or `dragSpeedDialChildren` must be specified');

  /// The tooltip message.
  final String? tooltipMessage;

  /// Callback function to be executed when the FAB is pressed.
  final VoidCallback? actionOnPress;

  /// Whether the FAB can be dragged.
  final bool isDraggable;

  /// Initial position of the FAB.
  ///
  /// If [offsetPosition] is not null, this property is ignored.
  final DragSpeedDialPosition? initialPosition;

  /// Offset position of the FAB.
  ///
  /// If [initialPosition] is not null, this property is ignored.
  final Offset? offsetPosition;

  /// Icon displayed on the FAB.
  final Icon fabIcon;

  /// Background color of the FAB.
  final Color? fabBgColor;

  /// Children widgets of the FAB.
  final List<DragSpeedDialChild>? dragSpeedDialChildren;

  /// Style alignment of the [DragSpeedDialChilrend] widgets.
  final DragSpeedDialChildrenAlignment alignment;

  /// Whether the FAB should snap on screen.
  final bool snagOnScreen;

  @override
  Widget build(BuildContext context) {
    return FloatingSnapButtonView(
      actionOnPress: actionOnPress,
      tooltipMessage: tooltipMessage,
      isDraggable: isDraggable,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      childrenStyle: alignment,
      dragSpeedDialChildren: dragSpeedDialChildren,
      snagOnScreen: snagOnScreen,
    );
  }
}

/// The FloatingSnapButton widget.
class FloatingSnapButtonView extends StatelessWidget {
  const FloatingSnapButtonView({
    super.key,
    required this.isDraggable,
    required this.fabIcon,
    required this.childrenStyle,
    required this.snagOnScreen,
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.dragSpeedDialChildren,
    this.actionOnPress,
    this.tooltipMessage,
  });

  final bool snagOnScreen;
  final String? tooltipMessage;
  final VoidCallback? actionOnPress;
  final bool isDraggable;
  final DragSpeedDialPosition? initialPosition;
  final Offset? offsetPosition;
  final Icon fabIcon;
  final DragSpeedDialChildrenAlignment childrenStyle;
  final Color? fabBgColor;
  final List<DragSpeedDialChild>? dragSpeedDialChildren;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

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
      tooltipMessage: tooltipMessage,
      controller: controller,
      actionOnPress: actionOnPress,
    );
  }
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
