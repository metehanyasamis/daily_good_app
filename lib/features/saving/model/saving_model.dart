import 'package:daily_good/features/saving/model/package_saving_model.dart';

import 'carbon_saving_model.dart';
import 'money_saving_model.dart';

class SavingModel {
  final PackageSaving package;
  final MoneySaving money;
  final CarbonSaving carbon;

  const SavingModel({
    this.package = const PackageSaving(),
    this.money = const MoneySaving(),
    this.carbon = const CarbonSaving(),
  });

  // 🔥 Kısa getter’lar
  int get packagesSaved => package.totalPackages;
  double get moneySaved => money.totalSavedMoney;
  double get carbonSavedKg => carbon.totalCarbonKg;

  SavingModel copyWith({
    PackageSaving? package,
    MoneySaving? money,
    CarbonSaving? carbon,
  }) {
    return SavingModel(
      package: package ?? this.package,
      money: money ?? this.money,
      carbon: carbon ?? this.carbon,
    );
  }

  // 🔧 JSON destekleri
  factory SavingModel.fromJson(Map<String, dynamic> json) {
    return SavingModel(
      package: PackageSaving.fromJson(json['package']),
      money: MoneySaving.fromJson(json['money']),
      carbon: CarbonSaving.fromJson(json['carbon']),
    );
  }

  Map<String, dynamic> toJson() => {
    'package': package.toJson(),
    'money': money.toJson(),
    'carbon': carbon.toJson(),
  };
}
