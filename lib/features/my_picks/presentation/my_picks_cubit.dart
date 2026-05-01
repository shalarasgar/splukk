import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splukk/features/auth/presentation/auth_bloc.dart';
import '../domain/usecases/get_my_picks_usecase.dart';
import 'my_picks_state.dart';

class MyPicksCubit extends Cubit<MyPicksState> {
  final GetMyPicksUseCase getMyPicksUseCase;

  MyPicksCubit({
    required this.getMyPicksUseCase,
  }) : super(const MyPicksState());

  Future<void> loadMyPicks(String? userUid) async {
    if (userUid == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Lütfen giriş yapın.',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final items = await getMyPicksUseCase(userUid);
      emit(state.copyWith(
        isLoading: false,
        items: items,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Hata oluştu: $e',
      ));
    }
  }
}
