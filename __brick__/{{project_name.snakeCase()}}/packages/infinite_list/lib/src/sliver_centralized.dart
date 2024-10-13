import 'package:flutter/material.dart';

/// {@template sliver_centralized}
/// A sliver that centers its child and fills the remaining space.
///
/// This is useful for centering a child in a [CustomScrollView].
/// {@endtemplate}
class SliverCentralized extends StatelessWidget {
  /// Constructs a [SliverCentralized]. <br />
  /// {@macro sliver_centralized}
  const SliverCentralized({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: child),
    );
  }
}
