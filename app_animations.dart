import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  // Standard durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration longDuration = Duration(milliseconds: 500);

  // ==================== CARD ANIMATIONS ====================

  static Widget animatedCard({
    required Widget child,
    Duration delay = Duration.zero,
    VoidCallback? onTap,
  }) {
    return Animate(
      delay: delay,
      effects: [
        FadeEffect(duration: mediumDuration),
        SlideEffect(
          duration: mediumDuration,
          begin: const Offset(0, 20),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
        ScaleEffect(
          duration: mediumDuration,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic,
        ),
      ],
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: child,
            )
          : child,
    );
  }

  // ==================== HERO ANIMATIONS ====================

  static Widget heroPhoto({
    required String tag,
    required Widget child,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, flightDirection,
          fromHeroContext, toHeroContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    16 + (animation.value * 24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2 * animation.value),
                      blurRadius: 20 * animation.value,
                      spreadRadius: 5 * animation.value,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // ==================== LIST ITEM ANIMATIONS ====================

  static Widget animatedListItem({
    required Widget child,
    required int index,
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    return Animate(
      delay: Duration(milliseconds: index * staggerDelay.inMilliseconds),
      effects: [
        FadeEffect(duration: mediumDuration),
        SlideEffect(
          duration: mediumDuration,
          begin: const Offset(20, 0),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: child,
    );
  }

  // ==================== BUTTON ANIMATIONS ====================

  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return AnimatedPress(
      onPressed: onPressed,
      child: child,
    );
  }

  // ==================== GALLERY ANIMATIONS ====================

  static Widget galleryGridItem({
    required Widget child,
    required int index,
    int crossAxisCount = 3,
  }) {
    final row = index ~/ crossAxisCount;
    final col = index % crossAxisCount;
    
    return Animate(
      delay: Duration(milliseconds: (row * 50) + (col * 30)),
      effects: [
        FadeEffect(duration: mediumDuration),
        ScaleEffect(
          duration: mediumDuration,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        ),
      ],
      child: child,
    );
  }

  // ==================== TAB TRANSITIONS ====================

  static Widget tabTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }

  // ==================== PROFILE TRANSITION ====================

  static Widget profileTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animation.value),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ==================== SHIMMER LOADING ====================

  static Widget shimmerLoading({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: Colors.white.withValues(alpha: 0.5),
        );
  }

  // ==================== PULSE ANIMATION ====================

  static Widget pulseWidget({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return Animate(
      effects: [
        ScaleEffect(
          duration: duration,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          curve: Curves.easeInOut,
        ),
      ],
      onPlay: (controller) => controller.repeat(reverse: true),
      child: child,
    );
  }

  // ==================== SUCCESS ANIMATION ====================

  static Widget successCheckmark({
    required bool show,
    double size = 50,
  }) {
    if (!show) return const SizedBox.shrink();
    
    return Animate(
      effects: [
        ScaleEffect(
          duration: mediumDuration,
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
        ),
        FadeEffect(duration: shortDuration),
      ],
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

// ==================== ANIMATED PRESS BUTTON ====================

class AnimatedPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedPress({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ==================== SWIPE CARD ====================

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final String? leftActionText;
  final String? rightActionText;
  final Color? leftActionColor;
  final Color? rightActionColor;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionText,
    this.rightActionText,
    this.leftActionColor,
    this.rightActionColor,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent > 100 && widget.onSwipeRight != null) {
      widget.onSwipeRight!();
    } else if (_dragExtent < -100 && widget.onSwipeLeft != null) {
      widget.onSwipeLeft!();
    }
    
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(_dragExtent, 0, 0),
        child: Stack(
          children: [
            // Background actions
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: widget.rightActionColor ?? Colors.green,
                        child: Center(
                          child: Text(
                            widget.rightActionText ?? 'Edit',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: widget.leftActionColor ?? Colors.red,
                        child: Center(
                          child: Text(
                            widget.leftActionText ?? 'Delete',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Foreground card
            Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE TRANSITION ====================

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.right,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0, 1);
                break;
              case AxisDirection.down:
                begin = const Offset(0, -1);
                break;
              case AxisDirection.left:
                begin = const Offset(1, 0);
                break;
              case AxisDirection.right:
                begin = const Offset(-1, 0);
                break;
            }

            final tween = Tween(begin: begin, end: Offset.zero).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

// ==================== FADE PAGE TRANSITION ====================

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({
    required this.page,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// ==================== ANIMATED BUILDER (alias) ====================

typedef AnimatedBuilder = AnimatedBuilder; // Use AnimatedBuilder from Flutter
