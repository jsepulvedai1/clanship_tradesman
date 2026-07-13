import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'active_request_detail_page.dart';
import '../widgets/active_request_item.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/active_request_detail_entity.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  StreamSubscription? _socketSubscription;
  late final RequestsBloc _requestsBloc;

  @override
  void initState() {
    super.initState();
    _requestsBloc = di.sl<RequestsBloc>()..add(LoadPendingRequests());

    // Escuchar notificaciones del WebSocket para actualizar la lista
    final socketService = di.sl<JobsWebSocketService>();
    socketService.connect();
    _socketSubscription = socketService.stream.listen((event) {
      debugPrint('RequestsPage received jobs websocket notification: $event');
      _requestsBloc.add(LoadPendingRequests());
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initialIndex = context.watch<NavigationBloc>().state.requestsSubIndex;

    return BlocProvider.value(
      value: _requestsBloc,
      child: DefaultTabController(
        key: ValueKey(initialIndex),
        length: 2,
        initialIndex: initialIndex,
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F7F5),
            elevation: 0,
            toolbarHeight: 90,
            titleSpacing: 20,
            automaticallyImplyLeading: Navigator.canPop(context),
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2B45)),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.requestsTitle,
                  style: const TextStyle(
                    color: Color(0xFF0D2B45),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Localizations.localeOf(context).languageCode == 'es'
                      ? 'Gestiona tus servicios y revisa nuevas oportunidades.'
                      : 'Manage your services and review new opportunities.',
                  style: const TextStyle(
                    color: Color(0xFF2E3135),
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            bottom: const RequestsTabBar(),
          ),
          body: BlocBuilder<RequestsBloc, RequestsState>(
            builder: (context, state) {
              if (state is RequestsLoading || state is RequestsInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RequestsError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is RequestsLoaded) {
                final requests = state.requests;
                
                final pendingRequests = requests.where((r) => r.status == 'REQUESTED').toList();
                final agreedRequests = requests.where((r) => r.status == 'AGREED' || r.status == 'SCHEDULED' || r.status == 'IN_VISIT').toList();

                return TabBarView(
                  children: [
                    _buildRequestsList(context, pendingRequests, l10n.requestsNoPending),
                    _buildRequestsList(context, agreedRequests, l10n.requestsNoScheduled),
                  ],
                );
              }
              
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, List<ActiveRequestDetailEntity> list, String emptyMessage) {
    if (list.isEmpty) {
      final isSpanish = Localizations.localeOf(context).languageCode == 'es';
      final String titleText;
      final String descText;

      if (emptyMessage.contains('pendientes') || emptyMessage.contains('pending') || emptyMessage.contains('No hay')) {
        titleText = isSpanish ? 'Aún no tienes solicitudes activas' : 'No active requests yet';
        descText = isSpanish 
            ? 'Cuando un cliente solicite tus servicios aparecerán aquí.' 
            : 'When a client requests your services, they will appear here.';
      } else {
        titleText = isSpanish ? 'Aún no tienes solicitudes agendadas' : 'No scheduled requests yet';
        descText = isSpanish 
            ? 'Cuando agendes un servicio con un cliente aparecerá aquí.' 
            : 'When you schedule a service with a client, it will appear here.';
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<RequestsBloc>().add(LoadPendingRequests());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                // Card 1: Sin solicitudes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Illustration Stack
                      Center(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B6E4F).withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/icon/icons_ F28C28/dialog.svg',
                                width: 44,
                                height: 44,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF0B6E4F),
                                  BlendMode.srcIn,
                                ),
                              ),
                              Positioned(
                                top: 25,
                                right: 15,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF28C28),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 30,
                                left: 20,
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    color: const Color(0xFF0B6E4F).withValues(alpha: 0.4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 25,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF0B6E4F).withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 25,
                                right: 25,
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    color: const Color(0xFF0B6E4F).withValues(alpha: 0.3),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        titleText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2B45),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        descText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E3135),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<RequestsBloc>().add(LoadPendingRequests());
                        },
                        icon: SvgPicture.asset(
                          'assets/icon/icons_ F28C28/dialog.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          isSpanish ? 'Actualizar solicitudes' : 'Update requests',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B6E4F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Card 2: ¿Cómo recibir más solicitudes?
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF28C28).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/icon/icons_ F28C28/dialog.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFF28C28),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSpanish ? '¿Cómo recibir más solicitudes?' : 'How to get more requests?',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D2B45),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildTipItem(
                                  isSpanish ? 'Mantén tu disponibilidad activa' : 'Keep your availability active',
                                ),
                                const SizedBox(height: 12),
                                _buildTipItem(
                                  isSpanish ? 'Completa tu perfil profesional' : 'Complete your professional profile',
                                ),
                                const SizedBox(height: 12),
                                _buildTipItem(
                                  isSpanish ? 'Define correctamente tu área de servicio' : 'Define your service area correctly',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: CustomPaint(
                                  painter: TargetDartPainter(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestsBloc>().add(LoadPendingRequests());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final request = list[index];
          return ActiveRequestItem(
            request: request,
            onTap: () async {
              if (!request.isRead && request.status == 'REQUESTED') {
                final intId = int.tryParse(request.id) ?? 0;
                if (intId > 0) {
                  context.read<RequestsBloc>().add(MarkRequestAsReadEvent(jobId: intId));
                }
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActiveRequestDetailPage(request: request),
                ),
              );
              if (context.mounted) {
                context.read<RequestsBloc>().add(LoadPendingRequests());
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0B6E4F).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icon/icons_ F28C28/dialog.svg',
            width: 10,
            height: 10,
            colorFilter: const ColorFilter.mode(
              Color(0xFF0B6E4F),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3135),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class RequestsTabBar extends StatefulWidget implements PreferredSizeWidget {
  const RequestsTabBar({super.key});

  @override
  State<RequestsTabBar> createState() => _RequestsTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _RequestsTabBarState extends State<RequestsTabBar> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = DefaultTabController.of(context);
    if (newController != _controller) {
      _controller?.removeListener(_onTabChanged);
      _controller = newController;
      _controller?.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final int selectedIndex = controller.index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: controller,
          indicatorColor: const Color(0xFF0B6E4F),
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: [
            _buildTab(
              index: 0,
              isSelected: selectedIndex == 0,
              label: l10n.requestsTabPending,
            ),
            _buildTab(
              index: 1,
              isSelected: selectedIndex == 1,
              label: l10n.requestsTabScheduled,
            ),
          ],
        ),
        Container(
          height: 1,
          color: Colors.black.withValues(alpha: 0.06),
        ),
      ],
    );
  }

  Widget _buildTab({
    required int index,
    required bool isSelected,
    required String label,
  }) {
    final activeColor = const Color(0xFF0B6E4F);
    final inactiveColor = const Color(0xFF5E6E78);

    return Tab(
      height: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icon/icons_ F28C28/dialog.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isSelected ? activeColor : inactiveColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TargetDartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw decorative light background glow
    final glowPaint = Paint()
      ..color = const Color(0xFF0B6E4F).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(8, 8), 38, glowPaint);
    
    // 1. Concentric Circles
    final paintOuter = Paint()
      ..color = const Color(0xFF0B6E4F).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 36, paintOuter);

    final paintBorder1 = Paint()
      ..color = const Color(0xFF0B6E4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 28, paintBorder1);

    final paintInnerGlow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 27, paintInnerGlow);

    final paintBorder2 = Paint()
      ..color = const Color(0xFF0B6E4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 18, paintBorder2);

    final paintCenterGlow = Paint()
      ..color = const Color(0xFF0B6E4F).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 17, paintCenterGlow);

    final paintBullseye = Paint()
      ..color = const Color(0xFF0B6E4F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, paintBullseye);

    // 2. Dart / Arrow
    // Arrow direction: from top-right (dx: 30, dy: -30) pointing to center (0,0)
    final arrowStart = center + const Offset(30, -30);
    final arrowEnd = center;

    final shaftPaint = Paint()
      ..color = const Color(0xFF2E3135)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(arrowStart, arrowEnd, shaftPaint);

    // Fletching (orange tail feathers at arrowStart)
    final fletchPaint = Paint()
      ..color = const Color(0xFFF28C28)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(arrowStart.dx, arrowStart.dy);
    path.lineTo(arrowStart.dx + 4, arrowStart.dy - 12);
    path.lineTo(arrowStart.dx + 12, arrowStart.dy - 12);
    path.lineTo(arrowStart.dx + 6, arrowStart.dy - 6);
    path.close();

    final path2 = Path();
    path2.moveTo(arrowStart.dx, arrowStart.dy);
    path2.lineTo(arrowStart.dx + 12, arrowStart.dy - 4);
    path2.lineTo(arrowStart.dx + 12, arrowStart.dy - 12);
    path2.lineTo(arrowStart.dx + 6, arrowStart.dy - 6);
    path2.close();

    canvas.drawPath(path, fletchPaint);
    canvas.drawPath(path2, fletchPaint);

    // Draw a small arrow tip at center
    final tipPaint = Paint()
      ..color = const Color(0xFF2E3135)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
