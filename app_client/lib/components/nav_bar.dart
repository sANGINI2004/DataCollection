import 'package:flutter/material.dart';
import 'package:wear_os/components/nav_button.dart';

class NavBar extends AppBar {
  NavBar({
    Key? key,
    required String title,
    required NavButton leftButton,
    required NavButton rightButton,
  }) : super(
            key: key,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [leftButton, Text(title), rightButton],
            ));
}
