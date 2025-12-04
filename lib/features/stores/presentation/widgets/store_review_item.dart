// lib/features/stores/presentation/widgets/store_review_item.dart

import 'package:flutter/material.dart';
import '../../../review/domain/models/review_model.dart';

class StoreReviewItem extends StatelessWidget {
  final ReviewModel review;

  const StoreReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username + Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.user,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                  Text(review.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            review.comment,
            style: const TextStyle(color: Colors.black87),
          ),

          const SizedBox(height: 6),

          Text(
            "${review.date.day}.${review.date.month}.${review.date.year}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
