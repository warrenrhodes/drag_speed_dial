import 'dart:async';
import 'dart:math';

import 'package:floating_snap_button/floating_snap_button.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'floating_snap_button_controller.dart';
import 'utils.dart';

final hideFabKey = GlobalKey<State>();
final fabGlobalKey = GlobalKey<State>();
bool typeForFirstTime = false;

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
    ValueNotifier<bool> open = ValueNotifier(false);

    return ValueListenableBuilder<bool>(
        valueListenable: controller.isDragging,
        builder: (context, isDragging, child) {
          return ValueListenableBuilder<double>(
              valueListenable: controller.top,
              builder: (context, valueTop, child) {
                return ValueListenableBuilder<double>(
                    valueListenable: controller.left,
                    builder: (context, valueLeft, child) {
                      Future.microtask(() {
                        if (!isDragging) {
                          controller.onPanEnd(
                              details: DragEndDetails(),
                              context: context,
                              floatingWidgetKey: fabGlobalKey,
                              deleteWidgetKey: hideFabKey);
                        }
                      });

                      return AnimatedPositioned(
                        duration: Duration(
                          milliseconds: isDragging ? 100 : 700,
                        ),
                        curve: Curves.bounceOut,
                        top: valueTop,
                        left: valueLeft,
                        child: GestureDetector(
                          onTap: () {
                            if (actionOnPress == null) {
                              open.value =
                                  controller.children?.isNotEmpty != null &&
                                          controller.children!.isNotEmpty
                                      ? !open.value
                                      : true;
                              typeForFirstTime = true;
                              return;
                            }
                            actionOnPress?.call();
                          },
                          onPanUpdate: (details) =>
                              controller.onPanUpdate(details: details),
                          onPanEnd: (details) => controller.onPanEnd(
                            details: details,
                            context: context,
                            floatingWidgetKey: fabGlobalKey,
                            deleteWidgetKey: hideFabKey,
                          ),
                          child: SizedBox(
                            key: fabGlobalKey,
                            child: ValueListenableBuilder<bool>(
                                valueListenable: open,
                                builder: (context, value, child) {
                                  return _BuildTapToCloseFab(
                                      controller: controller,
                                      displayMessageOnStart:
                                          displayMessageOnStart,
                                      startMessage: startMessage,
                                      messageDuration: messageDuration,
                                      value: value);
                                }),
                          ),
                        ),
                      );
                    });
              });
        });
  }
}

class _BuildTapToCloseFab extends StatelessWidget {
  final FloatingSnapButtonController controller;
  final bool value;
  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;

  const _BuildTapToCloseFab(
      {super.key,
      required this.controller,
      required this.value,
      required this.displayMessageOnStart,
      required this.startMessage,
      required this.messageDuration});

  @override
  Widget build(BuildContext context) {
    final children = controller.children;

    if (children == null) {
      return const SizedBox();
    }

    double lastItemX = 0;
    double lastItemY = 0;

    Offset? getPosition() {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;
      RenderBox? box2 =
          fabGlobalKey.currentContext?.findRenderObject() as RenderBox?;
      if (box2 == null) {
        return null;
      }
      final pos1 = box2.localToGlobal(Offset.zero);

      switch (controller.childrenStyle) {
        case ChildrenStyle.horizontal:
          if (pos1.dx < width / 2) {
            lastItemX = max(50, lastItemX + 30);
            return Offset(lastItemX, 10);
          }
          lastItemX = min(-30, lastItemX - 30);
          return Offset(lastItemX, 10);
        case ChildrenStyle.vertical:
          if (pos1.dy < height / 2) {
            lastItemY = max(80, lastItemY + 30);
            return Offset(10, lastItemY);
          }
          lastItemY = min(-50, lastItemY - 30);
          return Offset(10, lastItemY);
        default:
          return null;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...children.asMap().entries.map((entry) {
          final child = entry.value;
          return Positioned(
            top: typeForFirstTime ? getPosition()?.dy : null,
            left: typeForFirstTime ? getPosition()?.dx : null,
            child: AnimatedOpacity(
              opacity: value ? 1 : 0.0,
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              child: child,
            ),
          );
        }),
        
        if (!value)
          _FloatingButton(
            displayMessageOnStart: displayMessageOnStart,
            startMessage: startMessage,
            messageDuration: messageDuration,
            controller: controller,
          ),
          Positioned(
          top: 90,
          left: 20,
          child: GestureDetector(
            onTap: () {
              print("salutoooo");
            },
            child: Container(
              width: 50,
              height: 50,
              color: Colors.red,
            ),
          ),
        ),
        if (value)
          SizedBox(
            child: Center(
              child: Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        
      ],
    );
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

class _FloatingButton extends StatelessWidget {
  const _FloatingButton({
    required this.displayMessageOnStart,
    this.startMessage,
    required this.messageDuration,
    required this.controller,
  }) : super();

  final bool displayMessageOnStart;
  final String? startMessage;
  final Duration messageDuration;
  final FloatingSnapButtonController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: controller.displayTooltip,
        builder: (context, displayTooltip, child) {
          if (displayTooltip && displayMessageOnStart) {
            Future.microtask(() => Future.delayed(
                messageDuration, controller.tooltipController.showTooltip));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (displayMessageOnStart) {
                return SizedBox(
                  child: JustTheTooltip(
                    onDismiss: () => controller.displayTooltip.value = false,
                    controller: controller.tooltipController,
                    preferredDirection: AxisDirection.up,
                    content: !displayTooltip
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              startMessage ?? '',
                            ),
                          ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          backgroundColor: controller.fabBgColor,
                          onPressed: null,
                          child: controller.fabIcon,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return FloatingActionButton(
                backgroundColor: controller.fabBgColor,
                onPressed: null,
                child: controller.fabIcon,
              );
            },
          );
        });
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.color,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: () {
          onPressed?.call();
          print("object pressed");
        },
        icon: icon,
        color: color,
      ),
    );
  }
}
