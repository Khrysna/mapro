import 'package:flutter/material.dart';
import 'package:infinite_list/src/defaults.dart';
import 'package:infinite_list/src/infinite_list_builder.dart';
import 'package:infinite_list/src/infinite_list_state.dart';
import 'package:infinite_list/src/sliver_infinite_list.dart';

class InfiniteList<T> extends StatelessWidget {
  const InfiniteList({
    required this.onFetchData,
    required this.state,
    required this.builderDelegate,
    super.key,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.cacheExtent,
    this.debounceDuration = defaultDebounceDuration,
    this.reverse = false,
    this.padding,
    this.centerLoading = false,
    this.centerError = false,
    this.centerEmpty = false,
  });

  final ScrollController? scrollController;

  final Axis scrollDirection;

  final ScrollPhysics? physics;

  final Duration debounceDuration;

  final bool reverse;

  final InfiniteListState<T> state;

  final InfiniteListBuilder<T> builderDelegate;

  final void Function() onFetchData;

  final double? cacheExtent;

  final EdgeInsets? padding;

  final bool centerLoading;

  final bool centerError;

  final bool centerEmpty;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: scrollController,
      physics: physics,
      cacheExtent: cacheExtent,
      slivers: [
        _ContextualSliverPadding(
          padding: padding,
          scrollDirection: scrollDirection,
          sliver: SliverInfiniteList(
            onFetchData: onFetchData,
            builderDelegate: builderDelegate,
            debounceDuration: debounceDuration,
            centerLoading: centerLoading,
            centerError: centerError,
            centerEmpty: centerEmpty,
            state: state,
          ),
        ),
      ],
    );
  }
}

class _ContextualSliverPadding extends StatelessWidget {
  const _ContextualSliverPadding({
    required this.scrollDirection,
    required this.sliver,
    this.padding,
  });

  final EdgeInsets? padding;
  final Axis scrollDirection;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry? effectivePadding = padding;
    final mediaQuery = MediaQuery.maybeOf(context);

    var sliver = this.sliver;
    if (padding == null) {
      if (mediaQuery != null) {
        // Automatically pad sliver with padding from MediaQuery.
        late final mediaQueryHorizontalPadding = mediaQuery.padding.copyWith(top: 0, bottom: 0);
        late final mediaQueryVerticalPadding = mediaQuery.padding.copyWith(left: 0, right: 0);
        // Consume the main axis padding with SliverPadding.
        effectivePadding = scrollDirection == Axis.vertical
            ? mediaQueryVerticalPadding
            : mediaQueryHorizontalPadding;
        // Leave behind the cross axis padding.
        sliver = MediaQuery(
          data: mediaQuery.copyWith(
            padding: scrollDirection == Axis.vertical
                ? mediaQueryHorizontalPadding
                : mediaQueryVerticalPadding,
          ),
          child: sliver,
        );
      }
    }

    if (effectivePadding != null) {
      sliver = SliverPadding(padding: effectivePadding, sliver: sliver);
    }
    return sliver;
  }
}
