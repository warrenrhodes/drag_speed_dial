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
  final VoidCallback? onDragStart;
  final ValueChanged<Offset>? onDragUpdate;
  final ValueChanged<Offset>? onDragEnd;

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
    return Tween(begin: start, end: end).animate(
      CurvedAnimation(
        parent: menuAnimationController,
        curve: Curves.easeInOutCubicEmphasized,
        reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
      ),
    );
  }

  /// The menu animation.
  Animation<double> menuAnimation(int index) {
    const animationOverlap = 0.8;
    final animationLengthScale =
        1 +
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
      curve: Interval(start, end, curve: Curves.easeOutBack),
      reverseCurve: Interval(start, end, curve: Curves.easeOutBack),
    );
  }

  /// Constructor.
  DragSpeedDialController({
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
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  }) {
    _setInitialPosition(
      initialPosition: initialPosition,
      offsetPosition: offsetPosition,
      screenHeight: screenHeight,
      screenWidth: screenWidth,
    );
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
        fabPosition = Offset(
          (screenWidth - fabWidth) / 2,
          screenHeight - fabWidth - 80,
        );
        break;
    }
  }

  /// On draggable update.
  void onPanUpdate({required DragUpdateDetails details}) {
    if (isDraggable == false) {
      return;
    }
    overlayEntry?.remove();
    overlayEntry = null;

    if (!isDragging) {
      isDragging = true;
      onDragStart?.call();
    }

    fabPosition = Offset(
      fabPosition.dx + details.delta.dx,
      fabPosition.dy + details.delta.dy,
    );
    onDragUpdate?.call(fabPosition);
    notifyListeners();
  }

  /// On draggable end.
  Future<void> onPanEnd({
    required double screenWidth,
    required double screenHeight,
  }) async {
    isDragging = false;
    const double fabSize = 60;
    double leftX = fabPosition.dx;
    double leftY = fabPosition.dy;

    // Constrain to screen bounds
    leftX = leftX.clamp(0, screenWidth - fabSize);
    leftY = leftY.clamp(
      0,
      screenHeight - fabSize - 50,
    ); // 50px padding from bottom

    if (snagOnScreen) {
      // When snagOnScreen is enabled, keep the FAB where user dragged it
      // Just ensure it's within bounds (already done by clamp above)
      // Add minimum padding from edges
      if (leftX < 5) leftX = 5;
      if (leftY < 5) leftY = 5;
      if (leftX > screenWidth - fabSize - 5) {
        leftX = screenWidth - fabSize - 5;
      }
      if (leftY > screenHeight - fabSize - 80) {
        leftY = screenHeight - fabSize - 80;
      }
    } else {
      // When snagOnScreen is disabled, snap to nearest horizontal edge
      if (leftX > screenWidth / 2) {
        leftX = screenWidth - fabSize - 5;
      } else {
        leftX = 5;
      }

      // Keep Y position but ensure it's within bounds
      if (leftY > screenHeight - 140) {
        leftY = screenHeight - 110;
      }
      if (leftY < 5) {
        leftY = 5;
      }
    }

    if (fabPosition.dx == leftX && fabPosition.dy == leftY) {
      return;
    }

    fabPosition = Offset(leftX, leftY);
    onDragEnd?.call(fabPosition);
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
    BuildContext context,
    List<Widget> children,
  ) {
    return OverlayEntry(builder: (context) => Stack(children: children));
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
          // FAB on left side - show children to the right
          lastItemX = max(60, lastItemX + 50);
          itemPosition = Offset(lastItemX, 0);
          newItemPosition = Offset(lastItemX, 6);
          break;
        }
        // FAB on right side - show children to the left
        lastItemX = min(-50, lastItemX - 50);
        itemPosition = Offset(lastItemX, 0);
        newItemPosition = Offset(lastItemX, 6);
        break;
      case DragSpeedDialChildrenAlignment.vertical:
        if (position.dy < screenHeight / 2) {
          // FAB on top half - show children below
          lastItemY = max(60, lastItemY + 60);
          itemPosition = Offset(0, lastItemY);
          newItemPosition = Offset(6, lastItemY);
          break;
        }
        // FAB on bottom half - show children above
        lastItemY = min(-60, lastItemY - 60);
        itemPosition = Offset(0, lastItemY);
        newItemPosition = Offset(6, lastItemY);
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
