class AppVersionModel {
  final String? currentVersion;
  final String? minimumVersion;
  final bool forceUpdate;
  final bool updateAvailable;
  final String? updateMessage;
  final String? updateUrl;
  final bool maintenanceMode;

  AppVersionModel({
    this.currentVersion,
    this.minimumVersion,
    this.forceUpdate = false,
    this.updateAvailable = false,
    this.updateMessage,
    this.updateUrl,
    this.maintenanceMode = false,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AppVersionModel(
      currentVersion: data['current_version'],
      minimumVersion: data['minimum_version'],
      forceUpdate: data['force_update'] ?? false,
      updateAvailable: data['update_available'] ?? false,
      updateMessage: data['update_message'],
      updateUrl: data['update_url'],
      maintenanceMode: data['maintenance_mode'] ?? false,
    );
  }
}