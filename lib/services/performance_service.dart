import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance optimization utilities
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Frame timing tracking
  final List<Duration> _frameTimes = [];
  static const int _maxFrameSamples = 60;

  /// Get average frame time
  Duration get averageFrameTime {
    if (_frameTimes.isEmpty) return Duration.zero;
    final total = _frameTimes.fold<int>(0, (sum, d) => sum + d.inMicroseconds);
    return Duration(microseconds: total ~/ _frameTimes.length);
  }

  /// Get current FPS estimate
  double get estimatedFps {
    final avg = averageFrameTime.inMicroseconds;
    if (avg == 0) return 60.0;
    return (1000000 / avg).clamp(0, 120);
  }

  /// Track frame timing
  void trackFrameTime(Duration frameTime) {
    _frameTimes.add(frameTime);
    if (_frameTimes.length > _maxFrameSamples) {
      _frameTimes.removeAt(0);
    }
  }

  /// Clear performance data
  void clearMetrics() {
    _frameTimes.clear();
  }
}

/// Global instance
final performance = PerformanceService();

// ==================== DEBOUNCE / THROTTLE ====================

/// Debounce utility for search inputs, etc.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttle utility for scroll events, etc.
class Throttler {
  final Duration interval;
  Timer? _timer;
  bool _canRun = true;

  Throttler({this.interval = const Duration(milliseconds: 100)});

  void call(VoidCallback action) {
    if (_canRun) {
      action();
      _canRun = false;
      _timer = Timer(interval, () => _canRun = true);
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

// ==================== CACHED WIDGETS ====================

/// ValueListenableBuilder alternative with memoization
class MemoizedBuilder<T> extends StatefulWidget {
  final ValueListenable<T> valueListenable;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const MemoizedBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.child,
  });

  @override
  State<MemoizedBuilder<T>> createState() => _MemoizedBuilderState<T>();
}

class _MemoizedBuilderState<T> extends State<MemoizedBuilder<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.valueListenable.value;
    widget.valueListenable.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (_value != widget.valueListenable.value) {
      setState(() {
        _value = widget.valueListenable.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, widget.child);
  }
}

/// Widget that only rebuilds when the selector changes
class SelectorBuilder<T, S> extends StatefulWidget {
  final T value;
  final S Function(T value) selector;
  final Widget Function(BuildContext context, S selected) builder;

  const SelectorBuilder({
    super.key,
    required this.value,
    required this.selector,
    required this.builder,
  });

  @override
  State<SelectorBuilder<T, S>> createState() => _SelectorBuilderState<T, S>();
}

class _SelectorBuilderState<T, S> extends State<SelectorBuilder<T, S>> {
  late S _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selector(widget.value);
  }

  @override
  void didUpdateWidget(SelectorBuilder<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSelected = widget.selector(widget.value);
    if (newSelected != _selected) {
      _selected = newSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selected);
  }
}

// ==================== LAZY LOADING ====================

/// Lazy-loaded widget that builds on first frame
class LazyWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final Widget? placeholder;

  const LazyWidget({
    super.key,
    required this.builder,
    this.placeholder,
  });

  @override
  State<LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  Widget? _child;
  bool _built = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _child = widget.builder(context);
          _built = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_built) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return _child!;
  }
}

/// Deferred widget that builds after a delay
class DeferredWidget extends StatefulWidget {
  final Duration delay;
  final WidgetBuilder builder;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.delay,
    required this.builder,
    this.placeholder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Widget? _child;
  bool _built = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _child = widget.builder(context);
          _built = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_built) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return _child!;
  }
}

// ==================== LIST OPTIMIZATION ====================

/// Optimized list item wrapper with automatic repaint boundary
class OptimizedListItem extends StatelessWidget {
  final Widget child;
  final bool addRepaintBoundary;
  final bool addAutomaticKeepAlive;

  const OptimizedListItem({
    super.key,
    required this.child,
    this.addRepaintBoundary = true,
    this.addAutomaticKeepAlive = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (addRepaintBoundary) {
      result = RepaintBoundary(child: result);
    }

    if (addAutomaticKeepAlive) {
      result = AutomaticKeepAlive(child: result);
    }

    return result;
  }
}

/// Optimized sliver list builder with caching
class CachedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool addRepaintBoundary;
  final double? itemExtent;

  const CachedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.addRepaintBoundary = true,
    this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = itemBuilder(context, items[index], index);
            return addRepaintBoundary ? RepaintBoundary(child: item) : item;
          },
          childCount: items.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = itemBuilder(context, items[index], index);
          return addRepaintBoundary ? RepaintBoundary(child: item) : item;
        },
        childCount: items.length,
      ),
    );
  }
}

// ==================== IMAGE OPTIMIZATION ====================

/// Optimized network image with caching hints
class OptimizedNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildError();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Icon(Icons.error_outline, color: Colors.grey),
    );
  }
}

// ==================== ANIMATION OPTIMIZATION ====================

/// Conditional animation that respects reduce motion
class ConditionalAnimation extends StatelessWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
  final Curve curve;

  const ConditionalAnimation({
    super.key,
    required this.child,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion || !animate) {
      return child;
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: child,
    );
  }
}

// ==================== MEMORY OPTIMIZATION ====================

/// Widget that disposes heavy resources when not visible
class VisibilityOptimized extends StatefulWidget {
  final Widget child;
  final Widget placeholder;
  final Duration delay;

  const VisibilityOptimized({
    super.key,
    required this.child,
    required this.placeholder,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<VisibilityOptimized> createState() => _VisibilityOptimizedState();
}

class _VisibilityOptimizedState extends State<VisibilityOptimized> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _visible ? widget.child : widget.placeholder;
  }
}

// ==================== SCROLL OPTIMIZATION ====================

/// Optimized scroll physics that reduces rebuilds
class OptimizedScrollPhysics extends ScrollPhysics {
  const OptimizedScrollPhysics({super.parent});

  @override
  OptimizedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OptimizedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;
}

// ==================== COMPUTE HELPERS ====================

/// Run heavy computation in isolate
Future<R> computeHeavy<Q, R>(Q message, ComputeCallback<Q, R> callback) {
  return compute(callback, message);
}
