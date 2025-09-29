import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

enum GradientType {
  primary,
  secondary,
  accent,
  sunset,
  ocean,
  forest,
  cherry,
  cosmic,
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final GradientType type;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double>? stops;

  const GradientBackground({
    Key? key,
    required this.child,
    this.type = GradientType.primary,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.stops,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(type),
          begin: begin,
          end: end,
          stops: stops,
        ),
      ),
      child: child,
    );
  }

  List<Color> _getGradientColors(GradientType type) {
    switch (type) {
      case GradientType.primary:
        return AppColors.primaryGradient;
      case GradientType.secondary:
        return AppColors.secondaryGradient;
      case GradientType.accent:
        return AppColors.accentGradient;
      case GradientType.sunset:
        return AppColors.sunsetGradient;
      case GradientType.ocean:
        return [
          const Color(0xFF00C9FF),
          const Color(0xFF92FE9D),
        ];
      case GradientType.forest:
        return [
          const Color(0xFF134E5E),
          const Color(0xFF71B280),
        ];
      case GradientType.cherry:
        return [
          const Color(0xFFEB3349),
          const Color(0xFFF45C43),
        ];
      case GradientType.cosmic:
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ];
    }
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
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
      begin: 0.0,
      end: 1.0,
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.lerp(
                widget.begin as Alignment,
                widget.end as Alignment,
                _animation.value,
              )!,
              end: Alignment.lerp(
                widget.end as Alignment,
                widget.begin as Alignment,
                _animation.value,
              )!,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
