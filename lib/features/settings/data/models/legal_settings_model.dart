class LegalSettingsModel {
  final Map<String, ContractModel> contracts;
  final String importantInfo;

  LegalSettingsModel({
    required this.contracts,
    required this.importantInfo,
  });

  factory LegalSettingsModel.fromJson(Map<String, dynamic> json) {
    // API dökümanına göre root "data" objesini alıyoruz
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // Contracts kısmını güvenli bir şekilde map'e dönüştürüyoruz
    final contractsJson = data['contracts'] as Map<String, dynamic>? ?? {};

    final Map<String, ContractModel> parsedContracts = {};
    contractsJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        parsedContracts[key] = ContractModel.fromJson(value);
      }
    });

    return LegalSettingsModel(
      contracts: parsedContracts,
      // API dökümanında "important_info" olarak geçiyor
      importantInfo: data['important_info'] ?? data['importantInfo'] ?? "",
    );
  }
}

class ContractModel {
  final String url;
  final bool exists;

  ContractModel({required this.url, required this.exists});

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      url: json['url'] ?? "",
      exists: json['exists'] ?? false,
    );
  }
}