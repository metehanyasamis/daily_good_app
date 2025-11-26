class MoneySaving {
  final double totalSavedMoney;

  const MoneySaving({this.totalSavedMoney = 0.0});

  MoneySaving copyWith({double? totalSavedMoney}) {
    return MoneySaving(
      totalSavedMoney: totalSavedMoney ?? this.totalSavedMoney,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSavedMoney': totalSavedMoney,
  };

  factory MoneySaving.fromJson(Map<String, dynamic> json) {
    return MoneySaving(
      totalSavedMoney: (json['totalSavedMoney'] ?? 0.0).toDouble(),
    );
  }
}
