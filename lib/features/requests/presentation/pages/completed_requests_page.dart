import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_event.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_state.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import '../widgets/completed_stats_card.dart';
import '../widgets/completed_job_card.dart';
import '../widgets/time_filter_dropdown.dart';

class CompletedRequestsPage extends StatelessWidget {
  const CompletedRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RequestsBloc>()..add(LoadCompletedRequests()),
      child: const CompletedRequestsView(),
    );
  }
}

class CompletedRequestsView extends StatefulWidget {
  const CompletedRequestsView({super.key});

  @override
  State<CompletedRequestsView> createState() => _CompletedRequestsViewState();
}

class _CompletedRequestsViewState extends State<CompletedRequestsView> {
  String _selectedFilter = 'week';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(
          l10n.completedTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
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
            } else if (state is CompletedRequestsLoaded) {
              final completedJobs = state.completedJobs;
              
              // Calculate stats dynamically
              final totalJobs = completedJobs.length;
              final totalEarnings = completedJobs.fold<double>(0, (sum, job) => sum + job.amount);
              
              // Formatting currency
              final currencyFormat = '\$${totalEarnings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<RequestsBloc>().add(LoadCompletedRequests());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      const SizedBox(height: 32),
                      
                      // Filter Row
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            l10n.completedFilterPrefix,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          TimeFilterDropdown(
                            selectedValue: _selectedFilter,
                            onChanged: (val) => setState(() => _selectedFilter = val!),
                          ),
                          Text(
                            l10n.completedFilterSuffix,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Stats Cards
                      Row(
                        children: [
                           Expanded(
                            child: CompletedStatsCard(
                              value: totalJobs.toString(),
                              label: l10n.completedJobsLabel,
                            ),
                          ),
                          const SizedBox(width: 16),
                           Expanded(
                            child: CompletedStatsCard(
                              value: currencyFormat,
                              label: l10n.completedGeneratedLabel,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Section Title
                      Text(
                        l10n.completedSectionTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      if (completedJobs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text('No hay solicitudes finalizadas.'),
                          ),
                        )
                      else
                        ...completedJobs.map((job) => CompletedJobCard(job: job)),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
