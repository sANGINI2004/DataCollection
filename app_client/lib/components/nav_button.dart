import 'package:flutter/material.dart';

class NavButton extends ElevatedButton {
  NavButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    bool autofocus = false,
    required Widget child,
  }) : super(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
            ),
            key: key,
            onPressed: onPressed,
            onLongPress: onLongPress,
            autofocus: autofocus,
            child: child);
}
