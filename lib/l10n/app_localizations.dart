import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
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

  /// No description provided for @docsIdCardFront.
  ///
  /// In en, this message translates to:
  /// **'ID Card (Front)'**
  String get docsIdCardFront;

  /// No description provided for @docsIdCardBack.
  ///
  /// In en, this message translates to:
  /// **'ID Card (Back)'**
  String get docsIdCardBack;

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

  /// No description provided for @docsStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get docsStatusApproved;

  /// No description provided for @docsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get docsStatusRejected;

  /// No description provided for @docsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending validation'**
  String get docsStatusPending;

  /// No description provided for @docsRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String docsRejectionReason(String reason);

  /// No description provided for @docsVisiblePublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Visible on public profile'**
  String get docsVisiblePublicProfile;

  /// No description provided for @docsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get docsAddTitle;

  /// No description provided for @docsAddInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Document Name/Title'**
  String get docsAddInputLabel;

  /// No description provided for @docsAddInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SEC Certificate, Technical Degree'**
  String get docsAddInputHint;

  /// No description provided for @docsAddNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a document name'**
  String get docsAddNameError;

  /// No description provided for @verificationModalApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Approved & Validated'**
  String get verificationModalApprovedTitle;

  /// No description provided for @verificationModalPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'In Validation Process'**
  String get verificationModalPendingTitle;

  /// No description provided for @verificationModalApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your professional profile has been verified. You have full access to be active, receive direct requests from clients, and quote on specific requirements.'**
  String get verificationModalApprovedBody;

  /// No description provided for @verificationModalPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your background and documents are being reviewed by our administrative team. The process takes between 24 to 48 business hours. During this period your availability and access to quotes will remain restricted.'**
  String get verificationModalPendingBody;

  /// No description provided for @verificationModalApprovedBtn.
  ///
  /// In en, this message translates to:
  /// **'View My Documents'**
  String get verificationModalApprovedBtn;

  /// No description provided for @verificationModalPendingBtn.
  ///
  /// In en, this message translates to:
  /// **'Manage My Documents'**
  String get verificationModalPendingBtn;

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

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

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

  /// No description provided for @homePendingValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'In validation process'**
  String get homePendingValidationTitle;

  /// No description provided for @homePendingValidationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is being reviewed by the administrative team. Once approved you can activate your availability.'**
  String get homePendingValidationMessage;

  /// No description provided for @homeRejectedValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Rejected / Needs Review'**
  String get homeRejectedValidationTitle;

  /// No description provided for @homeRejectedValidationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your application could not be verified due to remarks on your documents or photos:'**
  String get homeRejectedValidationSubtitle;

  /// No description provided for @homeRejectedReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason:'**
  String get homeRejectedReasonLabel;

  /// No description provided for @homeRejectedReuploadBtn.
  ///
  /// In en, this message translates to:
  /// **'Update documents and submit for review'**
  String get homeRejectedReuploadBtn;

  /// No description provided for @homeServiceAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'My Service Area / Location'**
  String get homeServiceAreaTitle;

  /// No description provided for @homeCoordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get homeCoordinatesLabel;

  /// No description provided for @homeGpsActualBtn.
  ///
  /// In en, this message translates to:
  /// **'Current GPS'**
  String get homeGpsActualBtn;

  /// No description provided for @homeFixAddressBtn.
  ///
  /// In en, this message translates to:
  /// **'Set Address'**
  String get homeFixAddressBtn;

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

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Specialist'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginInvalidCredentials;

  /// No description provided for @loginChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get loginChangeLanguage;

  /// No description provided for @loginSloganPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your trusted network '**
  String get loginSloganPrefix;

  /// No description provided for @loginSloganSuffix.
  ///
  /// In en, this message translates to:
  /// **'to get things done'**
  String get loginSloganSuffix;

  /// No description provided for @loginConceptTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get loginConceptTrust;

  /// No description provided for @loginConceptTrustDesc.
  ///
  /// In en, this message translates to:
  /// **'Verification\n& safety'**
  String get loginConceptTrustDesc;

  /// No description provided for @loginConceptSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get loginConceptSpeed;

  /// No description provided for @loginConceptSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Immediate\nresponse'**
  String get loginConceptSpeedDesc;

  /// No description provided for @loginConceptConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get loginConceptConnection;

  /// No description provided for @loginConceptConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'People who\nsolve'**
  String get loginConceptConnectionDesc;

  /// No description provided for @loginBenefitVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified\nspecialists'**
  String get loginBenefitVerified;

  /// No description provided for @loginBenefitReviews.
  ///
  /// In en, this message translates to:
  /// **'Real\nreviews'**
  String get loginBenefitReviews;

  /// No description provided for @loginBenefitTracking.
  ///
  /// In en, this message translates to:
  /// **'Service\ntracking'**
  String get loginBenefitTracking;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to receive client requests'**
  String get authSubtitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Not registered as a specialist?'**
  String get authNoAccount;

  /// No description provided for @authRegisterHere.
  ///
  /// In en, this message translates to:
  /// **'Register as Specialist'**
  String get authRegisterHere;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialist Registration'**
  String get authRegisterTitle;

  /// No description provided for @authPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get authPersonalData;

  /// No description provided for @authProfessionalData.
  ///
  /// In en, this message translates to:
  /// **'Professional Profile'**
  String get authProfessionalData;

  /// No description provided for @authDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documentation & Certificates'**
  String get authDocuments;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get authLastName;

  /// No description provided for @authBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get authBirthdate;

  /// No description provided for @authRepeatEmail.
  ///
  /// In en, this message translates to:
  /// **'Repeat Email'**
  String get authRepeatEmail;

  /// No description provided for @authRepeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get authRepeatPassword;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get authPhone;

  /// No description provided for @authAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get authAddress;

  /// No description provided for @authBio.
  ///
  /// In en, this message translates to:
  /// **'Bio / Service Description'**
  String get authBio;

  /// No description provided for @authHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Estimated hourly rate (\$)'**
  String get authHourlyRate;

  /// No description provided for @authServiceRadius.
  ///
  /// In en, this message translates to:
  /// **'Service radius (km)'**
  String get authServiceRadius;

  /// No description provided for @authProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Mandatory Profile Photo'**
  String get authProfilePhoto;

  /// No description provided for @authCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo with camera'**
  String get authCamera;

  /// No description provided for @authGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get authGallery;

  /// No description provided for @authNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authNext;

  /// No description provided for @authPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get authPrevious;

  /// No description provided for @authCompleteRegister.
  ///
  /// In en, this message translates to:
  /// **'Submit Registration'**
  String get authCompleteRegister;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @versionUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get versionUpdateTitle;

  /// No description provided for @versionUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'To continue receiving job requests safely, please update the app to the latest version.'**
  String get versionUpdateMessage;

  /// No description provided for @versionUpdateBtn.
  ///
  /// In en, this message translates to:
  /// **'Update in App Store'**
  String get versionUpdateBtn;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session was opened on another device.'**
  String get sessionExpired;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get registerSubtitle;

  /// No description provided for @registerStepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get registerStepPersonal;

  /// No description provided for @registerStepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location & Contact'**
  String get registerStepLocation;

  /// No description provided for @registerStepLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in your contact details to continue'**
  String get registerStepLocationSubtitle;

  /// No description provided for @registerStepBio.
  ///
  /// In en, this message translates to:
  /// **'Your Professional Experience'**
  String get registerStepBio;

  /// No description provided for @registerStepBioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell future clients about your background, specialty and experience to stand out.'**
  String get registerStepBioSubtitle;

  /// No description provided for @registerStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Showcase Your Work'**
  String get registerStepPhotos;

  /// No description provided for @registerStepPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your profile photo and past work photos to build trust with clients.'**
  String get registerStepPhotosSubtitle;

  /// No description provided for @registerStepDocs.
  ///
  /// In en, this message translates to:
  /// **'Identity Documents'**
  String get registerStepDocs;

  /// No description provided for @registerStepDocsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Next, upload a front and back photo of your ID Card'**
  String get registerStepDocsSubtitle;

  /// No description provided for @registerStepSummary.
  ///
  /// In en, this message translates to:
  /// **'Your Profile is Ready!'**
  String get registerStepSummary;

  /// No description provided for @registerStepSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your registration summary before activating your professional profile on ClanShip.'**
  String get registerStepSummarySubtitle;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get registerEmailHint;

  /// No description provided for @registerRepeatEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat email'**
  String get registerRepeatEmailHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordHint;

  /// No description provided for @registerRepeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get registerRepeatPasswordHint;

  /// No description provided for @registerFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get registerFirstNameHint;

  /// No description provided for @registerLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get registerLastNameHint;

  /// No description provided for @registerBirthdateHint.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get registerBirthdateHint;

  /// No description provided for @registerAddressHint.
  ///
  /// In en, this message translates to:
  /// **'My address'**
  String get registerAddressHint;

  /// No description provided for @registerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registerPhoneHint;

  /// No description provided for @registerTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Tags'**
  String get registerTagsTitle;

  /// No description provided for @registerTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No specialties selected. Select at least one to continue.'**
  String get registerTagsEmpty;

  /// No description provided for @registerTagsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} specialties selected.'**
  String registerTagsSelectedCount(int count);

  /// No description provided for @registerTagsButton.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get registerTagsButton;

  /// No description provided for @registerTermsAccept.
  ///
  /// In en, this message translates to:
  /// **'Read terms and conditions of use'**
  String get registerTermsAccept;

  /// No description provided for @registerTermsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By registering you accept our\nTerms & Conditions and Privacy Policy'**
  String get registerTermsAgreement;

  /// No description provided for @registerPhotoFront.
  ///
  /// In en, this message translates to:
  /// **'+ Front Photo'**
  String get registerPhotoFront;

  /// No description provided for @registerPhotoFrontAttached.
  ///
  /// In en, this message translates to:
  /// **'Front Attached ✓'**
  String get registerPhotoFrontAttached;

  /// No description provided for @registerPhotoBack.
  ///
  /// In en, this message translates to:
  /// **'+ Back Photo'**
  String get registerPhotoBack;

  /// No description provided for @registerPhotoBackAttached.
  ///
  /// In en, this message translates to:
  /// **'Back Attached ✓'**
  String get registerPhotoBackAttached;

  /// No description provided for @registerCedulaAttached.
  ///
  /// In en, this message translates to:
  /// **'ID Card Attached'**
  String get registerCedulaAttached;

  /// No description provided for @registerTradeProofHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a document proving your trade/profession\n(If you don\'t have one, you can skip this step)'**
  String get registerTradeProofHint;

  /// No description provided for @registerUploadDocsOptional.
  ///
  /// In en, this message translates to:
  /// **'+ Upload Documents (optional)'**
  String get registerUploadDocsOptional;

  /// No description provided for @registerDocNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get registerDocNameDialogTitle;

  /// No description provided for @registerDocNameDialogHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Technical Degree, Certification'**
  String get registerDocNameDialogHint;

  /// No description provided for @registerBioTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick suggestion templates:'**
  String get registerBioTemplatesTitle;

  /// No description provided for @registerBioElectrician.
  ///
  /// In en, this message translates to:
  /// **'Certified electrician with over 5 years of experience in residential installations, breaker panels and guaranteed emergency repairs.'**
  String get registerBioElectrician;

  /// No description provided for @registerBioPlumber.
  ///
  /// In en, this message translates to:
  /// **'Specialist in plumbing, leaks, water heaters and drain cleaning. Fast response and guaranteed work.'**
  String get registerBioPlumber;

  /// No description provided for @registerBioPainter.
  ///
  /// In en, this message translates to:
  /// **'Technician in interior and exterior painting and fine finishes. Committed to cleanliness and punctuality.'**
  String get registerBioPainter;

  /// No description provided for @registerBioHint.
  ///
  /// In en, this message translates to:
  /// **'Example: I have been providing repair and installation services for 8 years. I stand out for punctuality, transparent quotes and warranty on work done...'**
  String get registerBioHint;

  /// No description provided for @registerProfilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo '**
  String get registerProfilePhotoTitle;

  /// No description provided for @registerProfilePhotoMandatory.
  ///
  /// In en, this message translates to:
  /// **'* (Required)'**
  String get registerProfilePhotoMandatory;

  /// No description provided for @registerProfilePhotoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded ✓'**
  String get registerProfilePhotoUploaded;

  /// No description provided for @registerProfilePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear photo where your face is easily visible (it will be evaluated for profile verification).'**
  String get registerProfilePhotoDesc;

  /// No description provided for @registerWorkGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Past Work Gallery'**
  String get registerWorkGalleryTitle;

  /// No description provided for @registerWorkPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/6 photos'**
  String registerWorkPhotosCount(int count);

  /// No description provided for @registerAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get registerAddPhoto;

  /// No description provided for @registerSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your information'**
  String get registerSummaryTitle;

  /// No description provided for @registerSummarySelectedTags.
  ///
  /// In en, this message translates to:
  /// **'Selected specialties:'**
  String get registerSummarySelectedTags;

  /// No description provided for @registerSummaryBio.
  ///
  /// In en, this message translates to:
  /// **'Biography / Experience:'**
  String get registerSummaryBio;

  /// No description provided for @registerSummaryNoBio.
  ///
  /// In en, this message translates to:
  /// **'No biography entered'**
  String get registerSummaryNoBio;

  /// No description provided for @registerSummaryWorkPhotos.
  ///
  /// In en, this message translates to:
  /// **'📷 Work photos: {count}'**
  String registerSummaryWorkPhotos(int count);

  /// No description provided for @registerSummaryIdCard.
  ///
  /// In en, this message translates to:
  /// **'📄 ID: {status}'**
  String registerSummaryIdCard(String status);

  /// No description provided for @registerSummaryIdCardLoaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded ✓'**
  String get registerSummaryIdCardLoaded;

  /// No description provided for @registerSummaryIdCardPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get registerSummaryIdCardPending;

  /// No description provided for @registerCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get registerCompleteButton;

  /// No description provided for @registerErrorFillAll.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get registerErrorFillAll;

  /// No description provided for @registerErrorNameLength.
  ///
  /// In en, this message translates to:
  /// **'First name cannot exceed 30 characters.'**
  String get registerErrorNameLength;

  /// No description provided for @registerErrorLastNameLength.
  ///
  /// In en, this message translates to:
  /// **'Last name cannot exceed 30 characters.'**
  String get registerErrorLastNameLength;

  /// No description provided for @registerErrorEmailMismatch.
  ///
  /// In en, this message translates to:
  /// **'Email addresses do not match.'**
  String get registerErrorEmailMismatch;

  /// No description provided for @registerErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get registerErrorEmailInvalid;

  /// No description provided for @registerErrorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerErrorPasswordLength;

  /// No description provided for @registerErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerErrorPasswordMismatch;

  /// No description provided for @registerErrorEmailRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email address is already registered. Please log in or use another email.'**
  String get registerErrorEmailRegistered;

  /// No description provided for @registerErrorPhoneRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered by another user. Please use another number.'**
  String get registerErrorPhoneRegistered;

  /// No description provided for @registerErrorCedulaMissing.
  ///
  /// In en, this message translates to:
  /// **'Please upload the front and back photo of your ID Card.'**
  String get registerErrorCedulaMissing;

  /// No description provided for @registerErrorAvatarMissing.
  ///
  /// In en, this message translates to:
  /// **'You must upload a clear profile photo of your face. It is required for profile verification.'**
  String get registerErrorAvatarMissing;

  /// No description provided for @registerErrorAgeRestriction.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to register.'**
  String get registerErrorAgeRestriction;

  /// No description provided for @registerPickImageError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, could not select the image.'**
  String get registerPickImageError;

  /// No description provided for @registerPickWorkPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the work image.'**
  String get registerPickWorkPhotoError;

  /// No description provided for @registerLoadingTags.
  ///
  /// In en, this message translates to:
  /// **'Loading service tags...'**
  String get registerLoadingTags;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a verification code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get forgotPasswordSendCode;

  /// No description provided for @forgotPasswordEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get forgotPasswordEnterOtp;

  /// No description provided for @forgotPasswordVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get forgotPasswordVerifyCode;

  /// No description provided for @forgotPasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get forgotPasswordNewPassword;

  /// No description provided for @forgotPasswordConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get forgotPasswordConfirmNewPassword;

  /// No description provided for @forgotPasswordResetButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get forgotPasswordResetButton;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Updated!'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully reset. You can now log in.'**
  String get forgotPasswordSuccessDesc;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @mapSearchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get mapSearchAddressHint;

  /// No description provided for @mapCurrentGpsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Current GPS'**
  String get mapCurrentGpsTooltip;

  /// No description provided for @mapSelectLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Select a location'**
  String get mapSelectLocationHint;

  /// No description provided for @mapConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get mapConfirmLocation;

  /// No description provided for @mapGpsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Current GPS'**
  String get mapGpsDialogTitle;

  /// No description provided for @mapGpsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This feature uses your device\'s GPS sensor to get your real-time geographic location, center the map on your exact coordinates, and auto-complete the address.'**
  String get mapGpsDialogContent;

  /// No description provided for @mapPinAddressDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Address'**
  String get mapPinAddressDialogTitle;

  /// No description provided for @mapPinAddressDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Confirm and save the exact point selected on the map as your registered address or primary service location.'**
  String get mapPinAddressDialogContent;

  /// No description provided for @mapPinAddressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Information about Setting Address'**
  String get mapPinAddressTooltip;

  /// No description provided for @commonUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonUnderstood;

  /// No description provided for @settingsAvatarUploadError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the photo could not be uploaded.'**
  String get settingsAvatarUploadError;

  /// No description provided for @settingsAvatarUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully'**
  String get settingsAvatarUploadSuccess;

  /// No description provided for @settingsNotAuthenticatedError.
  ///
  /// In en, this message translates to:
  /// **'Error: Not authenticated'**
  String get settingsNotAuthenticatedError;

  /// No description provided for @settingsAvatarProcessError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the photo could not be processed.'**
  String get settingsAvatarProcessError;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsStatusValidated.
  ///
  /// In en, this message translates to:
  /// **'✓ Verified'**
  String get settingsStatusValidated;

  /// No description provided for @settingsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'❌ Rejected'**
  String get settingsStatusRejected;

  /// No description provided for @settingsStatusInProcess.
  ///
  /// In en, this message translates to:
  /// **'⌛ In progress'**
  String get settingsStatusInProcess;

  /// No description provided for @settingsSectionOtherSecurity.
  ///
  /// In en, this message translates to:
  /// **'Other & Security'**
  String get settingsSectionOtherSecurity;

  /// No description provided for @settingsReportContent.
  ///
  /// In en, this message translates to:
  /// **'Report content or problem'**
  String get settingsReportContent;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsFooterVersion.
  ///
  /// In en, this message translates to:
  /// **'Clanship Professional v{version} (Build {buildNumber})'**
  String settingsFooterVersion(String version, String buildNumber);

  /// No description provided for @settingsDefaultDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Tradesman'**
  String get settingsDefaultDisplayName;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your provider account?\n\nThis action is permanent and irreversible. Your profile data, certifications, and history will be deleted according to our privacy policy.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsAccountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get settingsAccountDeletedSuccess;

  /// No description provided for @settingsReportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Content or Problem'**
  String get settingsReportDialogTitle;

  /// No description provided for @settingsReportDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the reason for the report so our team can review it:'**
  String get settingsReportDialogSubtitle;

  /// No description provided for @settingsReportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate or offensive content'**
  String get settingsReportReasonInappropriate;

  /// No description provided for @settingsReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or fake request'**
  String get settingsReportReasonSpam;

  /// No description provided for @settingsReportReasonPhotoProblem.
  ///
  /// In en, this message translates to:
  /// **'Photo or document issue'**
  String get settingsReportReasonPhotoProblem;

  /// No description provided for @settingsReportReasonCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright violation'**
  String get settingsReportReasonCopyright;

  /// No description provided for @settingsReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get settingsReportReasonOther;

  /// No description provided for @settingsReportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get settingsReportDetailsHint;

  /// No description provided for @settingsReportSubmitBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get settingsReportSubmitBtn;

  /// No description provided for @settingsReportSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully. Our team will review the information within 24 hours.'**
  String get settingsReportSubmittedSuccess;

  /// No description provided for @verificationModalRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Rejected'**
  String get verificationModalRejectedTitle;

  /// No description provided for @verificationModalRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your application was not approved due to the following observation:\n\n\"{reason}\"\n\nYou can upload or replace your documents to request validation again.'**
  String verificationModalRejectedBody(String reason);

  /// No description provided for @verificationModalRejectedBtn.
  ///
  /// In en, this message translates to:
  /// **'Resolve observations and resubmit'**
  String get verificationModalRejectedBtn;

  /// No description provided for @homeRegistrationObservedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Your registration has been observed{reasonText}. Please upload new documents.'**
  String homeRegistrationObservedSnackBar(String reasonText);

  /// No description provided for @homeNotifNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get homeNotifNewRequest;

  /// No description provided for @homeNotifJobUpdated.
  ///
  /// In en, this message translates to:
  /// **'Job Updated'**
  String get homeNotifJobUpdated;

  /// No description provided for @homeNotifNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get homeNotifNewMessage;

  /// No description provided for @homeNotifDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'You have a job update'**
  String get homeNotifDefaultBody;

  /// No description provided for @homeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotificationsTitle;

  /// No description provided for @homeClearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get homeClearAllNotifications;

  /// No description provided for @homeNoNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications'**
  String get homeNoNewNotifications;

  /// No description provided for @homeGpsDisabledError.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled on the device.'**
  String get homeGpsDisabledError;

  /// No description provided for @homeGpsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get homeGpsPermissionDenied;

  /// No description provided for @homeGpsPermissionDeniedPermanent.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Enable it in system settings.'**
  String get homeGpsPermissionDeniedPermanent;

  /// No description provided for @homeGpsLocationFetchError.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location.'**
  String get homeGpsLocationFetchError;

  /// No description provided for @homeGpsCurrentLocationAddress.
  ///
  /// In en, this message translates to:
  /// **'Current GPS Location'**
  String get homeGpsCurrentLocationAddress;

  /// No description provided for @homeGpsUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'GPS location updated successfully.'**
  String get homeGpsUpdateSuccess;

  /// No description provided for @homeGenericError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, an error occurred. Please try again.'**
  String get homeGenericError;

  /// No description provided for @homeFixAddressSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fixed address updated successfully.'**
  String get homeFixAddressSuccess;

  /// No description provided for @homeGpsDialogInfoContent.
  ///
  /// In en, this message translates to:
  /// **'This option uses your device\'s real-time GPS sensor to detect your exact geographic location right now. It is ideal if you are in the field and want to receive jobs near your current physical position.'**
  String get homeGpsDialogInfoContent;

  /// No description provided for @homeUseMyGpsBtn.
  ///
  /// In en, this message translates to:
  /// **'Use my GPS'**
  String get homeUseMyGpsBtn;

  /// No description provided for @homePinAddressInfoContent.
  ///
  /// In en, this message translates to:
  /// **'This option allows you to select and set a static address on the map as your primary work base (for example, your home or workshop). That way you will receive requests in that sector without depending on your GPS location.'**
  String get homePinAddressInfoContent;

  /// No description provided for @homeSelectOnMapBtn.
  ///
  /// In en, this message translates to:
  /// **'Select on Map'**
  String get homeSelectOnMapBtn;

  /// No description provided for @homeNoAddressConfigured.
  ///
  /// In en, this message translates to:
  /// **'No address configured'**
  String get homeNoAddressConfigured;

  /// No description provided for @homeServiceAreaInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get homeServiceAreaInfoTitle;

  /// No description provided for @homeServiceAreaInfoGps.
  ///
  /// In en, this message translates to:
  /// **'• Current GPS: Uses your live GPS location to receive requests near where you are physically located.'**
  String get homeServiceAreaInfoGps;

  /// No description provided for @homeServiceAreaInfoPin.
  ///
  /// In en, this message translates to:
  /// **'• Set Address: Defines a fixed point or workshop on the map to receive requests in that sector permanently.'**
  String get homeServiceAreaInfoPin;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
