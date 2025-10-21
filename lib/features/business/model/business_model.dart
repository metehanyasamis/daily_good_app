import '../../product/presentation/widgets/product_card.dart';

class BusinessModel {
  final String name;
  final String address;
  final String image;
  final double rating;
  final double distance;
  final String workingHours;
  final List<ProductModel> products;

  BusinessModel({
    required this.name,
    required this.address,
    required this.image,
    required this.rating,
    required this.distance,
    required this.workingHours,
    required this.products,
  });
}