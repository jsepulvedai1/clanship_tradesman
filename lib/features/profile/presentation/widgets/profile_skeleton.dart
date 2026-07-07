import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton_box.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ProfileAppBar Skeleton (Unified style)
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SkeletonBox(width: 40, height: 40, borderRadius: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SkeletonBox(width: 80, height: 12),
                      SizedBox(height: 4),
                      SkeletonBox(width: 120, height: 16),
                    ],
                  ),
                ],
              ),
              Row(
                children: const [
                  SkeletonBox(width: 32, height: 32, borderRadius: 16),
                  SizedBox(width: 8),
                  SkeletonBox(width: 45, height: 45, borderRadius: 23),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // Who am I title
              const SkeletonBox(width: 150, height: 24),
              const SizedBox(height: 16),
              
              // SubscriptionBanner
              const SkeletonBox(width: double.infinity, height: 100, borderRadius: 16),
              const SizedBox(height: 24),
              
              // WorkingRadiusSection
              const SkeletonBox(width: double.infinity, height: 120, borderRadius: 16),
              const SizedBox(height: 24),
              
              // BioSection
              const SkeletonBox(width: 100, height: 20),
              const SizedBox(height: 12),
              const SkeletonBox(width: double.infinity, height: 80, borderRadius: 12),
              const SizedBox(height: 24),
              
              // PortfolioGallery
              const SkeletonBox(width: 120, height: 20),
              const SizedBox(height: 12),
              Row(
                children: List.generate(3, (index) => const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SkeletonBox(height: 100, borderRadius: 12),
                  ),
                )),
              ),
              const SizedBox(height: 20),
              
              // SocialLinkSection Skeleton
              const SkeletonBox(width: double.infinity, height: 120, borderRadius: 20),
              const SizedBox(height: 12),
              
              // ActionButtons Skeleton
              const SkeletonBox(width: double.infinity, height: 60, borderRadius: 20),
              const SizedBox(height: 8),
              const SkeletonBox(width: double.infinity, height: 60, borderRadius: 20),
              const SizedBox(height: 20),
              
              // ServicesHeaderBanner
              const SkeletonBox(width: double.infinity, height: 60, borderRadius: 12),
              const SizedBox(height: 16),
              
              // ServiceTagsSection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(4, (index) => const SkeletonBox(width: 80, height: 32, borderRadius: 20)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
