import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BusResultShimmer extends StatelessWidget {
  const BusResultShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    color: Colors.white,
                  ),
                  Container(
                    width: 60,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.white,
                  ),
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 40,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SortingOptionsShimmer extends StatelessWidget {
  const SortingOptionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              5,
                  (index) => Container(
                width: 60,
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}