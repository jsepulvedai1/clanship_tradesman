import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_event.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_state.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart' as di;
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/l10n/app_localizations.dart';

class AssociateCodePage extends StatelessWidget {
  const AssociateCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ProfileBloc>()..add(LoadProfileData()),
      child: const _AssociateCodeView(),
    );
  }
}

class _AssociateCodeView extends StatefulWidget {
  const _AssociateCodeView();

  @override
  State<_AssociateCodeView> createState() => _AssociateCodeViewState();
}

class _AssociateCodeViewState extends State<_AssociateCodeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final lang = Localizations.localeOf(context).languageCode;
        context.read<ProfileBloc>().add(LoadReferralContentEvent(language: lang));
      }
    });
  }

  void _copyToClipboard(BuildContext context, String code, String message) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareCode(String code, String messageTemplate) async {
    final message = messageTemplate.replaceAll('{code}', code);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'Únete a Clanship con mi código de asociado',
        ),
      );
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _copyToClipboard(context, code, l10n.associateCodeCopied);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          l10n.associateCodeTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          // Obtener datos prioritariamente de ProfileState, con fallback a AuthBloc
          String referralCode = 'CLAN-PRO';
          int totalReferrals = 0;
          int pendingReferrals = 0;
          int targetReferrals = 5;
          String rewardPlanName = 'Plan Profesional';
          int rewardDays = 30;
          DateTime? planExpiresAt;
          int rewardsEarned = 0;
          int maxRewards = 1;
          bool hasReachedMax = false;

          if (profileState is ProfileLoaded) {
            final u = profileState.user;
            if (u.referralCode != null && u.referralCode!.isNotEmpty) {
              referralCode = u.referralCode!;
            }
            totalReferrals = u.referralsTotalCount;
            pendingReferrals = u.referralsPendingCount;
            targetReferrals = u.referralsTargetCount > 0 ? u.referralsTargetCount : 5;
            rewardPlanName = u.referralRewardPlanName ?? 'Plan Profesional';
            rewardDays = u.referralRewardDays > 0 ? u.referralRewardDays : 30;
            planExpiresAt = u.planExpiresAt;
            rewardsEarned = u.referralsRewardsEarnedCount;
            maxRewards = u.referralMaxRewardsPerUser;
            hasReachedMax = u.referralHasReachedMaxRewards;
          } else {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              final u = authState.user;
              if (u.referralCode != null && u.referralCode!.isNotEmpty) {
                referralCode = u.referralCode!;
              }
              totalReferrals = u.referralsTotalCount;
              pendingReferrals = u.referralsPendingCount;
              targetReferrals = u.referralsTargetCount > 0 ? u.referralsTargetCount : 5;
              rewardPlanName = u.referralRewardPlanName ?? 'Plan Profesional';
              rewardDays = u.referralRewardDays > 0 ? u.referralRewardDays : 30;
              planExpiresAt = u.planExpiresAt;
              rewardsEarned = u.referralsRewardsEarnedCount;
              maxRewards = u.referralMaxRewardsPerUser;
              hasReachedMax = u.referralHasReachedMaxRewards;
            }
          }

          final refContent = profileState is ProfileLoaded
              ? profileState.referralContent
              : const ReferralContentEntity();

          final heroTitle = refContent.heroTitle.trim().isNotEmpty
              ? refContent.heroTitle
              : '¡Invita y gana beneficios!';

          final heroDesc = refContent.formatHeroDescription(
            target: targetReferrals,
            days: rewardDays,
            plan: rewardPlanName,
            fallback: l10n.associateCodeDescription(targetReferrals, rewardDays, rewardPlanName),
          );

          final shareMsgTemplate = refContent.shareMessage.trim().isNotEmpty
              ? refContent.shareMessage
              : l10n.associateCodeShareMessage('{code}');

          final howWorksTitle = refContent.howItWorksTitle.trim().isNotEmpty
              ? refContent.howItWorksTitle
              : '¿Cómo funciona?';

          final step1Text = refContent.step1.trim().isNotEmpty
              ? refContent.step1
              : 'Comparte tu código con clientes o colegas.';

          final step2Text = refContent.step2.trim().isNotEmpty
              ? refContent.step2
              : 'Al registrarse en Clanship, ingresan tu código.';

          final step3Text = refContent.formatStep3(
            target: targetReferrals,
            days: rewardDays,
            plan: rewardPlanName,
            fallback: 'Al completar $targetReferrals asociados, ganas automáticamente $rewardDays días de $rewardPlanName.',
          );

          final double progress = (pendingReferrals / targetReferrals).clamp(0.0, 1.0);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner / Icono superior
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAzure.withValues(alpha: 0.2),
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      size: 38,
                      color: AppColors.primaryAzure,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título y Subtítulo
                Text(
                  heroTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  heroDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Tarjeta Principal de Código
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryAzure.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TU CÓDIGO DE ASOCIADO',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAzure,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : AppColors.smokeWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              referralCode,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3.0,
                                color: isDark ? Colors.white : AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Botones de Copiar y Compartir
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copyToClipboard(
                                context,
                                referralCode,
                                l10n.associateCodeCopied,
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: Text(l10n.associateCodeCopy),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryAzure,
                                side: BorderSide(color: AppColors.primaryAzure),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _shareCode(
                                referralCode,
                                shareMsgTemplate,
                              ),
                              icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                              label: Text(
                                l10n.associateCodeShare,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAzure,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tarjeta de Progreso hacia la Meta
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
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
                            'Progreso hacia el beneficio',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasReachedMax
                                  ? AppColors.successGreen.withValues(alpha: 0.15)
                                  : AppColors.primaryAzure.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: hasReachedMax
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.successGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.associateCodeMaxReachedBadge,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.successGreen,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    '$pendingReferrals / $targetReferrals',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryAzure,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Barra de progreso
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: hasReachedMax ? 1.0 : progress,
                          minHeight: 12,
                          backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hasReachedMax ? AppColors.successGreen : AppColors.primaryAzure,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        hasReachedMax
                            ? l10n.associateCodeMaxRewardsReached
                            : l10n.associateCodeProgress(pendingReferrals, targetReferrals),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: hasReachedMax ? FontWeight.w600 : FontWeight.normal,
                          color: hasReachedMax
                              ? AppColors.successGreen
                              : (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.65),
                        ),
                      ),

                      if (maxRewards > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.associateCodeRewardsProgress(rewardsEarned, maxRewards),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasReachedMax
                                ? AppColors.successGreen.withValues(alpha: 0.8)
                                : AppColors.primaryAzure,
                          ),
                        ),
                      ],

                      if (planExpiresAt != null && planExpiresAt.isAfter(DateTime.now())) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                refContent.formatActiveBenefit(
                                  date: DateFormat('dd/MM/yyyy').format(planExpiresAt),
                                  fallback: 'Beneficio de plan activo hasta el ${DateFormat('dd/MM/yyyy').format(planExpiresAt)}',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tarjeta de estadísticas e instrucciones
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_alt_outlined, color: AppColors.primaryAzure, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            l10n.associateCodeTotal(totalReferrals),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 14),
                      Text(
                        howWorksTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildStep(
                        '1',
                        step1Text,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildStep(
                        '2',
                        step2Text,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildStep(
                        '3',
                        step3Text,
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(String number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryAzure.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryAzure,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: (isDark ? Colors.white : AppColors.textDark).withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
