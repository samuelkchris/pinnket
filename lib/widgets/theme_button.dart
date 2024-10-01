import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ThemeButton extends StatefulWidget {
  const ThemeButton({
    super.key,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 300),
    this.padding = EdgeInsets.zero,
    this.onChanged,
  });

  final double size;
  final Duration duration;
  final EdgeInsets padding;
  final ValueChanged<bool>? onChanged;

  @override
  State<ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 180).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (_isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onChanged?.call(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: AnimatedContainer(
        duration: widget.duration,
        padding: widget.padding,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isDarkMode ? Colors.grey[850] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: _isDarkMode ? Colors.black26 : Colors.grey.withOpacity(
                  0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159 / 180,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  _isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                  size: widget.size * 0.6,
                  color: _isDarkMode ? Colors.white : Colors.orange,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}