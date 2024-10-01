import 'package:flutter/material.dart';

import 'banner.dart';

enum CardBannerPosition {
  TOPLEFT,
  TOPRIGHT,
  BOTTOMLEFT,
  BOTTOMRIGHT,
}

class CardBanner extends StatelessWidget {
  const CardBanner({
    super.key,
    required this.child,
    required this.text,
    this.position = CardBannerPosition.TOPLEFT,
    this.color = Colors.orange,
    this.edgeColor = const Color.fromARGB(255, 7, 86, 150),
    this.radius = 4,
    this.padding = 4.0,
    this.edgeSize = 6,
    this.textStyle = const TextStyle(fontSize: 10, color: Colors.white),
    required this.text2,
    required this.isSoldOut,
  });

  final Widget child;
  final String text;
  final String text2;
  final Color color;
  final Color edgeColor;
  final double edgeSize;
  final double radius;
  final double padding;
  final CardBannerPosition position;
  final TextStyle textStyle;
  final bool isSoldOut;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
            right: position.toString().contains("RIGHT") ? -6 : null,
            left: position.toString().contains("LEFT") ? -6 : null,
            top: position.toString().contains("TOP") ? 20 : null,
            bottom: position.toString().contains("BOTTOM") ? 20 : null,
            child: Visibility(
              visible: text.isNotEmpty,
              child: CustomPaint(
                painter: DesignCardBanner(edgeColor, position, edgeSize),
                child: Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                      bottomLeft: position.toString().contains("LEFT")
                          ? Radius.zero
                          : Radius.circular(radius),
                      bottomRight: position.toString().contains("RIGHT")
                          ? Radius.zero
                          : Radius.circular(radius),
                    ),
                    color: color,
                  ),
                  child: Text(text, style: textStyle),
                ),
              ),
            )),
        Visibility(
            visible: text2.isNotEmpty,
            child: CornerBanner(
              bannerPosition: CornerBannerPosition.topLeft,
              bannerColor: isSoldOut ? Colors.red : Colors.green,
              child: Text(isSoldOut ? "Sold Out" : text2,
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
            ))
      ],
    );
  }
}

class DesignCardBanner extends CustomPainter {
  DesignCardBanner(this.color, this.position, this.edgeSize);

  final Color color;
  final CardBannerPosition position;
  final double edgeSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (position.toString().contains("LEFT")) {
      Paint paint = Paint()..color = color;
      var path = Path();
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(10, size.height + edgeSize);
      path.lineTo(10, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    } else {
      Paint paint = Paint()..color = color;
      var path = Path();
      path.moveTo(size.width, size.height);

      path.lineTo(size.width - 10, size.height + edgeSize);
      path.lineTo(size.width - 10, size.height);
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
