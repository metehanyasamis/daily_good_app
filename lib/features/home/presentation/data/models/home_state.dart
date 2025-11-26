import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String selectedAddress;
  final int selectedCategoryIndex;
  final bool hasActiveOrder;

  const HomeState({
    required this.selectedAddress,
    required this.selectedCategoryIndex,
    required this.hasActiveOrder,
  });

  HomeState copyWith({
    String? selectedAddress,
    int? selectedCategoryIndex,
    bool? hasActiveOrder,
  }) {
    return HomeState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      hasActiveOrder: hasActiveOrder ?? this.hasActiveOrder,
    );
  }

  @override
  List<Object?> get props => [
    selectedAddress,
    selectedCategoryIndex,
    hasActiveOrder,
  ];
}

