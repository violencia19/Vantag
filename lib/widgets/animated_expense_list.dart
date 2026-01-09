import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'expense_history_card.dart';

/// Animasyonlu harcama listesi
/// Yeni kartlar slideUp + fadeIn ile eklenir
/// Silinen kartlar slideOut + fadeOut ile çıkar
class AnimatedExpenseList extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense, ExpenseDecision)? onDecisionUpdate;
  final Function(Expense)? onDelete;
  final ScrollController? scrollController;

  const AnimatedExpenseList({
    super.key,
    required this.expenses,
    this.onDecisionUpdate,
    this.onDelete,
    this.scrollController,
  });

  @override
  State<AnimatedExpenseList> createState() => AnimatedExpenseListState();
}

class AnimatedExpenseListState extends State<AnimatedExpenseList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Expense> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.expenses);
  }

  @override
  void didUpdateWidget(AnimatedExpenseList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Yeni eklenen itemları bul
    final newItems = widget.expenses.where((e) => !_items.contains(e)).toList();
    final removedItems = _items.where((e) => !widget.expenses.contains(e)).toList();

    // Önce silinen itemları kaldır
    for (final item in removedItems) {
      final index = _items.indexOf(item);
      if (index >= 0) {
        _removeItem(index);
      }
    }

    // Sonra yeni itemları ekle
    for (final item in newItems) {
      _insertItem(0, item);
    }
  }

  void _insertItem(int index, Expense item) {
    _items.insert(index, item);
    _listKey.currentState?.insertItem(
      index,
      duration: AppAnimations.medium,
    );
  }

  void _removeItem(int index) {
    final removedItem = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedItem, animation),
      duration: AppAnimations.medium,
    );
  }

  /// Dışarıdan item ekleme (örn: yeni harcama kaydı)
  void addExpense(Expense expense) {
    _insertItem(0, expense);
  }

  /// Dışarıdan item silme
  void removeExpense(Expense expense) {
    final index = _items.indexOf(expense);
    if (index >= 0) {
      _removeItem(index);
    }
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final expense = _items[index];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.standardCurve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseHistoryCard(
              expense: expense,
              onDecisionUpdate: widget.onDecisionUpdate != null
                  ? (decision) => widget.onDecisionUpdate!(expense, decision)
                  : null,
              onDelete: widget.onDelete != null
                  ? () => widget.onDelete!(expense)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemovedItem(Expense expense, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.exitCurve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseHistoryCard(expense: expense),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedList(
      key: _listKey,
      controller: widget.scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _items.length,
      itemBuilder: _buildItem,
    );
  }
}

/// Staggered fade-in ile liste görünümü
/// Her item belirli bir gecikmeyle görünür
class StaggeredFadeList extends StatefulWidget {
  final List<Widget> children;
  final Duration initialDelay;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final Offset slideOffset;

  const StaggeredFadeList({
    super.key,
    required this.children,
    this.initialDelay = AppAnimations.initialDelay,
    this.staggerDelay = AppAnimations.staggerDelay,
    this.itemDuration = AppAnimations.medium,
    this.curve = AppAnimations.standardCurve,
    this.slideOffset = const Offset(0, 20),
  });

  @override
  State<StaggeredFadeList> createState() => _StaggeredFadeListState();
}

class _StaggeredFadeListState extends State<StaggeredFadeList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.itemDuration,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.slideOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(widget.initialDelay);

    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      _controllers[i].forward();
      if (i < _controllers.length - 1) {
        await Future.delayed(widget.staggerDelay);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimations[index].value,
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Grid için staggered animasyon
class StaggeredFadeGrid extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Duration initialDelay;
  final Duration staggerDelay;

  const StaggeredFadeGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1.0,
    this.initialDelay = AppAnimations.initialDelay,
    this.staggerDelay = AppAnimations.staggerDelay,
  });

  @override
  State<StaggeredFadeGrid> createState() => _StaggeredFadeGridState();
}

class _StaggeredFadeGridState extends State<StaggeredFadeGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        vsync: this,
        duration: AppAnimations.medium,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: AppAnimations.standardCurve,
      );
    }).toList();

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(widget.initialDelay);

    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      _controllers[i].forward();
      if (i < _controllers.length - 1) {
        await Future.delayed(widget.staggerDelay);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _animations[index],
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(_animations[index]),
            child: widget.children[index],
          ),
        );
      },
    );
  }
}
