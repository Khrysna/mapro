import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<ItemType> = Widget Function(
  BuildContext context,
  ItemType item,
  int index,
);

class InfiniteListBuilder<ItemType> {
  const InfiniteListBuilder({
    required this.itemBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
  });

  final ItemWidgetBuilder<ItemType> itemBuilder;

  final WidgetBuilder? firstPageErrorIndicatorBuilder;

  final WidgetBuilder? newPageErrorIndicatorBuilder;

  final WidgetBuilder? firstPageProgressIndicatorBuilder;

  final WidgetBuilder? newPageProgressIndicatorBuilder;

  final WidgetBuilder? noItemsFoundIndicatorBuilder;

  final WidgetBuilder? noMoreItemsIndicatorBuilder;
}
