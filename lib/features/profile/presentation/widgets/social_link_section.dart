import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';

class SocialLinkSection extends StatelessWidget {
  final String facebookUrl;
  final String instagramUrl;
  final String tiktokUrl;
  final Function(String facebook, String instagram, String tiktok)? onEditLinks;

  const SocialLinkSection({
    super.key,
    required this.facebookUrl,
    required this.instagramUrl,
    required this.tiktokUrl,
    this.onEditLinks,
  });

  void _showEditDialog(BuildContext context) {
    final fbController = TextEditingController(text: facebookUrl);
    final igController = TextEditingController(text: instagramUrl);
    final ttController = TextEditingController(text: tiktokUrl);

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          title: const Text(
            'Vincular Redes Sociales',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fbController,
                  decoration: const InputDecoration(
                    labelText: 'Facebook URL',
                    prefixIcon: Icon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 20),
                    hintText: 'https://facebook.com/usuario',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: igController,
                  decoration: const InputDecoration(
                    labelText: 'Instagram URL',
                    prefixIcon: Icon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F), size: 20),
                    hintText: 'https://instagram.com/usuario',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ttController,
                  decoration: const InputDecoration(
                    labelText: 'TikTok URL',
                    prefixIcon: Icon(FontAwesomeIcons.tiktok, size: 20),
                    hintText: 'https://tiktok.com/@usuario',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                onEditLinks?.call(
                  fbController.text.trim(),
                  igController.text.trim(),
                  ttController.text.trim(),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _handleIconTap(BuildContext context, String url, String name) {
    if (url.isNotEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enlace a $name: $url'),
          action: SnackBarAction(
            label: 'Editar',
            textColor: Colors.white,
            onPressed: () => _showEditDialog(context),
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    } else {
      _showEditDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.profileLinkSocial,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: AppColors.primaryBlue),
                onPressed: () => _showEditDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialIcon(
                icon: FontAwesomeIcons.facebook,
                color: const Color(0xFF1877F2),
                opacity: facebookUrl.isNotEmpty ? 1.0 : 0.3,
                onTap: () => _handleIconTap(context, facebookUrl, 'Facebook'),
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.tiktok,
                color: isDark ? Colors.white : Colors.black,
                opacity: tiktokUrl.isNotEmpty ? 1.0 : 0.3,
                onTap: () => _handleIconTap(context, tiktokUrl, 'TikTok'),
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.instagram,
                color: const Color(0xFFE4405F),
                isGradient: instagramUrl.isNotEmpty,
                opacity: instagramUrl.isNotEmpty ? 1.0 : 0.3,
                onTap: () => _handleIconTap(context, instagramUrl, 'Instagram'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isGradient;
  final double opacity;

  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isGradient = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isGradient
                ? const RadialGradient(
                    colors: [
                      Color(0xFFF58529),
                      Color(0xFFFEDA77),
                      Color(0xFFDD2A7B),
                      Color(0xFF8134AF),
                      Color(0xFF515BD4),
                    ],
                    center: Alignment.bottomLeft,
                    radius: 1.2,
                  )
                : null,
            color: isGradient ? null : (color == Colors.white || color == Colors.black ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]) : color),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: color == Colors.white || color == Colors.black ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
