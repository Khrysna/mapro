import 'package:flutter/widgets.dart';
import 'package:infinite_list/infinite_list.dart';
import 'package:infinite_list/src/sliver_centralized.dart';

class SliverInfiniteList<T> extends StatefulWidget {
  const SliverInfiniteList({
    required this.onFetchData,
    required this.builderDelegate,
    required this.state,
    super.key,
    this.debounceDuration = defaultDebounceDuration,
    this.centerLoading = false,
    this.centerError = false,
    this.centerEmpty = false,
  });

  final Duration debounceDuration;

  final VoidCallback onFetchData;

  final InfiniteListBuilder<T> builderDelegate;

  final InfiniteListState<T> state;

  final bool centerLoading;

  final bool centerError;

  final bool centerEmpty;

  @override
  State<SliverInfiniteList<T>> createState() => _SliverInfiniteListState<T>();
}

class _SliverInfiniteListState<T> extends State<SliverInfiniteList<T>> {
  late final CallbackDebouncer debounce;

  bool isInitial = true;

  int? _lastFetchedIndex;

  @override
  void initState() {
    super.initState();
    debounce = CallbackDebouncer(widget.debounceDuration);

    if (isInitial) {
      setState(() => isInitial = false);
      widget.onFetchData.call();
    }
  }

  @override
  void didUpdateWidget(SliverInfiniteList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.state.hasReachedMax && oldWidget.state.hasReachedMax) {
      attemptFetch();
    }
  }

  @override
  void dispose() {
    super.dispose();
    debounce.dispose();
  }

  void attemptFetch() {
    if (!widget.state.hasReachedMax && !widget.state.isLoading && !widget.state.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.state.isInitial) {
          widget.onFetchData();
        } else {
          debounce(widget.onFetchData);
        }
      });
    }
  }

  void onBuiltLast(int lastItemIndex) {
    if (_lastFetchedIndex != lastItemIndex) {
      _lastFetchedIndex = lastItemIndex;
      attemptFetch();
    }
  }

  WidgetBuilder get firstPageErrorIndicatorBuilder {
    final builder = widget.builderDelegate.firstPageErrorIndicatorBuilder;
    return builder ?? defaultInfiniteListErrorBuilder;
  }

  WidgetBuilder get newPageErrorIndicatorBuilder {
    final builder = widget.builderDelegate.newPageErrorIndicatorBuilder;
    return builder ?? defaultInfiniteListErrorBuilder;
  }

  WidgetBuilder get firstPageProgressIndicatorBuilder {
    final builder = widget.builderDelegate.firstPageProgressIndicatorBuilder;
    return builder ?? defaultInfiniteListLoadingBuilder;
  }

  WidgetBuilder get newPageProgressIndicatorBuilder {
    final builder = widget.builderDelegate.newPageProgressIndicatorBuilder;
    return builder ?? defaultInfiniteListLoadingBuilder;
  }

  WidgetBuilder get noItemsFoundIndicatorBuilder {
    final builder = widget.builderDelegate.noItemsFoundIndicatorBuilder;
    return builder ?? defaultNoItemsFoundIndicatorBuilder;
  }

  WidgetBuilder get noMoreItemsIndicatorBuilder {
    final builder = widget.builderDelegate.noMoreItemsIndicatorBuilder;
    return builder ?? defaultNoItemsFoundIndicatorBuilder;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final lastItemIndex = state.itemCount - 1;

    Widget? centeredSliver;

    if (state.isLoading && state.isEmpty) {
      if (widget.centerLoading) {
        centeredSliver = SliverCentralized(child: firstPageProgressIndicatorBuilder.call(context));
      } else {
        centeredSliver = SliverToBoxAdapter(child: firstPageProgressIndicatorBuilder.call(context));
      }
    } else if (state.hasError && state.isEmpty) {
      if (widget.centerError) {
        centeredSliver = SliverCentralized(child: firstPageErrorIndicatorBuilder.call(context));
      } else {
        centeredSliver = SliverToBoxAdapter(child: firstPageErrorIndicatorBuilder.call(context));
      }
    } else if (state.isEmpty) {
      if (widget.centerEmpty) {
        centeredSliver = SliverCentralized(child: noItemsFoundIndicatorBuilder.call(context));
      } else {
        centeredSliver = SliverToBoxAdapter(child: noItemsFoundIndicatorBuilder.call(context));
      }
    }

    if (centeredSliver != null) return centeredSliver;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: state.itemCount,
        (context, index) {
          if (index == lastItemIndex) {
            onBuiltLast(lastItemIndex);
          }

          if (index == lastItemIndex) {
            if (state.itemCount == 1) {
              return widget.builderDelegate.itemBuilder(context, state.values[index], index);
            } else if (state.hasError) {
              return newPageErrorIndicatorBuilder(context);
            } else if (state.isLoading) {
              return newPageProgressIndicatorBuilder(context);
            } else if (state.hasReachedMax) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.builderDelegate.itemBuilder(context, state.values[index], index),
                  noMoreItemsIndicatorBuilder(context),
                ],
              );
            }

            return const SizedBox.shrink();
          }

          return widget.builderDelegate.itemBuilder(context, state.values[index], index);
        },
      ),
    );
  }
}
