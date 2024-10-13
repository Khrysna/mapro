import 'package:flutter/material.dart';
import 'package:infinite_list/src/infinite_list.dart';

/// The type definition for the [InfiniteList.builderDelegate.itemBuilder].
typedef ItemBuilder = Widget Function(BuildContext context, int index);

/// Default value to [InfiniteList.builderDelegate.loadingView].
/// Renders a centered [CircularProgressIndicator].
Widget defaultInfiniteListLoadingBuilder(BuildContext buildContext) {
  return Center(
    child: Container(
      height: 32,
      width: 32,
      margin: const EdgeInsets.all(8),
      child: const CircularProgressIndicator(),
    ),
  );
}

/// Default value to [InfiniteList.builderDelegate.newPageErrorIndicatorBuilder].
/// Renders a centered [Text] "error".
Widget defaultInfiniteListErrorBuilder(BuildContext buildContext) {
  return const Center(
    child: Text('Error'),
  );
}

Widget defaultNoItemsFoundIndicatorBuilder(BuildContext buildContext) {
  return const SizedBox.shrink();
}

/// Default value to [InfiniteList.debounceDuration].
const defaultDebounceDuration = Duration(milliseconds: 100);
