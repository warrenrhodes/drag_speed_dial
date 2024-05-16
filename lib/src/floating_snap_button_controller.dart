import 'dart:async';
import 'dart:math';

import 'package:floating_snap_button/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../floating_snap_button.dart';

/// The [FloatingSnapButtonController].
class FloatingSnapButtonController {
  final bool isDismissible;
  final bool isDraggable;
  final Position? initialPosition;
  final Offset? offsetPosition;
  final Icon fabIcon;
  final Color? fabBgColor;
  final List<ActionButton>? children;
  final ChildrenStyle childrenStyle;

  // Create a static instance variable to hold the singleton instance
  static FloatingSnapButtonController? _instance;

  /// The top position.
  ValueNotifier<double> top = ValueNotifier(-1);

  /// The left position.
  ValueNotifier<double> left = ValueNotifier(-1);

  /// Is in dragging state.
  ValueNotifier<bool> isDragging = ValueNotifier(false);

  /// The floating widget width.
  final double floatingWidgetWidth = 60;

  /// The floating widget height.
  final double floatingWidgetHeight = 60;

  /// The tooltip controller.
  final tooltipController = JustTheController();

  /// the last position.
  ValueNotifier<Offset> lastPanPosition = ValueNotifier(Offset.zero);

  /// The animation controller.
  static final AnimationController menuAnimationController =
      AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: const _MyTickerProvider(),
  );

  /// The animation.
  final Animation<double> menuAnimation =
      Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
    parent: menuAnimationController,
    curve: const Interval(0, 0.5, curve: Curves.easeInOut),
  ));

  /// Private constructor.
  FloatingSnapButtonController._({
    required this.isDraggable,
    required this.isDismissible,
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.children,
    required double screenWidth,
    required double screenHeight,
    required this.fabIcon,
    required this.childrenStyle,
  }) {
    _setInitialPosition(
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      screenHeight: screenHeight,
      screenWidth: screenWidth,
    );
  }

  factory FloatingSnapButtonController({
    required bool isDraggable,
    required bool isDismissible,
    Position? initialPosition,
    Offset? offsetPosition,
    required Icon fabIcon,
    Color? fabBgColor,
    List<ActionButton>? children,
    required ChildrenStyle childrenStyle,
    required double screenWidth,
    required double screenHeight,
  }) {
    _instance ??= FloatingSnapButtonController._(
      isDraggable: isDraggable,
      isDismissible: isDismissible,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      children: children,
      childrenStyle: childrenStyle,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );

    return _instance!;
  }

  void _setInitialPosition({
    Position? initialPosition,
    Offset? offsetPosition,
    required double screenHeight,
    required double screenWidth,
  }) {
    if (offsetPosition != null) {
      top.value = offsetPosition.dy;
      left.value = offsetPosition.dx;
      return;
    }

    Position currentInitPosition = initialPosition ?? Position.bottomRight;

    switch (currentInitPosition) {
      case Position.topLeft:
        top.value = 5;
        left.value = 5;
        break;
      case Position.topRight:
        top.value = 5;
        left.value = screenWidth - floatingWidgetWidth - 5;
        break;
      case Position.bottomLeft:
        top.value = screenHeight - floatingWidgetWidth - 80;
        left.value = 5;
        break;
      case Position.bottomRight:
        top.value = screenHeight - floatingWidgetWidth - 80;
        left.value = screenWidth - floatingWidgetWidth - 5;
        break;
      case Position.topCenter:
        top.value = 5;
        left.value = (screenHeight - floatingWidgetWidth) / 2;
        break;
      case Position.bottomCenter:
        top.value = screenHeight - floatingWidgetWidth - 80;
        left.value = (screenWidth - floatingWidgetWidth) / 2;
        break;
    }
  }

  /// The on button collapsed.
  Future<bool> onButtonCollapsed() async {
    final pref = await SharedPreferences.getInstance();

    return pref.getBool(
          PreferencesKeys.isButtonCollapsed,
        ) ??
        false;
  }

  bool hasCollision(
    GlobalKey<State<StatefulWidget>> key1,
    GlobalKey<State<StatefulWidget>> key2,
  ) {
    final RenderBox? box1 =
        key1.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? box2 =
        key2.currentContext?.findRenderObject() as RenderBox?;
    if (box1 == null || box2 == null) {
      return false;
    }
    final pos1 = box1.localToGlobal(Offset.zero);
    final pos2 = box2.localToGlobal(Offset.zero);

    final size1 = box1.size;
    final size2 = box2.size;

    final left = pos1.dx < pos2.dx + size2.width;
    final right = pos1.dx + size1.width > pos2.dx;
    final top = pos1.dy < pos2.dy + size2.height;
    final bottom = pos1.dy + size1.height > pos2.dy;

    return left && right && top && bottom;
  }

  /// On draggable update.
  void onPanUpdate({
    required DragUpdateDetails details,
  }) {
    if (isDraggable == false) {
      return;
    }
    isDragging.value = true;
    top.value = max(0, top.value + details.delta.dy);
    left.value = max(0, left.value + details.delta.dx);
  }

  /// On draggable end.
  Future<void> onPanEnd({
    required DragEndDetails details,
    required BuildContext context,
    required GlobalKey floatingWidgetKey,
    required GlobalKey deleteWidgetKey,
  }) async {
    if (isDraggable == false) {
      return;
    }
    isDragging.value = false;

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    left.value = left.value >= width / 2 ? width - floatingWidgetWidth - 5 : 5;
    top.value = min(top.value, height - floatingWidgetHeight - 80);

    if (!isDismissible) {
      return;
    }
    final isColliding = hasCollision(deleteWidgetKey, floatingWidgetKey);
    if (isColliding) {
      await disableFloatingButton();
    }
  }

  void runAnimation(Offset velocity, Offset offset) {
    print("object");
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 1,
        damping: 1,
      ),
      offset.dy, // starting point
      0, // ending point
      velocity.dy, // velocity
    );

    menuAnimationController.animateWith(simulation);
  }

  Future<void> disableFloatingButton() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(
      PreferencesKeys.isButtonCollapsed,
      true,
    );
  }
}

class _MyTickerProvider extends TickerProvider {
  const _MyTickerProvider();

  @override
  Ticker createTicker(onTick) => Ticker(onTick);
}
