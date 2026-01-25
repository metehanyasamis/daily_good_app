import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../account/domain/providers/user_notifier.dart';
import '../data/saving_repository.dart';
import '../model/saving_model.dart';


/// Ana Provider → SavingModel tutar
final savingProvider =
StateNotifierProvider<SavingNotifier, SavingModel>((ref) {
  final repo = SavingRepository(baseUrl: "https://api.myapp.com");
  final user = ref.watch(userNotifierProvider).user;

  return SavingNotifier(
    repository: repo,
    userId: user?.id ?? "guest",
  )..init();
});



class SavingNotifier extends StateNotifier<SavingModel> {
  final SavingRepository repository;
  final String userId;

  SavingNotifier({
    required this.repository,
    required this.userId,
  }) : super(const SavingModel());

  /// İlk açılış → local + remote yükleme
  Future<void> init() async {
    // 1) Local veriyi yükle
    final local = await repository.loadLocal();
    if (local != null) {
      state = local;
    }

    // 2) Remote varsa override et
    final remote = await repository.loadRemote(userId);
    if (remote != null) {
      state = remote;
      await repository.saveLocal(remote);
    }
  }


  // --------------------------------------------
  //              🔥 UPDATE METHODS 🔥
  // --------------------------------------------

  /// 1) Paket sayısı +1
  void addPackage() {
    state = state.copyWith(
      package: state.package.copyWith(
        totalPackages: state.package.totalPackages + 1,
      ),
    );

    repository.saveLocal(state);
    repository.saveRemote(state, userId);
  }

  /// 2) Para tasarrufu ekle
  void addMoney(double amount) {
    state = state.copyWith(
      money: state.money.copyWith(
        totalSavedMoney: state.money.totalSavedMoney + amount,
      ),
    );

    repository.saveLocal(state);
    repository.saveRemote(state, userId);
  }

  /// 3) CO₂ ekle
  void addCarbon(double kg) {
    state = state.copyWith(
      carbon: state.carbon.copyWith(
        totalCarbonKg: state.carbon.totalCarbonKg + kg,
      ),
    );

    repository.saveLocal(state);
    repository.saveRemote(state, userId);
  }

  /// 4) Komple reset
  Future<void> resetAll() async {
    state = const SavingModel();
    await repository.resetAll(userId);
  }
}
