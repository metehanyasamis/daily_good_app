// lib/features/cart/data/models/checkout_contracts_model.dart

class CheckoutContractsModel {
  final String mesafeliSatisSozlesmesi;
  final String onBilgilendirmeFormu;

  CheckoutContractsModel({
    required this.mesafeliSatisSozlesmesi,
    required this.onBilgilendirmeFormu,
  });

  factory CheckoutContractsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CheckoutContractsModel(
      mesafeliSatisSozlesmesi: data['mesafeli_satis_sozlesmesi'] ?? "",
      onBilgilendirmeFormu: data['on_bilgilendirme_formu'] ?? "",
    );
  }
}