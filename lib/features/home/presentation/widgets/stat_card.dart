import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StatCard extends StatefulWidget {
  final String value;
  final String label;
  final Color valueColor;
  final VoidCallback? onTap;
  final int highlightCount;
  final String svgIconPath;
  final Color iconColor;
  final bool showChevron;
  final Color chevronColor;
  final Color? backgroundColor;
  final String? bgImageUrl;
  final Color? labelColor;
  final double? imageOpacity;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    this.onTap,
    this.highlightCount = 0,
    this.svgIconPath = 'assets/icon/icons_ F28C28/document-add.svg',
    required this.iconColor,
    this.showChevron = false,
    required this.chevronColor,
    this.backgroundColor,
    this.bgImageUrl,
    this.labelColor,
    this.imageOpacity,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.highlightCount > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightCount > 0 && oldWidget.highlightCount == 0) {
      _controller.repeat(reverse: true);
    } else if (widget.highlightCount == 0 && oldWidget.highlightCount > 0) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasHighlight = widget.highlightCount > 0;

    Color cardColor = widget.backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    if (hasHighlight) {
      // Change background color when highlighted
      cardColor = isDark
          ? const Color(0xFF0D2B45).withValues(alpha: 0.6)
          : const Color(0xFFE0F2FE); // Light blue
    }

    final bool isBackgroundDark = isDark || (widget.backgroundColor != null && widget.backgroundColor!.computeLuminance() < 0.45);
    final Color defaultLabelColor = isBackgroundDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF2E3135);
    final Color effectiveLabelColor = widget.labelColor ?? defaultLabelColor;
    final Color effectiveValueColor = (isBackgroundDark && widget.valueColor == const Color(0xFF2E3135))
        ? Colors.white
        : widget.valueColor;

    Widget cardContent = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasHighlight
                ? const Color(0xFF3B82F6) // Bright blue border for highlight
                : (widget.backgroundColor != null
                    ? widget.backgroundColor!.withValues(alpha: 0.4)
                    : const Color(0xFFE2E8F0)),
            width: hasHighlight ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasHighlight 
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: hasHighlight ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.bgImageUrl != null && widget.bgImageUrl!.isNotEmpty) ...[
              Positioned.fill(
                child: Opacity(
                  opacity: (widget.imageOpacity ?? 0.25).clamp(0.0, 1.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.bgImageUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 150),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: isBackgroundDark ? 0.2 : 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      widget.svgIconPath,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        isBackgroundDark && widget.iconColor == const Color(0xFF2E3135)
                            ? Colors.white
                            : widget.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Texts
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: effectiveValueColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label.replaceAll('\n', ' '), 
                    style: TextStyle(
                      color: effectiveLabelColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasHighlight)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${widget.highlightCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (hasHighlight) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value,
            child: child,
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
