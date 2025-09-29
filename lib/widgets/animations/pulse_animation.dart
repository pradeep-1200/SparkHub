import 'package:flutter/material.dart';

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool autoStart;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class PulseOpacityAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulseOpacityAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.minOpacity = 0.5,
    this.maxOpacity = 1.0,
  }) : super(key: key);

  @override
  State<PulseOpacityAnimation> createState() => _PulseOpacityAnimationState();
}

class _PulseOpacityAnimationState extends State<PulseOpacityAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
