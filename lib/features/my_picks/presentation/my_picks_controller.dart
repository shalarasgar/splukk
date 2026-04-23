import 'package:get/get.dart';

import 'package:splukk/features/auth/presentation/auth_bloc.dart';
import '../domain/entities/my_pick_item.dart';
import '../domain/usecases/get_my_picks_usecase.dart';

class MyPicksController extends GetxController {
  MyPicksController({
    required this.getMyPicksUseCase,
    required this.authBloc,
  });

  final GetMyPicksUseCase getMyPicksUseCase;
  final AuthBloc authBloc;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final myPicks = <MyPickItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyPicks();
  }

  Future<void> loadMyPicks() async {
    final userUid = authBloc.state.profile?.uid;
    if (userUid == null) {
      errorMessage.value = 'Lütfen giriş yapın.';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      final items = await getMyPicksUseCase(userUid);
      myPicks.value = items;
    } catch (e) {
      errorMessage.value = 'Hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
