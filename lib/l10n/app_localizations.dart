import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Anti Gravity Tradesman'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @homeWelcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get homeWelcomePrefix;

  /// No description provided for @homeRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'My Rating'**
  String get homeRatingLabel;

  /// No description provided for @homeReviewsText.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get homeReviewsText;

  /// No description provided for @homeServicesLink.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get homeServicesLink;

  /// No description provided for @homeStatsActive.
  ///
  /// In en, this message translates to:
  /// **'Job\nRequests'**
  String get homeStatsActive;

  /// No description provided for @homeStatsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed\nRequests'**
  String get homeStatsCompleted;

  /// No description provided for @homeStatsRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected\nRequests'**
  String get homeStatsRejected;

  /// No description provided for @homeStatsScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled\nRequests'**
  String get homeStatsScheduled;

  /// No description provided for @homeAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability Status'**
  String get homeAvailabilityTitle;

  /// No description provided for @homeAvailabilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control when you can receive requests'**
  String get homeAvailabilitySubtitle;

  /// No description provided for @homeRecentRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Requests'**
  String get homeRecentRequestsTitle;

  /// No description provided for @homeGoToRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Go to request'**
  String get homeGoToRequestAction;

  /// No description provided for @profileWhoAmI.
  ///
  /// In en, this message translates to:
  /// **'Who am I'**
  String get profileWhoAmI;

  /// No description provided for @profileProfessionalProfile.
  ///
  /// In en, this message translates to:
  /// **'Professional profile'**
  String get profileProfessionalProfile;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profileServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get profileServices;

  /// No description provided for @profileServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The types of jobs you offer'**
  String get profileServicesSubtitle;

  /// No description provided for @profileServiceTags.
  ///
  /// In en, this message translates to:
  /// **'Your service tags'**
  String get profileServiceTags;

  /// No description provided for @profileAddServiceTag.
  ///
  /// In en, this message translates to:
  /// **'Want to add another service tag?'**
  String get profileAddServiceTag;

  /// No description provided for @profileSearchTags.
  ///
  /// In en, this message translates to:
  /// **'Search Tags'**
  String get profileSearchTags;

  /// No description provided for @profileMaxTagsHint.
  ///
  /// In en, this message translates to:
  /// **'You can have a maximum of 6 service tags.'**
  String get profileMaxTagsHint;

  /// No description provided for @profilePhotosVideos.
  ///
  /// In en, this message translates to:
  /// **'Photos/videos'**
  String get profilePhotosVideos;

  /// No description provided for @profilePlanReminder.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get profilePlanReminder;

  /// No description provided for @profileDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get profileDays;

  /// No description provided for @profilePlanSuffix.
  ///
  /// In en, this message translates to:
  /// **'of your plan'**
  String get profilePlanSuffix;

  /// No description provided for @profileWorkingRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Radius'**
  String get profileWorkingRadiusTitle;

  /// No description provided for @profileWorkingRadiusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'maximum working distance according to the location of the clients'**
  String get profileWorkingRadiusSubtitle;

  /// No description provided for @profileDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get profileDistance;

  /// No description provided for @profileKm.
  ///
  /// In en, this message translates to:
  /// **'Km'**
  String get profileKm;

  /// No description provided for @requestUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent request'**
  String get requestUrgentTitle;

  /// No description provided for @requestContactClient.
  ///
  /// In en, this message translates to:
  /// **'Contact the client for more details about the request'**
  String get requestContactClient;

  /// No description provided for @requestClientInfo.
  ///
  /// In en, this message translates to:
  /// **'Client Information'**
  String get requestClientInfo;

  /// No description provided for @requestUserLabel.
  ///
  /// In en, this message translates to:
  /// **'User:'**
  String get requestUserLabel;

  /// No description provided for @requestPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get requestPhoneLabel;

  /// No description provided for @requestAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get requestAddressLabel;

  /// No description provided for @requestGoToMaps.
  ///
  /// In en, this message translates to:
  /// **'go to Google Maps'**
  String get requestGoToMaps;

  /// No description provided for @requestGoToWaze.
  ///
  /// In en, this message translates to:
  /// **'go to Waze'**
  String get requestGoToWaze;

  /// No description provided for @requestGoToChat.
  ///
  /// In en, this message translates to:
  /// **'Go to chat'**
  String get requestGoToChat;

  /// No description provided for @requestReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get requestReminderTitle;

  /// No description provided for @requestReminderTip1.
  ///
  /// In en, this message translates to:
  /// **'Make sure to confirm the date and time with the client'**
  String get requestReminderTip1;

  /// No description provided for @requestReminderTip2.
  ///
  /// In en, this message translates to:
  /// **'Check that you have the necessary tools'**
  String get requestReminderTip2;

  /// No description provided for @requestReminderTip3.
  ///
  /// In en, this message translates to:
  /// **'Arrive on time for the scheduled appointment'**
  String get requestReminderTip3;

  /// No description provided for @requestReminderTip4.
  ///
  /// In en, this message translates to:
  /// **'Have agreed on the price previously with the client'**
  String get requestReminderTip4;

  /// No description provided for @completedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTitle;

  /// No description provided for @completedFilterPrefix.
  ///
  /// In en, this message translates to:
  /// **'In this'**
  String get completedFilterPrefix;

  /// No description provided for @completedFilterSuffix.
  ///
  /// In en, this message translates to:
  /// **'you have completed:'**
  String get completedFilterSuffix;

  /// No description provided for @completedWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get completedWeek;

  /// No description provided for @completedMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get completedMonth;

  /// No description provided for @completedYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get completedYear;

  /// No description provided for @completedJobsLabel.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get completedJobsLabel;

  /// No description provided for @completedGeneratedLabel.
  ///
  /// In en, this message translates to:
  /// **'generated'**
  String get completedGeneratedLabel;

  /// No description provided for @completedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed jobs:'**
  String get completedSectionTitle;

  /// No description provided for @completedUrgentTag.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get completedUrgentTag;

  /// No description provided for @profileLinkSocial.
  ///
  /// In en, this message translates to:
  /// **'Link social networks'**
  String get profileLinkSocial;

  /// No description provided for @profileClientReviews.
  ///
  /// In en, this message translates to:
  /// **'Client reviews'**
  String get profileClientReviews;

  /// No description provided for @profileViewDocuments.
  ///
  /// In en, this message translates to:
  /// **'Document visualization'**
  String get profileViewDocuments;

  /// No description provided for @docsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents or Certificates'**
  String get docsTitle;

  /// No description provided for @docsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can activate or deactivate the visibility of your documents on your public profile'**
  String get docsSubtitle;

  /// No description provided for @docsIdCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get docsIdCard;

  /// No description provided for @docsDriverLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get docsDriverLicense;

  /// No description provided for @docsAdd.
  ///
  /// In en, this message translates to:
  /// **'+ Add Documents'**
  String get docsAdd;

  /// No description provided for @docsFooter.
  ///
  /// In en, this message translates to:
  /// **'Here you can add your documents, certificates, or titles'**
  String get docsFooter;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get settingsPersonalInfo;

  /// No description provided for @settingsEditData.
  ///
  /// In en, this message translates to:
  /// **'Edit Data'**
  String get settingsEditData;

  /// No description provided for @settingsMyPlan.
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get settingsMyPlan;

  /// No description provided for @settingsMyDocs.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get settingsMyDocs;

  /// No description provided for @settingsVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get settingsVerificationStatus;

  /// No description provided for @settingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsChooseLanguage;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions of use'**
  String get settingsTerms;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Requests'**
  String get requestsTitle;

  /// No description provided for @requestsTabPending.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTabPending;

  /// No description provided for @requestsTabScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get requestsTabScheduled;

  /// No description provided for @requestsNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending requests.'**
  String get requestsNoPending;

  /// No description provided for @requestsNoScheduled.
  ///
  /// In en, this message translates to:
  /// **'No scheduled jobs.'**
  String get requestsNoScheduled;

  /// No description provided for @requestEnrichedDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional Client Details'**
  String get requestEnrichedDetailsTitle;

  /// No description provided for @requestScheduleVisit.
  ///
  /// In en, this message translates to:
  /// **'Schedule Visit'**
  String get requestScheduleVisit;

  /// No description provided for @requestRescheduleVisit.
  ///
  /// In en, this message translates to:
  /// **'Reschedule Visit'**
  String get requestRescheduleVisit;

  /// No description provided for @requestScheduleLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder lead time'**
  String get requestScheduleLeadTitle;

  /// No description provided for @requestScheduleLeadBody.
  ///
  /// In en, this message translates to:
  /// **'How far in advance do you want to send the push reminder notification?'**
  String get requestScheduleLeadBody;

  /// No description provided for @requestSchedule15Mins.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes before'**
  String get requestSchedule15Mins;

  /// No description provided for @requestSchedule30Mins.
  ///
  /// In en, this message translates to:
  /// **'30 Minutes before'**
  String get requestSchedule30Mins;

  /// No description provided for @requestSchedule1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour before'**
  String get requestSchedule1Hour;

  /// No description provided for @requestSchedule2Hours.
  ///
  /// In en, this message translates to:
  /// **'2 Hours before'**
  String get requestSchedule2Hours;

  /// No description provided for @requestSchedule3Hours.
  ///
  /// In en, this message translates to:
  /// **'3 Hours before'**
  String get requestSchedule3Hours;

  /// No description provided for @requestCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get requestCancel;

  /// No description provided for @requestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get requestConfirm;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @planSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get planSelect;

  /// No description provided for @planActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get planActive;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planDurationDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get planDurationDays;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get planTitle;

  /// No description provided for @planCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Current Plan'**
  String get planCurrentTitle;

  /// No description provided for @planAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Plans'**
  String get planAvailableTitle;

  /// No description provided for @planUpgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan updated successfully!'**
  String get planUpgradeSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
