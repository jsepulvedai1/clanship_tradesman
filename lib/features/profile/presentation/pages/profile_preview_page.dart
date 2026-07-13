import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';

class ProfilePreviewPage extends StatefulWidget {
  final UserEntity user;

  const ProfilePreviewPage({super.key, required this.user});

  @override
  State<ProfilePreviewPage> createState() => _ProfilePreviewPageState();
}

class _ProfilePreviewPageState extends State<ProfilePreviewPage> {
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<String> images = [
      if (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty)
        widget.user.profileImageUrl!,
      ...widget.user.portfolioPhotos.map((p) => p.imageUrl),
    ].isEmpty
        ? ['']
        : [
            if (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty)
              widget.user.profileImageUrl!,
            ...widget.user.portfolioPhotos.map((p) => p.imageUrl),
          ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Carousel (No SafeArea at top to start at the very top of screen)
                SafeArea(
                  top: true,
                  bottom: false,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                        child: SizedBox(
                          height: size.height * 0.45,
                          width: double.infinity,
                          child: images.first.isEmpty
                              ? Container(
                                  color: theme.colorScheme.surface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : PageView.builder(
                                  controller: _pageController,
                                  itemCount: images.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final url = images[index];
                                    final isNetwork = url.startsWith('http://') || url.startsWith('https://');

                                    return Stack(
                                      children: [
                                        isNetwork
                                            ? Image.network(
                                                url,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                              )
                                            : Image.file(
                                                File(url),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                              ),
                                        ClipRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                                            child: Container(
                                              color: Colors.black.withOpacity(0.15),
                                            ),
                                          ),
                                        ),
                                        isNetwork
                                            ? Image.network(
                                                url,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: theme.colorScheme.surface,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error_outline_rounded,
                                                        color: Colors.redAccent,
                                                        size: 40,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Image.file(
                                                File(url),
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: theme.colorScheme.surface,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error_outline_rounded,
                                                        color: Colors.redAccent,
                                                        size: 40,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                      // Carousel Indicators
                      if (images.length > 1)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: images.asMap().entries.map((entry) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(
                                    _currentImageIndex == entry.key ? 0.9 : 0.4,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Rating Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.user.firstName} ${widget.user.lastName}'.trim(),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildRatingStars(widget.user.rating),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.user.rating.toInt()} (8 opiniones)',
                            style: const TextStyle(
                              color: AppColors.primaryAzure,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Distance Row
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primaryAzure,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '1.21 km',
                            style: TextStyle(
                              color: AppColors.primaryAzure,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Biography / Description
                      Text(
                        widget.user.biography.isNotEmpty
                            ? widget.user.biography
                            : 'El profesional no ha escrito una biografía todavía.',
                        textAlign: TextAlign.justify,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Encuéntrame en: Social Row and Documents Button
                      const Text(
                        'Encuéntrame en:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSocialIcon(
                            FontAwesomeIcons.tiktok,
                            theme.colorScheme.onSurface,
                            widget.user.tiktokUrl,
                          ),
                          const SizedBox(width: 16),
                          _buildSocialIcon(
                            FontAwesomeIcons.facebook,
                            const Color(0xFF1877F2),
                            widget.user.facebookUrl,
                          ),
                          const SizedBox(width: 16),
                          _buildSocialIcon(
                            FontAwesomeIcons.instagram,
                            const Color(0xFFE4405F),
                            widget.user.instagramUrl,
                          ),
                          const Spacer(),
                          // Documents Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  color: AppColors.primaryAzure,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Documentos',
                                  style: TextStyle(
                                    color: AppColors.primaryAzure,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Contact Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {}, // Dummy action for preview
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAzure,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Ir al chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.3),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Sticky Preview Badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'VISTA PREVIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          size: 20,
          color: index < rating.floor() ? Colors.amber : themeDividerColor(context),
        );
      }),
    );
  }

  Color themeDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  Widget _buildSocialIcon(IconData icon, Color color, String? urlString) {
    final bool hasUrl = urlString != null && urlString.trim().isNotEmpty;
    return Opacity(
      opacity: hasUrl ? 1.0 : 0.3,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasUrl ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: FaIcon(
          icon,
          color: hasUrl ? color : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
