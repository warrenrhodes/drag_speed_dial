import 'dart:async';

import 'drag_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'drag_speed_dial_controller.dart';

class DragSpeedDialButtonAnimation extends StatelessWidget {
  const DragSpeedDialButtonAnimation({
    super.key,
    required this.startMessage,
    required this.messageDuration,
    required this.controller,
    this.actionOnPress,
  });

  final String? startMessage;
  final Duration messageDuration;
  final DragSpeedDialController controller;
  final VoidCallback? actionOnPress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dragSpeedDialChildren = controller.dragSpeedDialChildren?.asMap().entries.map((e) {
      return _FabsItem(
          controller: controller,
          startMessage: startMessage,
          messageDuration: messageDuration,
          child: e);
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
                    ? Stack(
                        children: [
                          Positioned(
                              top: controller.fabPosition.dy,
                              left: controller.fabPosition.dx,
                              child: _MainFirstButton(
                                startMessage: startMessage,
                                messageDuration: messageDuration,
                                controller: controller,
                                actionOnPress: actionOnPress,
                                rotateTheIcon: false,
                              )),
                        ],
                      )
                    : CompositedTransformTarget(
                        link: controller.buttonLayerLink,
                        child: _MainFirstButton(
                          startMessage: startMessage,
                          messageDuration: messageDuration,
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

class _FabsItem extends StatelessWidget {
  const _FabsItem({
    super.key,
    required this.controller,
    required this.startMessage,
    required this.messageDuration,
    required this.child,
  });

  final DragSpeedDialController controller;
  final String? startMessage;
  final Duration messageDuration;
  final MapEntry<int, DrapSpeedDialChild> child;

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
            child: _FloatingButton(
              startMessage: null,
              messageDuration: messageDuration,
              controller: controller,
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
    super.key,
    required this.startMessage,
    required this.messageDuration,
    required this.controller,
    required this.actionOnPress,
    required this.rotateTheIcon,
    this.onPressed,
  });

  final String? startMessage;
  final Duration messageDuration;
  final DragSpeedDialController controller;
  final VoidCallback? actionOnPress;
  final bool rotateTheIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _FloatingButton(
      startMessage: startMessage,
      messageDuration: messageDuration,
      controller: controller,
      child: Material(
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
      ),
    );
  }
}

class _FloatingButton extends StatelessWidget {
  const _FloatingButton({
    this.startMessage,
    required this.messageDuration,
    required this.controller,
    required this.child,
  }) : super();

  final String? startMessage;
  final Duration messageDuration;
  final DragSpeedDialController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (startMessage == null) {
      return child;
    }
    return LayoutBuilder(builder: (context, constraints) {
      if (!controller.isTooltipMessageDisplayed) {
        Future.microtask(() => Future.delayed(
            messageDuration, controller.tooltipController.showTooltip));
        Future.microtask(() => Future.delayed(const Duration(seconds: 2),
            controller.disableTooltipMessageDisplay));
      }

      return SizedBox(
        child: JustTheTooltip(
          controller: controller.tooltipController,
          preferredDirection: AxisDirection.up,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              startMessage ?? '',
            ),
          ),
          child: child,
        ),
      );
    });
  }
}
