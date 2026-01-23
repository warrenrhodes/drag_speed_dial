import 'package:flutter/material.dart';

import 'drag_speed_dial.dart';
import 'drag_speed_dial_controller.dart';

class DragSpeedDialButtonAnimation extends StatelessWidget {
  const DragSpeedDialButtonAnimation({
    super.key,
    required this.controller,
    this.actionOnPress,
    this.overlayBuilder,
  });
  final DragSpeedDialController controller;
  final VoidCallback? actionOnPress;
  final Widget Function(BuildContext, bool)? overlayBuilder;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dragSpeedDialChildren = controller.dragSpeedDialChildren
        ?.asMap()
        .entries
        .map((e) {
          return _FabItem(controller: controller, child: e);
        });

    return ListenableBuilder(
      listenable: controller,
      builder: (context, snapshot) {
        final isDragging = controller.isDragging;
        final fabPosition = controller.fabPosition;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!controller.isDragging) {
            controller.onPanEnd(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            );
          }
        });

        Widget fabWidget = GestureDetector(
          onPanUpdate: (details) => controller.onPanUpdate(details: details),
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
                  child: AnimatedFABButton(
                    controller: controller,
                    actionOnPress: actionOnPress,
                    onPressed: () {
                      if (controller.overlayEntry != null) {
                        controller.removeLayer();
                      } else {
                        controller.showOverlay(
                          context,
                          dragSpeedDialChildren.toList(),
                        );
                      }
                    },
                  ),
                ),
        );

        return Stack(
          children: [
            // Custom overlay (e.g., close button)
            if (overlayBuilder != null) overlayBuilder!(context, isDragging),
            AnimatedPositioned(
              duration: Duration(milliseconds: isDragging ? 10 : 700),
              curve: Curves.bounceOut,
              top: fabPosition.dy,
              left: fabPosition.dx,
              child: fabWidget,
            ),
          ],
        );
      },
    );
  }
}

class _FabItem extends StatelessWidget {
  const _FabItem({required this.controller, required this.child});

  final DragSpeedDialController controller;
  final MapEntry<int, DragSpeedDialChild> child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

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
            child: FloatingActionButton(
              backgroundColor: child.value.bgColor,
              mini: true,
              shape: const CircleBorder(),
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
    );
  }
}

class AnimatedFABButton extends StatelessWidget {
  const AnimatedFABButton({
    super.key,
    required this.controller,
    required this.actionOnPress,
    this.onPressed,
  });

  final DragSpeedDialController controller;
  final VoidCallback? actionOnPress;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: FloatingActionButton(
        backgroundColor: controller.isOverlayVisible
            ? Colors.black
            : controller.fabBgColor,
        onPressed: onPressed ?? actionOnPress ?? () {},
        child: RotationTransition(
          turns: controller.fabButtonAnimation(),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: controller.isOverlayVisible ? 0 : 1,
                child: controller.fabIcon,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: controller.isOverlayVisible ? 1 : 0,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
