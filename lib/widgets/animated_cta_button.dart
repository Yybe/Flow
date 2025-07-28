import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CTAType { tasks, habits, journal }

class AnimatedCTAButton extends StatefulWidget {
  final CTAType type;
  final VoidCallback onPressed;
  final String heroTag;

  const AnimatedCTAButton({
    super.key,
    required this.type,
    required this.onPressed,
    required this.heroTag,
  });

  @override
  State<AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<AnimatedCTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));



    // Initialize color animation with the initial color
    final initialColor = _getColorForType(widget.type);
    _colorAnimation = ColorTween(
      begin: initialColor,
      end: initialColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _updateColorAnimation() {
    final targetColor = _getColorForType(widget.type);
    final currentColor = _colorAnimation.value ?? targetColor;
    _colorAnimation = ColorTween(
      begin: currentColor,
      end: targetColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Color _getColorForType(CTAType type) {
    switch (type) {
      case CTAType.tasks:
        return AppColors.teal;
      case CTAType.habits:
        return AppColors.coral;
      case CTAType.journal:
        return Colors.purple;
    }
  }

  IconData _getIconForType(CTAType type) {
    switch (type) {
      case CTAType.tasks:
        return Icons.add;
      case CTAType.habits:
        return Icons.track_changes; // More distinctive icon for habits
      case CTAType.journal:
        return Icons.edit;
    }
  }

  Widget _getExtendedContent(CTAType type) {
    switch (type) {
      case CTAType.tasks:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 20),
            SizedBox(width: 8),
            Text(
              'Task',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        );
      case CTAType.habits:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.track_changes, size: 20),
            SizedBox(width: 8),
            Text(
              'Habit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        );
      case CTAType.journal:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 8),
            Text(
              'Write',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        );
    }
  }

  @override
  void didUpdateWidget(AnimatedCTAButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      _updateColorAnimation();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_colorAnimation.value ?? AppColors.teal).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.type == CTAType.journal
                  ? FloatingActionButton.extended(
                      heroTag: widget.heroTag,
                      onPressed: widget.onPressed,
                      backgroundColor: _colorAnimation.value ?? AppColors.teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      label: _getExtendedContent(widget.type),
                    )
                  : FloatingActionButton(
                      heroTag: widget.heroTag,
                      onPressed: widget.onPressed,
                      backgroundColor: _colorAnimation.value ?? AppColors.teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      child: Icon(_getIconForType(widget.type), size: 24),
                    ),
            ),
        );
      },
    );
  }
}
