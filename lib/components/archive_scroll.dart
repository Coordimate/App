import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverHidedHeader extends SingleChildRenderObjectWidget {
  const SliverHidedHeader({
    super.key,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverHidedHeader(context: context);
  }
}

class RenderSliverHidedHeader extends RenderSliverSingleBoxAdapter {
  RenderSliverHidedHeader({
    required BuildContext context,
    super.child,
  }) : _context = context;

  bool _correctScrollOffsetNextLayout = true;
  bool _showChild = true;
  final BuildContext _context;
  ScrollableState? _scrollableState;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    if (_correctScrollOffsetNextLayout) {
      geometry = SliverGeometry(scrollOffsetCorrection: childExtent);
      _correctScrollOffsetNextLayout = false;
      return;
    }
    _manageSnapEffect(
      childExtent: childExtent,
      paintedChildSize: paintedChildSize,
    );
    _manageInsertChild(
      childExtent: childExtent,
      paintedChildSize: paintedChildSize,
    );

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      paintOrigin: _showChild ? 0 : -paintedChildSize,
      layoutExtent: _showChild ? null : 0,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollableState = Scrollable.of(_context);
  }

  @override
  void dispose() {
    if (_scrollableState != null) {
      final scrollPosition = _scrollableState!.position;
      if (_subscribedSnapScrollNotifierListener != null) {
        scrollPosition.isScrollingNotifier
            .removeListener(_subscribedSnapScrollNotifierListener!);
      }
      if (_subscribedInsertChildScrollNotifierListener != null) {
        scrollPosition.isScrollingNotifier
            .removeListener(_subscribedInsertChildScrollNotifierListener!);
      }
    }
    super.dispose();
  }

  void Function()? _subscribedSnapScrollNotifierListener;

  _manageSnapEffect({
    required double childExtent,
    required double paintedChildSize,
  }) {
    final scrollPosition = Scrollable.of(_context).position;

    if (_subscribedSnapScrollNotifierListener != null) {
      scrollPosition.isScrollingNotifier
          .removeListener(_subscribedSnapScrollNotifierListener!);
    }

    _subscribedSnapScrollNotifierListener = () => _snapScrollNotifierListener(
          childExtent: childExtent,
          paintedChildSize: paintedChildSize,
        );
    scrollPosition.isScrollingNotifier
        .addListener(_subscribedSnapScrollNotifierListener!);
  }

  void _snapScrollNotifierListener({
    required double childExtent,
    required double paintedChildSize,
  }) {
    final scrollPosition = Scrollable.of(_context).position;
    final isIdle = scrollPosition is IdleScrollActivity;

    final isChildVisible = paintedChildSize > 0;

    if (isIdle && isChildVisible) {
      if (paintedChildSize >= childExtent / 2 &&
          paintedChildSize != childExtent) {
        scrollPosition.animateTo(
          0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      } else if (paintedChildSize < childExtent / 2 && paintedChildSize != 0) {
        scrollPosition.animateTo(
          childExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void Function()? _subscribedInsertChildScrollNotifierListener;

  void _manageInsertChild({
    required double childExtent,
    required double paintedChildSize,
  }) {
    final scrollPosition = Scrollable.of(_context).position;

    if (_subscribedInsertChildScrollNotifierListener != null) {
      scrollPosition.isScrollingNotifier
          .removeListener(_subscribedInsertChildScrollNotifierListener!);
    }

    _subscribedInsertChildScrollNotifierListener =
        () => _insertChildScrollNotifierListener(
              childExtent: childExtent,
              paintedChildSize: paintedChildSize,
            );
    scrollPosition.isScrollingNotifier
        .addListener(_subscribedInsertChildScrollNotifierListener!);
  }

  void _insertChildScrollNotifierListener({
    required double childExtent,
    required double paintedChildSize,
  }) {
    final scrollPosition = Scrollable.of(_context).position;

    final isScrolling = scrollPosition.isScrollingNotifier.value;

    if (isScrolling) {
      return;
    }

    final scrollOffset = scrollPosition.pixels;

    if (!_showChild && scrollOffset <= 0.1) {
      _showChild = true;
      _correctScrollOffsetNextLayout = true;
      markNeedsLayout();
    }

    if (scrollPosition.physics
        .containsScrollPhysicsOfType<ClampingScrollPhysics>()) {
      if (!_showChild && scrollOffset == childExtent) {
        _showChild = true;
        markNeedsLayout();
      }
    }

    if (_showChild && scrollOffset > childExtent) {
      _showChild = false;
      markNeedsLayout();
    }
  }
}

extension _ScrollPhysicsExtension on ScrollPhysics {
  bool containsScrollPhysicsOfType<T extends ScrollPhysics>() {
    return this is T || (parent?.containsScrollPhysicsOfType<T>() ?? false);
  }
}
