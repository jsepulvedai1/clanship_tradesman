import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/settings/presentation/pages/my_plan_page.dart';

class TradesmanSubtagsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> specialties;
  final Set<String> initialSelectedSpecialtyIds;
  final Set<String> initialSelectedTagIds;
  final Set<String> initialSelectedSubtagIds;
  final int maxSpecialtiesPerTradesman;
  final Function(Set<String> selectedSpecialtyIds, Set<String> selectedTagIds, Set<String> selectedSubtagIds) onSave;

  TradesmanSubtagsSheet({
    super.key,
    required this.specialties,
    required this.initialSelectedSpecialtyIds,
    required this.initialSelectedTagIds,
    required this.initialSelectedSubtagIds,
    int? maxSpecialtiesPerTradesman,
    required this.onSave,
  }) : maxSpecialtiesPerTradesman = maxSpecialtiesPerTradesman ?? AuthRemoteDataSourceImpl.maxSpecialtiesLimit;

  @override
  State<TradesmanSubtagsSheet> createState() => _TradesmanSubtagsSheetState();
}

class _TradesmanSubtagsSheetState extends State<TradesmanSubtagsSheet> {
  // Navigation State
  // 0: Categories (Level 1)
  // 1: Subcategories (Level 2)
  // 2: Services (Level 3)
  int _currentView = 0;

  // Active parent nodes
  Map<String, dynamic>? _activeSpecialty;
  Map<String, dynamic>? _activeTag;

  // Selected IDs (Strings to match tradesman app standard)
  late Set<String> _selectedSpecialtyIds;
  late Set<String> _selectedTagIds;
  late Set<String> _selectedSubtagIds;

  @override
  void initState() {
    super.initState();
    _selectedSpecialtyIds = Set<String>.from(widget.initialSelectedSpecialtyIds);
    _selectedTagIds = Set<String>.from(widget.initialSelectedTagIds);
    _selectedSubtagIds = Set<String>.from(widget.initialSelectedSubtagIds);

    // Backward compatibility for legacy tags (no subtags selected)
    for (final spec in widget.specialties) {
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final tagId = tag['id']?.toString() ?? '';
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        if (subtags.isNotEmpty && _selectedTagIds.contains(tagId)) {
          bool hasAny = subtags.any((s) => _selectedSubtagIds.contains(s['id']?.toString() ?? ''));
          if (!hasAny) {
            for (final s in subtags) {
              _selectedSubtagIds.add(s['id']?.toString() ?? '');
            }
          }
        }
      }
    }

    _syncParentIds();
  }

  int get _maxLimit => widget.maxSpecialtiesPerTradesman;

  // Extract all leaf service items (subtags or standalone tags) for a specialty
  List<Map<String, String>> _getSpecialtyLeafItems(Map<String, dynamic> specialty) {
    final List<Map<String, String>> items = [];
    final specId = specialty['id']?.toString() ?? '';
    final tags = specialty['tags'] as List<dynamic>? ?? [];
    for (final tag in tags) {
      final tagId = tag['id']?.toString() ?? '';
      final subtags = tag['subtags'] as List<dynamic>? ?? [];
      if (subtags.isEmpty) {
        if (tagId.isNotEmpty) {
          items.add({'type': 'tag', 'id': tagId, 'specialtyId': specId});
        }
      } else {
        for (final subtag in subtags) {
          final subtagId = subtag['id']?.toString() ?? '';
          if (subtagId.isNotEmpty) {
            items.add({'type': 'subtag', 'id': subtagId, 'tagId': tagId, 'specialtyId': specId});
          }
        }
      }
    }
    return items;
  }

  // Extract all leaf service items for a tag
  List<Map<String, String>> _getTagLeafItems(Map<String, dynamic> tag, String specId) {
    final List<Map<String, String>> items = [];
    final tagId = tag['id']?.toString() ?? '';
    final subtags = tag['subtags'] as List<dynamic>? ?? [];
    if (subtags.isEmpty) {
      if (tagId.isNotEmpty) {
        items.add({'type': 'tag', 'id': tagId, 'specialtyId': specId});
      }
    } else {
      for (final subtag in subtags) {
        final subtagId = subtag['id']?.toString() ?? '';
        if (subtagId.isNotEmpty) {
          items.add({'type': 'subtag', 'id': subtagId, 'tagId': tagId, 'specialtyId': specId});
        }
      }
    }
    return items;
  }

  // Count of selected leaf services (subtags + standalone tags)
  int get _totalCount {
    int count = _selectedSubtagIds.length;
    for (final spec in widget.specialties) {
      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final tagId = tag['id']?.toString() ?? '';
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        if (subtags.isEmpty && _selectedTagIds.contains(tagId)) {
          count++;
        }
      }
    }
    return count;
  }

  // Check if a specialty is fully selected
  bool _isSpecialtyFullySelected(Map<String, dynamic> specialty) {
    final leafItems = _getSpecialtyLeafItems(specialty);
    if (leafItems.isEmpty) return false;
    for (final item in leafItems) {
      if (item['type'] == 'subtag') {
        if (!_selectedSubtagIds.contains(item['id'])) return false;
      } else {
        if (!_selectedTagIds.contains(item['id'])) return false;
      }
    }
    return true;
  }

  // Check if a tag is fully selected
  bool _isTagFullySelected(Map<String, dynamic> tag, String specId) {
    final leafItems = _getTagLeafItems(tag, specId);
    if (leafItems.isEmpty) return false;
    for (final item in leafItems) {
      if (item['type'] == 'subtag') {
        if (!_selectedSubtagIds.contains(item['id'])) return false;
      } else {
        if (!_selectedTagIds.contains(item['id'])) return false;
      }
    }
    return true;
  }

  // Synchronize parent tag and specialty IDs based on selected leaf items
  void _syncParentIds() {
    for (final spec in widget.specialties) {
      final specId = spec['id']?.toString() ?? '';
      bool specHasAny = false;

      final tags = spec['tags'] as List<dynamic>? ?? [];
      for (final tag in tags) {
        final tagId = tag['id']?.toString() ?? '';
        final subtags = tag['subtags'] as List<dynamic>? ?? [];

        if (subtags.isEmpty) {
          if (_selectedTagIds.contains(tagId)) {
            specHasAny = true;
          }
        } else {
          bool tagHasAny = false;
          for (final subtag in subtags) {
            final subtagId = subtag['id']?.toString() ?? '';
            if (_selectedSubtagIds.contains(subtagId)) {
              tagHasAny = true;
              specHasAny = true;
            }
          }
          if (tagHasAny) {
            _selectedTagIds.add(tagId);
          } else {
            _selectedTagIds.remove(tagId);
          }
        }
      }

      if (specHasAny) {
        _selectedSpecialtyIds.add(specId);
      } else {
        _selectedSpecialtyIds.remove(specId);
      }
    }
  }

  // Toggle selection for an entire specialty
  void _toggleSpecialty(Map<String, dynamic> specialty) {
    final leafItems = _getSpecialtyLeafItems(specialty);
    if (leafItems.isEmpty) return;

    final isFullySelected = _isSpecialtyFullySelected(specialty);

    setState(() {
      if (isFullySelected) {
        for (final item in leafItems) {
          if (item['type'] == 'subtag') {
            _selectedSubtagIds.remove(item['id']);
          } else {
            _selectedTagIds.remove(item['id']);
          }
        }
        _syncParentIds();
      } else {
        final unselectedItems = leafItems.where((item) {
          if (item['type'] == 'subtag') {
            return !_selectedSubtagIds.contains(item['id']);
          } else {
            return !_selectedTagIds.contains(item['id']);
          }
        }).toList();

        if (_totalCount + unselectedItems.length > _maxLimit) {
          _showLimitWarning();
          return;
        }

        for (final item in unselectedItems) {
          if (item['type'] == 'subtag') {
            _selectedSubtagIds.add(item['id']!);
          } else {
            _selectedTagIds.add(item['id']!);
          }
        }
        _syncParentIds();
      }
    });
  }

  // Toggle selection for an entire tag
  void _toggleTag(Map<String, dynamic> tag, String specId) {
    final leafItems = _getTagLeafItems(tag, specId);
    if (leafItems.isEmpty) return;

    final isFullySelected = _isTagFullySelected(tag, specId);

    setState(() {
      if (isFullySelected) {
        for (final item in leafItems) {
          if (item['type'] == 'subtag') {
            _selectedSubtagIds.remove(item['id']);
          } else {
            _selectedTagIds.remove(item['id']);
          }
        }
        _syncParentIds();
      } else {
        final unselectedItems = leafItems.where((item) {
          if (item['type'] == 'subtag') {
            return !_selectedSubtagIds.contains(item['id']);
          } else {
            return !_selectedTagIds.contains(item['id']);
          }
        }).toList();

        if (_totalCount + unselectedItems.length > _maxLimit) {
          _showLimitWarning();
          return;
        }

        for (final item in unselectedItems) {
          if (item['type'] == 'subtag') {
            _selectedSubtagIds.add(item['id']!);
          } else {
            _selectedTagIds.add(item['id']!);
          }
        }
        _syncParentIds();
      }
    });
  }

  // Toggle selection for an individual subtag
  void _toggleSubtag(String subtagId) {
    setState(() {
      if (_selectedSubtagIds.contains(subtagId)) {
        _selectedSubtagIds.remove(subtagId);
        _syncParentIds();
      } else {
        if (_totalCount >= _maxLimit) {
          _showLimitWarning();
          return;
        }
        _selectedSubtagIds.add(subtagId);
        _syncParentIds();
      }
    });
  }

  // Count active selections for a Specialty
  int _getSpecialtySelectedCount(Map<String, dynamic> specialty) {
    int count = 0;
    final tags = specialty['tags'] as List<dynamic>? ?? [];
    for (final tag in tags) {
      final tagId = tag['id']?.toString() ?? '';
      final subtags = tag['subtags'] as List<dynamic>? ?? [];
      if (subtags.isEmpty) {
        if (_selectedTagIds.contains(tagId)) {
          count++;
        }
      } else {
        for (final subtag in subtags) {
          final subtagId = subtag['id']?.toString() ?? '';
          if (_selectedSubtagIds.contains(subtagId)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  // Count active selections for a Tag
  int _getTagSelectedCount(Map<String, dynamic> tag) {
    final tagId = tag['id']?.toString() ?? '';
    final subtags = tag['subtags'] as List<dynamic>? ?? [];
    if (subtags.isEmpty) {
      return _selectedTagIds.contains(tagId) ? 1 : 0;
    }
    int count = 0;
    for (final subtag in subtags) {
      final subtagId = subtag['id']?.toString() ?? '';
      if (_selectedSubtagIds.contains(subtagId)) {
        count++;
      }
    }
    return count;
  }

  // Icon mapping helper
  IconData _getSpecialtyIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('elec')) return Icons.bolt_rounded;
    if (n.contains('const') || n.contains('remod')) return Icons.home_rounded;
    if (n.contains('gas') || n.contains('agua') || n.contains('fit')) return Icons.plumbing_rounded;
    if (n.contains('pint')) return Icons.format_paint_rounded;
    if (n.contains('jard')) return Icons.local_florist_rounded;
    if (n.contains('limp')) return Icons.cleaning_services_rounded;
    if (n.contains('carp')) return Icons.handyman_rounded;
    if (n.contains('clim')) return Icons.ac_unit_rounded;
    return Icons.work_outline_rounded;
  }

  Color _parseHexColor(String? colorHex, {Color defaultColor = AppColors.primaryBlue}) {
    if (colorHex == null || colorHex.trim().isEmpty) return defaultColor;
    try {
      final hex = colorHex.trim().replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  Widget _buildSpecialtyIconWidget(String name, String? iconUrl, {String? colorHex, double size = 22}) {
    final fallbackIcon = Icon(
      _getSpecialtyIcon(name),
      color: _getSpecialtyIconColor(name, colorHex),
      size: size,
    );

    if (iconUrl != null && iconUrl.trim().isNotEmpty) {
      final cleanUrl = iconUrl.trim();
      final isSvg = cleanUrl.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => fallbackIcon,
        );
      } else {
        return Image.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => fallbackIcon,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return fallbackIcon;
          },
        );
      }
    }
    return fallbackIcon;
  }

  Color _getSpecialtyColor(String name, String? colorHex) {
    if (colorHex != null && colorHex.trim().isNotEmpty) {
      final base = _parseHexColor(colorHex);
      return base.withOpacity(0.12);
    }
    final n = name.toLowerCase();
    if (n.contains('elec')) return const Color(0xFFE2FBE9);
    if (n.contains('const') || n.contains('remod')) return const Color(0xFFE3F2FD);
    if (n.contains('gas') || n.contains('agua') || n.contains('fit')) return const Color(0xFFE0F7FA);
    if (n.contains('pint')) return const Color(0xFFF3E5F5);
    if (n.contains('jard')) return const Color(0xFFF1F8E9);
    if (n.contains('limp')) return const Color(0xFFFFF3E0);
    if (n.contains('carp')) return const Color(0xFFE0F2F1);
    if (n.contains('clim')) return const Color(0xFFECEFF1);
    return const Color(0xFFF5F5F5);
  }

  Color _getSpecialtyIconColor(String name, String? colorHex) {
    if (colorHex != null && colorHex.trim().isNotEmpty) {
      return _parseHexColor(colorHex);
    }
    final n = name.toLowerCase();
    if (n.contains('elec')) return const Color(0xFF0F973D);
    if (n.contains('const') || n.contains('remod')) return const Color(0xFF1565C0);
    if (n.contains('gas') || n.contains('agua') || n.contains('fit')) return const Color(0xFF00838F);
    if (n.contains('pint')) return const Color(0xFF6A1B9A);
    if (n.contains('jard')) return const Color(0xFF558B2F);
    if (n.contains('limp')) return const Color(0xFFEF6C00);
    if (n.contains('carp')) return const Color(0xFF00695C);
    if (n.contains('clim')) return const Color(0xFF37474F);
    return const Color(0xFF616161);
  }

  Widget _buildTagIconWidget(String name, String? iconUrl, {double size = 22}) {
    final fallbackIcon = Icon(
      _getTagIcon(name),
      color: AppColors.primaryBlue,
      size: size,
    );

    if (iconUrl != null && iconUrl.trim().isNotEmpty) {
      final cleanUrl = iconUrl.trim();
      final isSvg = cleanUrl.toLowerCase().endsWith('.svg');
      if (isSvg) {
        return SvgPicture.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => fallbackIcon,
        );
      } else {
        return Image.network(
          cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => fallbackIcon,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return fallbackIcon;
          },
        );
      }
    }
    return fallbackIcon;
  }

  IconData _getTagIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('instal')) return Icons.settings_suggest_rounded;
    if (n.contains('repara')) return Icons.build_rounded;
    if (n.contains('ilumin')) return Icons.lightbulb_outline_rounded;
    if (n.contains('certif')) return Icons.verified_rounded;
    if (n.contains('especial')) return Icons.star_rounded;
    if (n.contains('albañ')) return Icons.foundation_rounded;
    if (n.contains('termin')) return Icons.architecture_rounded;
    if (n.contains('techo') || n.contains('gotera')) return Icons.roofing_rounded;
    if (n.contains('piso')) return Icons.layers_rounded;
    if (n.contains('ventan')) return Icons.window_rounded;
    if (n.contains('cerraj')) return Icons.key_rounded;
    if (n.contains('hojal')) return Icons.hardware_rounded;
    if (n.contains('gasfit')) return Icons.plumbing_rounded;
    if (n.contains('calefon')) return Icons.local_fire_department_rounded;
    if (n.contains('redes')) return Icons.hub_rounded;
    if (n.contains('alcantar')) return Icons.water_damage_rounded;
    return Icons.handyman_rounded;
  }

  void _showLimitWarning() {
    final remaining = _maxLimit - _totalCount;
    final String message = remaining <= 0
        ? 'Has alcanzado el límite de $_maxLimit categorías/servicios de tu plan.'
        : 'Solo te quedan $remaining cupo(s) disponible(s).';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrange,
        action: SnackBarAction(
          label: 'Mejorar Plan',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPlanPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.trueBlack : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Render Navigated views
          if (_currentView == 0) ...[
            _buildHeader(theme, 'Seleccionar Trabajos', showClear: true),
            _buildInfoTip(theme),
            Expanded(child: _buildCategoriesView(theme)),
            _buildBottomActionBar(
              theme,
              onPressedSave: () {
                Navigator.pop(context);
                widget.onSave(_selectedSpecialtyIds, _selectedTagIds, _selectedSubtagIds);
              },
              onPressedCancel: () {
                Navigator.pop(context);
              },
              cancelText: 'Cancelar',
            ),
          ] else if (_currentView == 1) ...[
            _buildHeader(
              theme,
              _activeSpecialty!['name'] as String,
              onBack: () {
                setState(() {
                  _currentView = 0;
                  _activeSpecialty = null;
                });
              },
            ),
            _buildBreadcrumb(theme, 'Categoría', _activeSpecialty!['name'] as String),
            Expanded(child: _buildSubcategoriesView(theme)),
            _buildBottomActionBar(
              theme,
              onPressedSave: () {
                Navigator.pop(context);
                widget.onSave(_selectedSpecialtyIds, _selectedTagIds, _selectedSubtagIds);
              },
              onPressedCancel: () {
                setState(() {
                  _currentView = 0;
                  _activeSpecialty = null;
                });
              },
              cancelText: 'Volver',
            ),
          ] else if (_currentView == 2) ...[
            _buildHeader(
              theme,
              _activeTag!['name'] as String,
              onBack: () {
                setState(() {
                  _currentView = 1;
                  _activeTag = null;
                });
              },
            ),
            _buildBreadcrumb(
              theme,
              _activeSpecialty!['name'] as String,
              _activeTag!['name'] as String,
            ),
            Expanded(child: _buildServicesView(theme)),
            _buildBottomActionBar(
              theme,
              onPressedSave: () {
                Navigator.pop(context);
                widget.onSave(_selectedSpecialtyIds, _selectedTagIds, _selectedSubtagIds);
              },
              onPressedCancel: () {
                setState(() {
                  _currentView = 1;
                  _activeTag = null;
                });
              },
              cancelText: 'Volver',
              selectedCountText: '${_getTagSelectedCount(_activeTag!)} especialidades en esta categoría',
            ),
          ],
        ],
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(ThemeData theme, String title, {bool showClear = false, VoidCallback? onBack}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                GestureDetector(
                  onTap: onBack,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showClear)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTagIds.clear();
                  _selectedSubtagIds.clear();
                });
              },
              child: const Text(
                'Limpiar todo',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Breadcrumb widget
  Widget _buildBreadcrumb(ThemeData theme, String parent, String child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Text(
            '$parent ',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          Text(
            ' $child',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Info tip
  Widget _buildInfoTip(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _maxLimit >= 999
                  ? 'Selecciona las especializaciones que manejas. (Plan Ilimitado)'
                  : 'Selecciona las especializaciones que manejas. Máximo $_maxLimit en total.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 1: Categories View
  Widget _buildCategoriesView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: widget.specialties.length,
      itemBuilder: (context, index) {
        final spec = widget.specialties[index];
        final name = spec['name'] as String;
        final iconUrl = spec['iconUrl'] as String?;
        final specColorHex = spec['color'] as String?;
        final tags = spec['tags'] as List<dynamic>? ?? [];
        final selectedCount = _getSpecialtySelectedCount(spec);
        final isFullySelected = _isSpecialtyFullySelected(spec);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _activeSpecialty = spec;
                _currentView = 1;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isFullySelected,
                    activeColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      _toggleSpecialty(spec);
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getSpecialtyColor(name, specColorHex),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _buildSpecialtyIconWidget(name, iconUrl, colorHex: specColorHex, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tags.length} subcategorías',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SCREEN 2: Subcategories View
  Widget _buildSubcategoriesView(ThemeData theme) {
    final tags = _activeSpecialty!['tags'] as List<dynamic>? ?? [];
    final specId = _activeSpecialty!['id']?.toString() ?? '';

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final name = tag['name'] as String;
        final iconUrl = tag['iconUrl'] as String?;
        final subtags = tag['subtags'] as List<dynamic>? ?? [];
        final selectedCount = _getTagSelectedCount(tag);
        final isFullySelected = _isTagFullySelected(tag, specId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              if (subtags.isNotEmpty) {
                setState(() {
                  _activeTag = tag;
                  _currentView = 2;
                });
              } else {
                _toggleTag(tag, specId);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isFullySelected,
                    activeColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      _toggleTag(tag, specId);
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _buildTagIconWidget(name, iconUrl, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtags.isEmpty ? 'Servicio General' : '${subtags.length} servicios',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subtags.isNotEmpty) ...[
                    if (selectedCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$selectedCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SCREEN 3: Services View
  Widget _buildServicesView(ThemeData theme) {
    final subtags = _activeTag!['subtags'] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: subtags.length,
      itemBuilder: (context, index) {
        final subtag = subtags[index];
        final name = subtag['name'] as String;
        final subtagId = subtag['id']?.toString() ?? '';
        final isSelected = _selectedSubtagIds.contains(subtagId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _toggleSubtag(subtagId);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.1),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      _toggleSubtag(subtagId);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Bottom action bar widget
  Widget _buildBottomActionBar(
    ThemeData theme, {
    required VoidCallback onPressedSave,
    required VoidCallback onPressedCancel,
    required String cancelText,
    String? selectedCountText,
  }) {
    final defaultCountText = _maxLimit >= 999
        ? '$_totalCount especialidades seleccionadas (Sin límite)'
        : '$_totalCount de $_maxLimit especialidades seleccionadas';
    final countText = selectedCountText ?? defaultCountText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            countText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressedSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Guardar selección',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: TextButton(
              onPressed: onPressedCancel,
              child: Text(
                cancelText,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
