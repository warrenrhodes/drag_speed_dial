import 'dart:async';

import 'package:flutter/material.dart';

import 'drag_speed_dial.dart';
import 'drag_speed_dial_controller.dart';

class DragSpeedDialButtonAnimation extends StatelessWidget {
  const DragSpeedDialButtonAnimation({
    super.key,
    this.tooltipMessage,
    required this.controller,
    this.actionOnPress,
  });

  final String? tooltipMessage;
  final DragSpeedDialController controller;
  final VoidCallback? actionOnPress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dragSpeedDialChildren =
        controller.dragSpeedDialChildren?.asMap().entries.map((e) {
      return _FabItem(
          controller: controller, tooltipMessage: tooltipMessage, child: e);
    });

    return ListenableBuilder(
        listenable: controller,
        builder: (context, snapshot) {
          final isDragging = controller.isDragging;
          final fabPosition = controller.fabPosition;
          Future.microtask(() {
            if (!controller.isDragging) {
              controller.onPanEnd(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
              );
            }
          });
          return AnimatedPositioned(
            duration: Duration(
              milliseconds: isDragging ? 10 : 700,
            ),
            curve: Curves.bounceOut,
            top: fabPosition.dy,
            left: fabPosition.dx,
            child: GestureDetector(
                onPanUpdate: (details) =>
                    controller.onPanUpdate(details: details),
                onPanEnd: (details) {
                  controller.onPanEnd(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  );
                },
                child: dragSpeedDialChildren == null
                    ? Material(
                        clipBehavior: Clip.antiAlias,
                        shape: const CircleBorder(),
                        child: FloatingActionButton(
                          backgroundColor: controller.fabBgColor,
                          heroTag: null,
                          onPressed: actionOnPress,
                          child: controller.fabIcon,
                        ),
                      )
                    : CompositedTransformTarget(
                        link: controller.buttonLayerLink,
                        child: _MainFirstButton(
                          controller: controller,
                          actionOnPress: actionOnPress,
                          rotateTheIcon: true,
                          onPressed: () {
                            if (controller.overlayEntry != null) {
                              controller.removeLayer();
                            } else {
                              controller.showOverlay(
                                  context, dragSpeedDialChildren.toList());
                            }
                          },
                        ))),
          );
        });
  }
}

class _FabItem extends StatelessWidget {
  const _FabItem({
    required this.controller,
    this.tooltipMessage,
    required this.child,
  });

  final DragSpeedDialController controller;
  final String? tooltipMessage;
  final MapEntry<int, DragSpeedDialChild> child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return CompositedTransformFollower(
      offset: controller.getPosition(screenHeight, screenWidth) ?? Offset.zero,
      link: controller.buttonLayerLink,
      showWhenUnlinked: true,
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: FractionalTranslation(
          translation: Offset.zero,
          child: ScaleTransition(
            scale: controller.menuAnimation(child.key),
            child: Tooltip(
              child: FloatingActionButton(
                backgroundColor: child.value.bgColor,
                mini: true,
                heroTag: null,
                onPressed: () {
                  if (controller.overlayEntry != null) {
                    controller.removeLayer();
                  }
                  child.value.onPressed?.call();
                },
                child: child.value.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainFirstButton extends StatelessWidget {
  const _MainFirstButton({
    required this.controller,
    required this.actionOnPress,
    required this.rotateTheIcon,
    this.onPressed,
  });

  final DragSpeedDialController controller;
  final VoidCallback? actionOnPress;
  final bool rotateTheIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: FloatingActionButton(
        backgroundColor: Color.lerp(Colors.black, controller.fabBgColor,
            controller.fabButtonAnimation().value),
        onPressed: onPressed ?? actionOnPress ?? () {},
        child: !rotateTheIcon
            ? controller.fabIcon
            : RotationTransition(
                turns: controller.fabButtonAnimation(),
                child: Stack(
                  children: [
                    AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: controller.fabButtonAnimation().value,
                        child: controller.fabIcon),
                    AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: controller
                            .fabButtonAnimation(isCloseIcon: true)
                            .value,
                        child: const Icon(Icons.close, color: Colors.white)),
                  ],
                )),
      ),
    );
  }
}
