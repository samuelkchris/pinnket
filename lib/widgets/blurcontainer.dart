library blurry_container;

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class BlurryContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double elevation;
  final double blur;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BorderRadius borderRadius;

  const BlurryContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.blur = 5,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  const BlurryContainer.square({
    super.key,
    required this.child,
    double? dimension,
    this.blur = 5,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  })  : width = dimension,
        height = dimension;

  const BlurryContainer.expand({
    super.key,
    required this.child,
    this.blur = 5,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.transparent,
    this.borderRadius = BorderRadius.zero,
  })  : width = double.infinity,
        height = double.infinity;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.cover,
        child: Column(
          children: [
            Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/cardhandle.png',
                  // width: 100,
                  height: 100,
                )),
            Material(
              elevation: elevation,
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                          height: height,
                          width: width,
                          padding: padding,
                          color: color,
                          child: Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: child,
                          )),
                    ),
                    const Positioned(
                      top: 0,
                      left: 0,
                      // alignment: Alignment.topLeft,
                      child: Icon(Icons.drag_handle, color: Colors.black),
                    ),
                    const Positioned(
                      top: 0,
                      right: 0,
                      // alignment: Alignment.topRight,
                      child: Icon(Icons.drag_handle, color: Colors.black),
                    ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      child: Icon(Icons.drag_handle, color: Colors.black),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(Icons.drag_handle, color: Colors.black),
                    ),
                    Positioned(
                      top: 5,
                      left: width! / 2 - 50,
                      child: Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
