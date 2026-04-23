import "package:flutter/material.dart";
import "package:shimmer/shimmer.dart";

class FintechShimmer extends StatelessWidget {
  const FintechShimmer({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.radius = 16,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE3EBF8),
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE3EBF8),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
