import 'package:equatable/equatable.dart';

class InfiniteListState<StateT> extends Equatable {
  const InfiniteListState()
      : this._(
          error: null,
          currentPage: 1,
          hasReachedMax: false,
          isInitial: true,
          isLoading: false,
          stackTrace: null,
          values: const [],
        );

  const InfiniteListState.loading()
      : this._(
          error: null,
          currentPage: 1,
          hasReachedMax: false,
          isInitial: false,
          isLoading: true,
          stackTrace: null,
          values: const [],
        );

  const InfiniteListState._({
    required this.error,
    required this.currentPage,
    required this.hasReachedMax,
    required this.isInitial,
    required this.isLoading,
    required this.stackTrace,
    required this.values,
  });

  InfiniteListState<StateT> addItem(StateT item) {
    final items = [item, ...values];

    return InfiniteListState._(
      error: null,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
      isInitial: false,
      isLoading: false,
      stackTrace: null,
      values: items,
    );
  }

  InfiniteListState<StateT> deleteItem({
    required bool Function(StateT) comparedBy,
  }) {
    final items = [...values];
    items.removeWhere((item) => comparedBy.call(item));

    return InfiniteListState._(
      error: null,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
      isInitial: false,
      isLoading: false,
      stackTrace: null,
      values: [...items],
    );
  }

  InfiniteListState<StateT> updateItem({
    required StateT Function(StateT) updatedItem,
    required bool Function(StateT) comparedBy,
  }) {
    final items = values.map((item) {
      if (comparedBy.call(item)) {
        return updatedItem.call(item);
      }

      return item;
    });

    return InfiniteListState._(
      error: null,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
      isInitial: false,
      isLoading: false,
      stackTrace: null,
      values: [...items],
    );
  }

  InfiniteListState<StateT> setLoading({bool isRefreshed = false}) {
    return InfiniteListState._(
      error: null,
      currentPage: isRefreshed ? 1 : currentPage,
      hasReachedMax: hasReachedMax,
      isInitial: false,
      isLoading: true,
      stackTrace: null,
      values: isRefreshed ? <StateT>[] : values,
    );
  }

  InfiniteListState<StateT> setError(Object? error, StackTrace? stackTrace) {
    return InfiniteListState._(
      error: error,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
      isInitial: false,
      isLoading: false,
      stackTrace: stackTrace,
      values: values,
    );
  }

  InfiniteListState<StateT> setData(List<StateT> values) {
    return InfiniteListState._(
      error: null,
      currentPage: currentPage + 1,
      hasReachedMax: values.isEmpty,
      isInitial: false,
      isLoading: false,
      stackTrace: null,
      values: [...this.values, ...values],
    );
  }

  InfiniteListState<StateT> setLastData(List<StateT> values) {
    return InfiniteListState._(
      error: null,
      currentPage: currentPage + 1,
      hasReachedMax: true,
      isInitial: false,
      isLoading: false,
      stackTrace: null,
      values: [...this.values, ...values],
    );
  }

  bool get hasValues => itemCount > 0;

  bool get isEmpty => itemCount == 0;

  bool get isNotEmpty => !isEmpty;

  bool get isSuccess => error == null && !isLoading;

  bool get hasError => error != null;

  int get itemCount => values.length;

  int get nextPage => currentPage + 1;

  final bool hasReachedMax;

  final int currentPage;

  final Object? error;

  final bool isInitial;

  final bool isLoading;

  final StackTrace? stackTrace;

  final List<StateT> values;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        isInitial,
        isLoading,
        values,
        hasReachedMax,
        error,
        stackTrace,
        currentPage,
      ];
}

// sealed class InfiniteListState<StateT> extends Equatable {
//   const InfiniteListState._();
//
//   const factory InfiniteListState.data({
//     required List<StateT> values,
//     required bool hasReachedMax,
//   }) = InfiniteListData<StateT>;
//
//   const factory InfiniteListState.loading({List<StateT>? values}) = InfiniteListLoading<StateT>;
//
//   const factory InfiniteListState.initial() = InfiniteListInitial<StateT>;
//
//   const factory InfiniteListState.error(
//     Object error,
//     StackTrace stackTrace, {
//     List<StateT>? values,
//   }) = InfiniteListError<StateT>;
//
//   bool get hasValues => itemCount > 0;
//
//   bool get isEmpty => itemCount == 0;
//
//   bool get hasError => error != null;
//
//   int get itemCount => values.length;
//
//   Object? get error;
//
//   bool get hasReachedMax;
//
//   bool get isInitial;
//
//   bool get isLoading;
//
//   StackTrace? get stackTrace;
//
//   List<StateT> get values;
//
//   @override
//   List<Object?> get props => [isInitial, isLoading, values, hasReachedMax, error, stackTrace];
// }
//
// final class InfiniteListData<StateT> extends InfiniteListState<StateT> {
//   const InfiniteListData({required List<StateT> values, required bool hasReachedMax})
//       : this._(values: values, hasReachedMax: hasReachedMax);
//
//   const InfiniteListData._({required this.values, required this.hasReachedMax}) : super._();
//
//   @override
//   Object? get error => null;
//
//   @override
//   final bool hasReachedMax;
//
//   @override
//   bool get isInitial => false;
//
//   @override
//   bool get isLoading => false;
//
//   @override
//   StackTrace? get stackTrace => null;
//
//   @override
//   final List<StateT> values;
// }
//
// final class InfiniteListInitial<StateT> extends InfiniteListState<StateT> {
//   const InfiniteListInitial() : this._();
//
//   const InfiniteListInitial._() : super._();
//
//   @override
//   Object? get error => null;
//
//   @override
//   bool get hasReachedMax => false;
//
//   @override
//   bool get isInitial => true;
//
//   @override
//   bool get isLoading => false;
//
//   @override
//   StackTrace? get stackTrace => null;
//
//   @override
//   List<StateT> get values => [];
// }
//
// final class InfiniteListLoading<StateT> extends InfiniteListState<StateT> {
//   const InfiniteListLoading({List<StateT>? values}) : this._(values: values ?? const []);
//
//   const InfiniteListLoading._({required this.values}) : super._();
//
//   @override
//   Object? get error => null;
//
//   @override
//   bool get isInitial => false;
//
//   @override
//   bool get isLoading => true;
//
//   @override
//   bool get hasReachedMax => false;
//
//   @override
//   StackTrace? get stackTrace => null;
//
//   @override
//   final List<StateT> values;
// }
//
// final class InfiniteListError<StateT> extends InfiniteListState<StateT> {
//   const InfiniteListError(
//     Object error,
//     StackTrace stackTrace, {
//     List<StateT>? values,
//   }) : this._(error, stackTrace: stackTrace, values: values ?? const []);
//
//   const InfiniteListError._(
//     this.error, {
//     required this.stackTrace,
//     required this.values,
//   }) : super._();
//
//   @override
//   final Object error;
//
//   @override
//   bool get hasReachedMax => false;
//
//   @override
//   bool get isInitial => false;
//
//   @override
//   bool get isLoading => false;
//
//   @override
//   final StackTrace stackTrace;
//
//   @override
//   final List<StateT> values;
// }
