class PackageSaving {
  final int totalPackages;

  const PackageSaving({this.totalPackages = 0});

  PackageSaving copyWith({int? totalPackages}) {
    return PackageSaving(
      totalPackages: totalPackages ?? this.totalPackages,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalPackages': totalPackages,
  };

  factory PackageSaving.fromJson(Map<String, dynamic> json) {
    return PackageSaving(
      totalPackages: json['totalPackages'] ?? 0,
    );
  }
}
