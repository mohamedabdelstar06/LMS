import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'liquid_pill.dart';
import 'liquid_tap_item.dart';

class ContentTabBar extends StatefulWidget {
  const ContentTabBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _tabs = ['Lectures', 'Quizzes', 'Assignments'];

  @override
  State<ContentTabBar> createState() => _ContentTabBarState();
}

class _ContentTabBarState extends State<ContentTabBar>
    with SingleTickerProviderStateMixin {
  final _containerKey = GlobalKey();

  late Ticker _ticker;
  double _position = 0;
  double _velocity = 0;
  double _containerWidth = 0;

  static const double _stiffness = 320.0;
  static const double _damping = 28.0;
  static const double _mass = 1.0;
  static const double _restThreshold = 0.001;

  bool _isAnimating = false;

  final List<double> _rippleProgress = [0.0, 0.0, 0.0];
  final List<AnimationController?> _rippleControllers = [null, null, null];

  @override
  void initState() {
    super.initState();
    _position = widget.activeIndex.toDouble();
    _ticker = createTicker(_physicsTick);

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureWidth());
  }

  void _measureWidth() {
    final box =
    _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final w = box.size.width;
      if (w > 0 && w.isFinite && w != _containerWidth) {
        setState(() => _containerWidth = w);
      }
    }
  }

  void _physicsTick(Duration elapsed) {
    final target = widget.activeIndex.toDouble();
    const dt = 1 / 60;

    final displacement = _position - target;
    final springForce = -_stiffness * displacement;
    final dampingForce = -_damping * _velocity;
    final acceleration = (springForce + dampingForce) / _mass;

    _velocity += acceleration * dt;
    _position += _velocity * dt;

    final atRest = displacement.abs() < _restThreshold &&
        _velocity.abs() < _restThreshold;

    if (atRest) {
      _position = target;
      _velocity = 0;
      _ticker.stop();
      _isAnimating = false;
    }

    if (mounted) setState(() {});
  }

  void _onTabTap(int index) {
    if (index == widget.activeIndex) return;
    widget.onTap(index);

    if (!_ticker.isActive) {
      _isAnimating = true;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant ContentTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      if (!_ticker.isActive) {
        _isAnimating = true;
        _ticker.start();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    for (final c in _rippleControllers) {
      c?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabs = ContentTabBar._tabs;
    final tabCount = tabs.length;
    final tabWidth = _containerWidth > 0 ? _containerWidth / tabCount : 0.0;

    final ratio = tabCount > 1
        ? (_position / (tabCount - 1)).clamp(0.0, 1.0)
        : 0.0;
    final indicatorLeft = _containerWidth > 0
        ? ((_containerWidth - tabWidth) * ratio).clamp(
        0.0, _containerWidth - tabWidth)
        : 0.0;

    return Container(
      key: _containerKey,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFBAE6FD).withValues(alpha: .20),
        border: Border.all(
          color: Colors.white.withValues(alpha: .6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: .20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: .5),
            spreadRadius: -1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (_containerWidth > 0)
                  Positioned(
                    left: indicatorLeft,
                    top: 0,
                    bottom: 0,
                    width: tabWidth - 4,
                    child: LiquidPill(position: _position),
                  ),

                Row(
                  children: List.generate(tabCount, (i) {
                    final active = i == widget.activeIndex;
                    final proximity = 1.0 - (_position - i).abs().clamp(0.0, 1.0);

                    return Expanded(
                      child: TabItem(
                        label: tabs[i],
                        active: active,
                        proximity: proximity,
                        onTap: () => _onTabTap(i),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


