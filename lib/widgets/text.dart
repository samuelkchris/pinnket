import 'package:flutter/material.dart';

class NameText extends StatelessWidget {
  final ThemeData themeData;
  final String text;
  final TextStyle? style;

  const NameText({
    super.key,
    required this.themeData,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: style ??
          const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w200,
          ),
    );
  }
}
