class CarbonSaving {
  final double totalCarbonKg;

  const CarbonSaving({this.totalCarbonKg = 0.0});

  CarbonSaving copyWith({double? totalCarbonKg}) {
    return CarbonSaving(
      totalCarbonKg: totalCarbonKg ?? this.totalCarbonKg,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCarbonKg': totalCarbonKg,
  };

  factory CarbonSaving.fromJson(Map<String, dynamic> json) {
    return CarbonSaving(
      totalCarbonKg: (json['totalCarbonKg'] ?? 0.0).toDouble(),
    );
  }
}
