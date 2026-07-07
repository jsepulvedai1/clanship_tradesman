import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton_box.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 40, left: 20, right: 20),
      children: [
        // StatsBanner Skeleton
        const Center(
          child: SkeletonBox(
            width: double.infinity,
            height: 80,
            borderRadius: 20,
          ),
        ),
        const SizedBox(height: 25),
        
        // StatsGrid Skeleton
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: List.generate(4, (index) => const SkeletonBox(borderRadius: 16)),
        ),
        const SizedBox(height: 25),
        
        // AvailabilityWidget Skeleton
        const SkeletonBox(
          width: double.infinity,
          height: 70,
          borderRadius: 20,
        ),
        const SizedBox(height: 25),
        
        // RecentRequestsWidget Skeleton title
        const SkeletonBox(width: 150, height: 24),
        const SizedBox(height: 15),
        
        // RecentRequests items
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonBox(
            width: double.infinity,
            height: 100,
            borderRadius: 20,
          ),
        )),
      ],
    );
  }
}
