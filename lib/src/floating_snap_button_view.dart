import 'package:flutter/material.dart';

import 'floating_snap_button_controller.dart';
import 'widget.dart';

final parentGlobalKey = GlobalKey<State>();

enum Position {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
}

enum ChildrenStyle {
  horizontal,
  vertical,
}

@immutable
class FloatingSnapButton extends StatelessWidget {
  FloatingSnapButton({
    super.key,
    required this.displayMessageOnStart,
    this.startMessage,
    required this.messageDuration,
    this.actionOnPress,
    required this.isDraggable,
    required this.fabIcon,
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.childrenStyle = ChildrenStyle.horizontal,
    this.children,
  }) {
    assert(offsetPosition != null || initialPosition != null);
    assert(actionOnPress != null || children != null);
  }

  factory FloatingSnapButton.withStartMessage({
    Key? key,
    required String message,
    Duration messageDuration = const Duration(seconds: 2),
    VoidCallback? actionOnPress,
    Icon fabIcon = const Icon(Icons.add),
    bool isDraggable = true,
    Position? initialPosition,
    Offset? offsetPosition,
    Color? fabBgColor,
    List<ActionButton>? children,
    ChildrenStyle childrenStyle = ChildrenStyle.horizontal,
  }) {
    assert(message.isNotEmpty);

    return FloatingSnapButton(
      displayMessageOnStart: true,
      startMessage: message,
      messageDuration: messageDuration,
      actionOnPress: actionOnPress,
      isDraggable: isDraggable,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      childrenStyle: childrenStyle,
      children: children,
    );
  }

  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;
  final VoidCallback? actionOnPress;
  final bool isDismissible = false;
  final bool isDraggable;
  final Position? initialPosition;
  final Offset? offsetPosition;
  final Icon fabIcon;
  final Color? fabBgColor;
  final List<ActionButton>? children;
  final ChildrenStyle childrenStyle;

  @override
  Widget build(BuildContext context) {
    return FloatingSnapButtonView(
      actionOnPress: actionOnPress,
      displayMessageOnStart: displayMessageOnStart,
      isDismissible: isDismissible,
      messageDuration: messageDuration,
      startMessage: startMessage,
      isDraggable: isDraggable,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      childrenStyle: childrenStyle,
      children: children,
    );
  }
}

/// The FloatingSnapButton widget.
class FloatingSnapButtonView extends StatelessWidget {
  const FloatingSnapButtonView({
    super.key,
    required this.displayMessageOnStart,
    required this.messageDuration,
    required this.isDismissible,
    required this.isDraggable,
    required this.fabIcon,
    required this.childrenStyle,
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.children,
    this.actionOnPress,
    this.startMessage,
  });

  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;
  final VoidCallback? actionOnPress;
  final bool isDismissible;
  final bool isDraggable;
  final Position? initialPosition;
  final Offset? offsetPosition;
  final Icon fabIcon;
  final ChildrenStyle childrenStyle;
  final Color? fabBgColor;
  final List<ActionButton>? children;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final controller = FloatingSnapButtonController(
        isDraggable: isDraggable,
        isDismissible: isDismissible,
        initialPosition: initialPosition,
        offsetPosition: offsetPosition,
        screenHeight: screenHeight,
        screenWidth: screenWidth,
        fabIcon: fabIcon,
        fabBgColor: fabBgColor,
        children: children,
        childrenStyle: childrenStyle);
    return _FloatingSnapButtonExtraBody(
      actionOnPress: actionOnPress,
      displayMessageOnStart: displayMessageOnStart,
      startMessage: startMessage,
      messageDuration: messageDuration,
      controller: controller,
    );
  }
}

class _FloatingSnapButtonExtraBody extends StatelessWidget {
  const _FloatingSnapButtonExtraBody({
    super.key,
    this.actionOnPress,
    required this.displayMessageOnStart,
    required this.startMessage,
    required this.messageDuration,
    required this.controller,
  });

  final VoidCallback? actionOnPress;
  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;
  final FloatingSnapButtonController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: controller.onButtonCollapsed(),
      builder: (context, snapshot) {
        final isButtonCollapsed = snapshot.data;

        if (isButtonCollapsed == null) {
          return const SizedBox();
        }

        return FabButtonAnimation(
          displayMessageOnStart: displayMessageOnStart,
          startMessage: startMessage,
          messageDuration: messageDuration,
          controller: controller,
          actionOnPress: actionOnPress,
        );
      },
    );
  }
}
