import 'package:equatable/equatable.dart';

class AddressState extends Equatable {
  final String title;
  final double lat;
  final double lng;
  final bool isSelected;

  const AddressState({
    this.title = 'Kadıköy, İstanbul',
    this.lat = 40.9917,
    this.lng = 29.0275,
    this.isSelected = false,
  });

  AddressState copyWith({
    String? title,
    double? lat,
    double? lng,
    bool? isSelected,
  }) {
    return AddressState(
      title: title ?? this.title,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [title, lat, lng, isSelected];
}


