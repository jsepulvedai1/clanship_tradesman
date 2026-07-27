import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_event.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_state.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clanship_mobile_tradesman/core/di/injection.dart';

class MyPlanPage extends StatelessWidget {
  const MyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfileData()),
      child: const MyPlanPageView(),
    );
  }
}

class MyPlanPageView extends StatefulWidget {
  const MyPlanPageView({super.key});

  @override
  State<MyPlanPageView> createState() => _MyPlanPageViewState();
}

class _MyPlanPageViewState extends State<MyPlanPageView> {
  @override
  void initState() {
    super.initState();
    // Load subscription plans from backend
    context.read<ProfileBloc>().add(LoadSubscriptionPlansEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // Loaded successfully
        }
      },
      builder: (context, state) {
        if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.planTitle),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.redAccent : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is! ProfileLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.planTitle),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAzure),
            ),
          );
        }

        final user = state.user;
        final currentPlan = user.subscriptionPlan;
        final plans = state.availablePlans;

        return Scaffold(
          backgroundColor: isDark ? AppColors.trueBlack : AppColors.smokeWhite,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.primaryBlue,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              l10n.planTitle,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Active Plan Card
                _buildCurrentPlanCard(context, currentPlan, isDark, l10n),
                const SizedBox(height: 32),

                // Available Plans Section
                Text(
                  l10n.planAvailableTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),

                if (state.isLoadingPlans)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDark ? Colors.white : AppColors.primaryAzure,
                      ),
                    ),
                  )
                else if (plans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No hay otros planes disponibles en el servidor',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...plans.map((plan) {
                    final isCurrent = currentPlan?.id == plan.id ||
                        (currentPlan == null && plan.price == 0);
                    return _buildPlanOptionCard(
                      context: context,
                      plan: plan,
                      isCurrent: isCurrent,
                      isDark: isDark,
                      l10n: l10n,
                      isSubscribing: state.isSubscribing,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPlanCard(
    BuildContext context,
    SubscriptionPlanEntity? plan,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final planName = plan?.name ?? 'Plan Base';
    final planPrice = plan?.price ?? 0.0;
    final planDuration = plan?.durationDays ?? 3650;
    final planDesc = plan?.description ?? 'Plan básico gratuito';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4364F7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  l10n.planActive.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.planCurrentTitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            planName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            planDesc,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRECIO',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    planPrice == 0 ? l10n.planFree : '\$${planPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'DURACIÓN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    planDuration > 1000 ? 'Permanente' : '$planDuration ${l10n.planDurationDays}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value, bool isDark, {bool isWhiteText = false}) {
    final bool isDisabled = value == '—' || value.isEmpty;
    final Color iconColor = isDisabled
        ? (isWhiteText ? Colors.white38 : (isDark ? Colors.white24 : Colors.grey.shade400))
        : (isWhiteText ? Colors.white : AppColors.primaryAzure);
    final Color textColor = isWhiteText
        ? Colors.white.withOpacity(0.9)
        : (isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.8));
    final Color valColor = isWhiteText
        ? Colors.white
        : (isDark ? Colors.white : AppColors.primaryBlue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDisabled ? Icons.remove_circle_outline_rounded : Icons.check_circle_rounded,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptionCard({
    required BuildContext context,
    required SubscriptionPlanEntity plan,
    required bool isCurrent,
    required bool isDark,
    required AppLocalizations l10n,
    required bool isSubscribing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? AppColors.primaryAzure
              : (isDark ? Colors.white10 : Colors.black12),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryBlue,
                ),
              ),
              if (isCurrent)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryAzure,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.price == 0 ? l10n.planFree : '\$${plan.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    plan.durationDays > 1000 ? 'Permanente' : '${plan.durationDays} ${l10n.planDurationDays}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
              if (!isCurrent)
                ElevatedButton(
                  onPressed: isSubscribing
                      ? null
                      : () {
                          context
                              .read<ProfileBloc>()
                              .add(SubscribeToPlanEvent(plan.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.planUpgradeSuccess),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAzure,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: isSubscribing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.planSelect,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          _buildFeatureRow('Solicitudes mensuales', plan.monthlyRequests == null ? 'Ilimitadas' : '${plan.monthlyRequests}', isDark),
          _buildFeatureRow('Solicitudes urgentes', plan.urgentRequests == null ? 'Ilimitadas' : '${plan.urgentRequests}', isDark),
          _buildFeatureRow('Categorías de servicio', plan.serviceCategories == null ? 'Ilimitadas' : '${plan.serviceCategories}', isDark),
          _buildFeatureRow('Posición en búsquedas', plan.searchPosition, isDark),
          _buildFeatureRow('Insignia destacada', plan.featuredBadge ?? '—', isDark),
          _buildFeatureRow('Aparición campañas RRSS', plan.rrssCampaigns ?? '—', isDark),
          _buildFeatureRow('Difusión radial', plan.radioBroadcast ?? '—', isDark),
          _buildFeatureRow('Estadísticas del perfil', plan.profileStatistics, isDark),
          _buildFeatureRow('Soporte', plan.supportLevel, isDark),
        ],
      ),
    );
  }
}
