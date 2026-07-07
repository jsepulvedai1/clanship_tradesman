import 'package:flutter/material.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';

class PortfolioGallery extends StatelessWidget {
  final List<PortfolioPhotoEntity> portfolioPhotos;
  final VoidCallback? onAddTap;
  final Function(String photoId)? onDeleteTap;

  const PortfolioGallery({
    super.key,
    required this.portfolioPhotos,
    this.onAddTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.pureWhite.withAlpha(20) : AppColors.trueBlack.withAlpha(20),
            width: 0.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profilePhotosVideos,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8, // Basado en el diseño que muestra 8 espacios
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                if (index < portfolioPhotos.length) {
                  return _PortfolioItem(
                    photo: portfolioPhotos[index],
                    onDelete: onDeleteTap,
                  );
                }
                return _AddPortfolioItem(onTap: onAddTap);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioItem extends StatelessWidget {
  final PortfolioPhotoEntity photo;
  final Function(String photoId)? onDelete;

  const _PortfolioItem({
    required this.photo,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(photo.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onDelete?.call(photo.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha(150),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPortfolioItem extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddPortfolioItem({this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(5) : AppColors.lightGrey.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withAlpha(30),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_box_outlined,
                color: (isDark ? Colors.white : Colors.black).withAlpha(100),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
