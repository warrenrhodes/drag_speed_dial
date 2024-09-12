import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'drag_speed_dial.dart';

/// The [DragSpeedDialController].
class DragSpeedDialController extends ChangeNotifier {
  final bool isDraggable;
  final DragSpeedDialPosition? initialPosition;
  final Offset? offsetPosition;
  final Icon fabIcon;
  final Color? fabBgColor;
  final List<DragSpeedDialChild>? dragSpeedDialChildren;
  final DragSpeedDialChildrenAlignment childrenStyle;
  final bool snagOnScreen;

  // Create a static instance variable to hold the singleton instance
  static DragSpeedDialController? _instance;

  /// Whether the tooltip has been shown.
  bool isTooltipMessageDisplayed = false;

  /// Whether the overlay is visible.
  bool isOverlayVisible = false;

  /// The fab position.
  Offset fabPosition = Offset.zero;

  /// The item position.
  Offset itemPosition = Offset.zero;

  /// Is in dragging state.
  bool isDragging = false;

  /// The button layer link.
  final buttonLayerLink = LayerLink();

  OverlayEntry? overlayEntry;

  /// The menu animation controller.
  static final AnimationController menuAnimationController =
      AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: const _MyTickerProvider(),
  );

  Animation<double> fabButtonAnimation({bool isCloseIcon = false}) {
    final start = isCloseIcon ? 0.0 : 1.0;
    final end = isCloseIcon ? 1.0 : 0.0;
    return Tween(begin: start, end: end).animate(CurvedAnimation(
      parent: menuAnimationController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
    ));
  }

  /// The menu animation.
  Animation<double> menuAnimation(int index) {
    const animationOverlap = 0.8;
    final animationLengthScale = 1 +
        ((1 - animationOverlap) * ((dragSpeedDialChildren?.length ?? 0) - 1));
    menuAnimationController.duration =
        const Duration(milliseconds: 500) * animationLengthScale;
    menuAnimationController.reverseDuration =
        const Duration(milliseconds: 200) * animationLengthScale;

    final intervalLength = 1 / animationLengthScale;

    final overlapLength = intervalLength * animationOverlap;

    final intervalOffset = intervalLength - overlapLength;

    final start = index * intervalOffset;
    final end = start + intervalLength;

    return CurvedAnimation(
      parent: menuAnimationController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutBack,
      ),
      reverseCurve: Interval(
        start,
        end,
        curve: Curves.easeOutBack,
      ),
    );
  }

  /// Private constructor.
  DragSpeedDialController._({
    required this.isDraggable,
    this.initialPosition,
    this.offsetPosition,
    this.fabBgColor,
    this.dragSpeedDialChildren,
    required double screenWidth,
    required double screenHeight,
    required this.fabIcon,
    required this.childrenStyle,
    required this.snagOnScreen,
  }) {
    _setInitialPosition(
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      screenHeight: screenHeight,
      screenWidth: screenWidth,
    );
  }

  factory DragSpeedDialController({
    required bool isDraggable,
    DragSpeedDialPosition? initialPosition,
    Offset? offsetPosition,
    required Icon fabIcon,
    Color? fabBgColor,
    List<DragSpeedDialChild>? dragSpeedDialChildren,
    required DragSpeedDialChildrenAlignment childrenStyle,
    required double screenWidth,
    required double screenHeight,
    required bool snagOnScreen,
  }) {
    _instance ??= DragSpeedDialController._(
      isDraggable: isDraggable,
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      fabIcon: fabIcon,
      fabBgColor: fabBgColor,
      dragSpeedDialChildren: dragSpeedDialChildren,
      childrenStyle: childrenStyle,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      snagOnScreen: snagOnScreen,
    );

    return _instance!;
  }

  void _setInitialPosition({
    DragSpeedDialPosition? initialPosition,
    Offset? offsetPosition,
    required double screenHeight,
    required double screenWidth,
  }) {
    if (offsetPosition != null) {
      fabPosition = offsetPosition;
      return;
    }

    DragSpeedDialPosition currentInitPosition =
        initialPosition ?? DragSpeedDialPosition.bottomRight;
    const int fabWidth = 60;

    switch (currentInitPosition) {
      case DragSpeedDialPosition.topLeft:
        fabPosition = const Offset(5, 5);
        break;
      case DragSpeedDialPosition.topRight:
        fabPosition = Offset(screenWidth - fabWidth - 5, 5);
        break;
      case DragSpeedDialPosition.bottomLeft:
        fabPosition = Offset(5, screenHeight - 140);
        break;
      case DragSpeedDialPosition.bottomRight:
        fabPosition = Offset(screenWidth - fabWidth - 5, screenHeight - 140);

        break;
      case DragSpeedDialPosition.topCenter:
        fabPosition = Offset((screenWidth - fabWidth) / 2, 5);

        break;
      case DragSpeedDialPosition.bottomCenter:
        fabPosition =
            Offset((screenWidth - fabWidth) / 2, screenHeight - fabWidth - 80);
        break;
    }
  }

  /// On draggable update.
  void onPanUpdate({
    required DragUpdateDetails details,
  }) {
    if (isDraggable == false) {
      return;
    }
    overlayEntry?.remove();
    overlayEntry = null;
    isDragging = true;
    fabPosition = Offset(
        fabPosition.dx + details.delta.dx, fabPosition.dy + details.delta.dy);
    notifyListeners();
  }

  /// On draggable end.
  Future<void> onPanEnd({
    required double screenWidth,
    required double screenHeight,
  }) async {
    isDragging = false;
    //removeLayer();
    double leftX = fabPosition.dx;
    double leftY = fabPosition.dy;

    if (snagOnScreen) {
      if (leftY > screenHeight - 60) {
        leftY = screenHeight - 110;
      }
      if (leftX > screenWidth - 60) {
        leftX = screenWidth - 65;
      }

      if (fabPosition.dx == leftX && fabPosition.dy == leftY) {
        return;
      }

      fabPosition = Offset(leftX, leftY);
      notifyListeners();
      return;
    }

    if (leftX > screenWidth / 2) {
      leftX = screenWidth - 65;
    } else {
      leftX = 5;
    }
    if (leftY > screenHeight - 140) {
      leftY = screenHeight - 110;
    } else {
      leftY = leftY;
    }

    if (fabPosition.dx == leftX && fabPosition.dy == leftY) {
      return;
    }

    fabPosition = Offset(leftX, leftY);

    notifyListeners();
  }

  void showOverlay(BuildContext context, List<Widget> children) {
    overlayEntry = _createOverlayEntry(context, children);
    final newOverlay = overlayEntry;
    if (newOverlay == null) return;
    Overlay.of(context).insert(newOverlay);
    menuAnimationController.forward();
    isOverlayVisible = true;
    notifyListeners();
  }

  OverlayEntry _createOverlayEntry(
      BuildContext context, List<Widget> children) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: children,
      ),
    );
  }

  Future<void> removeLayer() async {
    await menuAnimationController.reverse();
    overlayEntry?.remove();
    overlayEntry = null;
    itemPosition = Offset.zero;
    isOverlayVisible = false;
    notifyListeners();
  }

  Offset? getPosition(double screenHeight, double screenWidth) {
    Offset? position = buttonLayerLink.leader?.offset;
    if (position == null) {
      return null;
    }

    double lastItemX = itemPosition.dx;
    double lastItemY = itemPosition.dy;
    Offset? newItemPosition;

    switch (childrenStyle) {
      case DragSpeedDialChildrenAlignment.horizontal:
        if (position.dx < screenWidth / 2) {
          lastItemX = max(60, lastItemX + 50);
          itemPosition = Offset(lastItemX, 0);
          newItemPosition = Offset(lastItemX, 6);
          break;
        }
        lastItemX = min(-50, lastItemX - 50);
        itemPosition = Offset(lastItemX, 0);
        newItemPosition = Offset(lastItemX, 6);
        break;
      case DragSpeedDialChildrenAlignment.vertical:
        if (position.dy < screenHeight / 2) {
          lastItemY = max(60, lastItemY + 50);
          itemPosition = Offset(0, lastItemY);
          newItemPosition = Offset(8, lastItemY);
          break;
        }
        lastItemY = min(0, lastItemY - 50);
        itemPosition = Offset(0, lastItemY);
        newItemPosition = Offset(6, lastItemY);
        break;
      default:
        newItemPosition = null;
        break;
    }
    return newItemPosition;
  }

  void disableTooltipMessageDisplay() {
    isTooltipMessageDisplayed = true;

    notifyListeners();
  }
}

class _MyTickerProvider extends TickerProvider {
  const _MyTickerProvider();

  @override
  Ticker createTicker(onTick) => Ticker(onTick);
}
