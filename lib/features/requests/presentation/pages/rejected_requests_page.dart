import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/entities/active_request_detail_entity.dart';

class RejectedRequestsPage extends StatelessWidget {
  const RejectedRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RequestsBloc>()..add(LoadRejectedRequests()),
      child: const RejectedRequestsView(),
    );
  }
}

class RejectedRequestsView extends StatelessWidget {
  const RejectedRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.trueBlack : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.trueBlack),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Solicitudes Rechazadas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<RequestsBloc, RequestsState>(
          builder: (context, state) {
            if (state is RequestsLoading || state is RequestsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RequestsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is RejectedRequestsLoaded) {
              final rejectedRequests = state.rejectedRequests;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<RequestsBloc>().add(LoadRejectedRequests());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: rejectedRequests.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay solicitudes rechazadas o canceladas.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: rejectedRequests.length,
                        itemBuilder: (context, index) {
                          final request = rejectedRequests[index];
                          return _buildRejectedJobCard(context, request);
                        },
                      ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildRejectedJobCard(BuildContext context, ActiveRequestDetailEntity request) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Formatting currency
    final priceStr = request.agreedPrice != null
        ? '\$${request.agreedPrice!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
        : '\$0';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Customer Name and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.clientName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  priceStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              request.instruction,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Schedule Details and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (request.scheduledDate != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            request.scheduledDate!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (request.scheduledTime != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppColors.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            request.scheduledTime!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Rechazada',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
