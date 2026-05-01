import 'package:equatable/equatable.dart';
import '../domain/entities/my_pick_item.dart';

class MyPicksState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<MyPickItem> items;

  const MyPicksState({
    this.isLoading = true,
    this.errorMessage,
    this.items = const [],
  });

  MyPicksState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MyPickItem>? items,
    bool clearError = false,
  }) {
    return MyPicksState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, items];
}
