import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class DoctorCardSkeleton extends StatelessWidget {
  const DoctorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 60, height: 60, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 14),
                const SizedBox(height: 6),
                const SkeletonBox(width: 90, height: 11),
                const SizedBox(height: 10),
                const SkeletonBox(width: 120, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              SkeletonBox(width: 40, height: 14),
              SizedBox(height: 6),
              SkeletonBox(width: 30, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}

class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 100, height: 12),
          SizedBox(height: 8),
          SkeletonBox(height: 16),
          SizedBox(height: 6),
          SkeletonBox(width: 160, height: 12),
          SizedBox(height: 10),
          SkeletonBox(width: 80, height: 24, radius: 12),
        ],
      ),
    );
  }
}

class PatientRecordSkeleton extends StatelessWidget {
  const PatientRecordSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 80, height: 11),
          SizedBox(height: 6),
          SkeletonBox(width: 180, height: 15),
          SizedBox(height: 10),
          SkeletonBox(width: 120, height: 11),
        ],
      ),
    );
  }
}

Widget buildSkeletonList({
  required Widget Function() itemBuilder,
  int count = 5,
}) {
  return ListView.separated(
    padding: const EdgeInsets.all(20),
    itemCount: count,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, __) => itemBuilder(),
  );
}
