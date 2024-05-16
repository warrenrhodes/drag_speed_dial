import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../floating_snap_button.dart';
import 'floating_snap_button_controller.dart';
import 'utils.dart';

final hideFabKey = GlobalKey<State>();
final fabGlobalKey = GlobalKey<State>();

class ActionButton {
  const ActionButton({
    this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;
}

class FabButtonAnimation extends StatelessWidget {
  const FabButtonAnimation({
    super.key,
    required this.displayMessageOnStart,
    required this.startMessage,
    required this.messageDuration,
    required this.controller,
    this.actionOnPress,
  });

  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;
  final FloatingSnapButtonController controller;
  final VoidCallback? actionOnPress;

  @override
  Widget build(BuildContext context) {
    final List<Widget> defaultMenuItems = [
      _FloatingButton(
        displayMessageOnStart: displayMessageOnStart,
        startMessage: startMessage,
        messageDuration: messageDuration,
        controller: controller,
        onPressed: actionOnPress ?? () {},
        child: FloatingActionButton(
          backgroundColor: controller.fabBgColor,
          onPressed: null,
          child: controller.fabIcon,
        ),
      ),
    ];
    final children = controller.children?.asMap().entries.map((e) {
      return _FloatingButton(
        displayMessageOnStart: displayMessageOnStart &&
                e.key == (controller.children?.length ?? 1) - 1
            ? displayMessageOnStart
            : false,
        startMessage: startMessage,
        messageDuration: messageDuration,
        controller: controller,
        child: e.value.child,
        onPressed: () {
          FloatingSnapButtonController.menuAnimationController.status ==
                  AnimationStatus.completed
              ? FloatingSnapButtonController.menuAnimationController.reverse()
              : FloatingSnapButtonController.menuAnimationController.forward();
          e.value.onPressed?.call();
        },
      );
    });

    return ValueListenableBuilder<bool>(
        valueListenable: controller.isDragging,
        builder: (context, isDragging, child) {
          return ValueListenableBuilder<double>(
              valueListenable: controller.top,
              builder: (context, valueTop, child) {
                return ValueListenableBuilder<double>(
                    valueListenable: controller.left,
                    builder: (context, valueLeft, child) {
                      // Future.microtask(() {
                      //   if (!isDragging) {
                      //     controller.onPanEnd(
                      //         details: DragEndDetails(),
                      //         context: context,
                      //         floatingWidgetKey: fabGlobalKey,
                      //         deleteWidgetKey: hideFabKey);
                      //   }
                      // });
                      return GestureDetector(
                        onPanUpdate: (details) =>
                            controller.onPanUpdate(details: details),
                        onPanEnd: (details) {
                          controller.onPanEnd(
                            details: details,
                            context: context,
                            floatingWidgetKey: fabGlobalKey,
                            deleteWidgetKey: hideFabKey,
                          );
                          // controller.runAnimation(
                          //     details.velocity.pixelsPerSecond,
                          //     Offset(valueLeft, valueTop));
                        },
                        child: Flow(
                          clipBehavior: Clip.none,
                          key: fabGlobalKey,
                          delegate: _FlowMenuDelegate(
                            menuAnimation: controller.menuAnimation,
                            dx: valueLeft,
                            dy: valueTop,
                            controller: controller,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                          children: children == null
                              ? defaultMenuItems
                              : children.map<Widget>((data) => data).toList(),
                        ),
                      );
                    });
              });
        });
  }
}

class _FloatingButton extends StatelessWidget {
  const _FloatingButton({
    required this.displayMessageOnStart,
    this.startMessage,
    required this.messageDuration,
    required this.controller,
    required this.child,
    required this.onPressed,
  }) : super();

  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;
  final FloatingSnapButtonController controller;
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!displayMessageOnStart) {
      return InkWell(onTap: onPressed, child: child);
    }
    return LayoutBuilder(builder: (context, constraints) {
      Future.microtask(() => Future.delayed(
          messageDuration, controller.tooltipController.showTooltip));

      Future.microtask(() => Future.delayed(const Duration(seconds: 2),
          controller.tooltipController.hideTooltip));

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
          child: InkWell(onTap: onPressed, child: child),
        ),
      );
    });
  }
}

class BuilderOnHideFAB extends StatelessWidget {
  const BuilderOnHideFAB({
    super.key,
    required this.isButtonCollapsed,
    required this.controller,
  });

  final bool isButtonCollapsed;
  final FloatingSnapButtonController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!controller.isDismissible) {
      return const SizedBox();
    }

    return AnimatedPositioned(
      duration: const Duration(seconds: 1),
      top: MediaQuery.of(context).size.height / 4,
      left: isButtonCollapsed
          ? MediaQuery.of(context).size.width - 25
          : MediaQuery.of(context).size.width,
      child: Material(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 5,
          ),
          width: 30,
          decoration: BoxDecoration(
            gradient: theme.brightness == Brightness.dark
                ? lightLinearGradient
                : darkLinearGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: GestureDetector(
            child: Transform.rotate(
              angle: 3.14,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  "localization.chatHelperMessage",
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowMenuDelegate extends FlowDelegate {
  _FlowMenuDelegate(
      {required this.menuAnimation,
      required this.dx,
      required this.dy,
      required this.controller,
      required this.width,
      required this.height})
      : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;
  final double dx;
  final double dy;
  final double width;
  final double height;
  final FloatingSnapButtonController controller;

  @override
  bool shouldRepaint(_FlowMenuDelegate oldDelegate) {
    return Offset(dx, dy) != Offset(oldDelegate.dx, oldDelegate.dy) ||
        menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double scale = menuAnimation.value;
    double currentDx = dx;
    double currentDy = dy;
    for (int i = 0; i < context.childCount; ++i) {
      double bounceFactor = 0.5;
      double bounceAmount = sin(menuAnimation.value * pi) * bounceFactor;
      if (controller.childrenStyle == ChildrenStyle.horizontal) {
        if (dx < width / 2) {
          currentDx = dx + (i * 70) * scale;
        } else {
          currentDx = dx + (i * -70) * scale;
        }
      } else {
        if (dy < height / 2) {
          currentDy = dy + (i * 70) * scale;
        } else {
          currentDy = dy + (i * -70) * scale;
        }
      }
      context.paintChild(i,
          transform: Matrix4.identity()
            ..setTranslationRaw(currentDx, currentDy, 0.0));
      // context.paintChild(i,
      //     transform: Matrix4.translationValues(currentDx, currentDy, 0.0));
    }
  }
}

class CloseWidget extends StatelessWidget {
  const CloseWidget({super.key, required this.controller});
  final FloatingSnapButtonController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!controller.isDismissible) {
      return const SizedBox();
    }

    return ValueListenableBuilder<bool>(
        valueListenable: controller.isDragging,
        builder: (context, value, child) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: value
                ? MediaQuery.of(context).size.height - 180
                : MediaQuery.of(context).size.height +
                    controller.floatingWidgetHeight,
            left: MediaQuery.of(context).size.width / 2 -
                controller.floatingWidgetWidth,
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                key: hideFabKey,
                height: 60,
                width: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: theme.brightness == Brightness.dark
                        ? lightLinearGradient
                        : darkLinearGradient,
                    shape: BoxShape.circle,
                    border: const Border.fromBorderSide(
                      BorderSide(width: 4, color: Colors.white),
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
