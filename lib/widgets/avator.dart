import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String imagePath;
  final double height;
  final double width;

  const AvatarWidget({
    super.key,
    this.imagePath = 'assets/image/png/avator.png',
    this.height = 150,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      //outer gradiant border
      width: width,
      height: height,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            themeData.colorScheme.primary,
            themeData.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        //white container for padding
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: themeData.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Container(
          //inner gradiant border
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeData.colorScheme.primary,
                themeData.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Container(
            //white container for padding
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: themeData.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                imagePath,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
