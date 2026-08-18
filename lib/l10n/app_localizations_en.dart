// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Anti Gravity Tradesman';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get homeWelcomePrefix => 'Hello,';

  @override
  String get homeRatingLabel => 'My Rating';

  @override
  String get homeReviewsText => 'reviews';

  @override
  String get homeServicesLink => 'Services';

  @override
  String get homeStatsActive => 'Job\nRequests';

  @override
  String get homeStatsCompleted => 'Completed\nRequests';

  @override
  String get homeStatsRejected => 'Rejected\nRequests';

  @override
  String get homeStatsScheduled => 'Scheduled\nRequests';

  @override
  String get homeAvailabilityTitle => 'Availability Status';

  @override
  String get homeAvailabilitySubtitle =>
      'Control when you can receive requests';

  @override
  String get homeRecentRequestsTitle => 'Recent Requests';

  @override
  String get homeGoToRequestAction => 'Go to request';

  @override
  String get profileWhoAmI => 'Who am I';

  @override
  String get profileProfessionalProfile => 'Professional profile';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileServices => 'Services';

  @override
  String get profileServicesSubtitle => 'The types of jobs you offer';

  @override
  String get profileServiceTags => 'Your service tags';

  @override
  String get profileAddServiceTag => 'Want to add another service tag?';

  @override
  String get profileSearchTags => 'Search Tags';

  @override
  String get profileMaxTagsHint => 'You can have a maximum of 6 service tags.';

  @override
  String get profilePhotosVideos => 'Photos/videos';

  @override
  String get profilePlanReminder => 'You have';

  @override
  String get profileDays => 'Days';

  @override
  String get profilePlanSuffix => 'of your plan';

  @override
  String get profileWorkingRadiusTitle => 'Work Radius';

  @override
  String get profileWorkingRadiusSubtitle =>
      'maximum working distance according to the location of the clients';

  @override
  String get profileDistance => 'Distance';

  @override
  String get profileKm => 'Km';

  @override
  String get requestUrgentTitle => 'Urgent request';

  @override
  String get requestContactClient =>
      'Contact the client for more details about the request';

  @override
  String get requestClientInfo => 'Client Information';

  @override
  String get requestUserLabel => 'User:';

  @override
  String get requestPhoneLabel => 'Phone:';

  @override
  String get requestAddressLabel => 'Address:';

  @override
  String get requestGoToMaps => 'go to Google Maps';

  @override
  String get requestGoToWaze => 'go to Waze';

  @override
  String get requestGoToChat => 'Go to chat';

  @override
  String get requestReminderTitle => 'Remember';

  @override
  String get requestReminderTip1 =>
      'Make sure to confirm the date and time with the client';

  @override
  String get requestReminderTip2 => 'Check that you have the necessary tools';

  @override
  String get requestReminderTip3 =>
      'Arrive on time for the scheduled appointment';

  @override
  String get requestReminderTip4 =>
      'Have agreed on the price previously with the client';

  @override
  String get completedTitle => 'Completed';

  @override
  String get completedFilterPrefix => 'In this';

  @override
  String get completedFilterSuffix => 'you have completed:';

  @override
  String get completedWeek => 'Week';

  @override
  String get completedMonth => 'Month';

  @override
  String get completedYear => 'Year';

  @override
  String get completedJobsLabel => 'Jobs';

  @override
  String get completedGeneratedLabel => 'generated';

  @override
  String get completedSectionTitle => 'Completed jobs:';

  @override
  String get completedUrgentTag => 'Urgent';

  @override
  String get profileLinkSocial => 'Link social networks';

  @override
  String get profileClientReviews => 'Client reviews';

  @override
  String get profileViewDocuments => 'Document visualization';

  @override
  String get docsTitle => 'Documents or Certificates';

  @override
  String get docsSubtitle =>
      'You can activate or deactivate the visibility of your documents on your public profile';

  @override
  String get docsIdCard => 'ID Card';

  @override
  String get docsIdCardFront => 'ID Card (Front)';

  @override
  String get docsIdCardBack => 'ID Card (Back)';

  @override
  String get docsDriverLicense => 'Driver\'s License';

  @override
  String get docsAdd => '+ Add Documents';

  @override
  String get docsFooter =>
      'Here you can add your documents, certificates, or titles';

  @override
  String get docsStatusApproved => 'Validated';

  @override
  String get docsStatusRejected => 'Rejected';

  @override
  String get docsStatusPending => 'Pending validation';

  @override
  String docsRejectionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get docsVisiblePublicProfile => 'Visible on public profile';

  @override
  String get docsAddTitle => 'Add Document';

  @override
  String get docsAddInputLabel => 'Document Name/Title';

  @override
  String get docsAddInputHint => 'e.g. SEC Certificate, Technical Degree';

  @override
  String get docsAddNameError => 'Please enter a document name';

  @override
  String get verificationModalApprovedTitle => 'Profile Approved & Validated';

  @override
  String get verificationModalPendingTitle => 'In Validation Process';

  @override
  String get verificationModalApprovedBody =>
      'Congratulations! Your professional profile has been verified. You have full access to be active, receive direct requests from clients, and quote on specific requirements.';

  @override
  String get verificationModalPendingBody =>
      'Your background and documents are being reviewed by our administrative team. The process takes between 24 to 48 business hours. During this period your availability and access to quotes will remain restricted.';

  @override
  String get verificationModalApprovedBtn => 'View My Documents';

  @override
  String get verificationModalPendingBtn => 'Manage My Documents';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPersonalInfo => 'Personal Information';

  @override
  String get settingsEditData => 'Edit Data';

  @override
  String get settingsMyPlan => 'My Plan';

  @override
  String get settingsMyDocs => 'My Documents';

  @override
  String get settingsVerificationStatus => 'Verification Status';

  @override
  String get settingsChooseLanguage => 'Choose Language';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsTerms => 'Terms and conditions of use';

  @override
  String get requestsTitle => 'Active Requests';

  @override
  String get requestsTabPending => 'Requests';

  @override
  String get requestsTabScheduled => 'Scheduled';

  @override
  String get requestsNoPending => 'No pending requests.';

  @override
  String get requestsNoScheduled => 'No scheduled jobs.';

  @override
  String get requestEnrichedDetailsTitle => 'Additional Client Details';

  @override
  String get requestScheduleVisit => 'Schedule Visit';

  @override
  String get requestRescheduleVisit => 'Reschedule Visit';

  @override
  String get requestScheduleLeadTitle => 'Reminder lead time';

  @override
  String get requestScheduleLeadBody =>
      'How far in advance do you want to send the push reminder notification?';

  @override
  String get requestSchedule15Mins => '15 Minutes before';

  @override
  String get requestSchedule30Mins => '30 Minutes before';

  @override
  String get requestSchedule1Hour => '1 Hour before';

  @override
  String get requestSchedule2Hours => '2 Hours before';

  @override
  String get requestSchedule3Hours => '3 Hours before';

  @override
  String get requestCancel => 'Cancel';

  @override
  String get requestConfirm => 'Confirm';

  @override
  String get navHome => 'Home';

  @override
  String get navRequests => 'Requests';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get homePendingValidationTitle => 'In validation process';

  @override
  String get homePendingValidationMessage =>
      'Your account is being reviewed by the administrative team. Once approved you can activate your availability.';

  @override
  String get homeRejectedValidationTitle =>
      'Registration Rejected / Needs Review';

  @override
  String get homeRejectedValidationSubtitle =>
      'Your application could not be verified due to remarks on your documents or photos:';

  @override
  String get homeRejectedReasonLabel => 'Rejection reason:';

  @override
  String get homeRejectedReuploadBtn =>
      'Update documents and submit for review';

  @override
  String get homeServiceAreaTitle => 'My Service Area / Location';

  @override
  String get homeCoordinatesLabel => 'Coordinates';

  @override
  String get homeGpsActualBtn => 'Current GPS';

  @override
  String get homeFixAddressBtn => 'Set Address';

  @override
  String get planSelect => 'Select Plan';

  @override
  String get planActive => 'Active';

  @override
  String get planFree => 'Free';

  @override
  String get planDurationDays => 'days';

  @override
  String get planTitle => 'Subscription Plans';

  @override
  String get planCurrentTitle => 'Your Current Plan';

  @override
  String get planAvailableTitle => 'Available Plans';

  @override
  String get planUpgradeSuccess => 'Plan updated successfully!';

  @override
  String get loginTitle => 'Welcome Specialist';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String get loginInvalidCredentials => 'Invalid email or password';

  @override
  String get loginChangeLanguage => 'Language';

  @override
  String get loginSloganPrefix => 'Your trusted network ';

  @override
  String get loginSloganSuffix => 'to get things done';

  @override
  String get loginConceptTrust => 'Trust';

  @override
  String get loginConceptTrustDesc => 'Verification\n& safety';

  @override
  String get loginConceptSpeed => 'Speed';

  @override
  String get loginConceptSpeedDesc => 'Immediate\nresponse';

  @override
  String get loginConceptConnection => 'Connection';

  @override
  String get loginConceptConnectionDesc => 'People who\nsolve';

  @override
  String get loginBenefitVerified => 'Verified\nspecialists';

  @override
  String get loginBenefitReviews => 'Real\nreviews';

  @override
  String get loginBenefitTracking => 'Service\ntracking';

  @override
  String get authSubtitle => 'Sign in to receive client requests';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authNoAccount => 'Not registered as a specialist?';

  @override
  String get authRegisterHere => 'Register as Specialist';

  @override
  String get authRegisterTitle => 'Specialist Registration';

  @override
  String get authPersonalData => 'Personal Information';

  @override
  String get authProfessionalData => 'Professional Profile';

  @override
  String get authDocuments => 'Documentation & Certificates';

  @override
  String get authFirstName => 'First Name';

  @override
  String get authLastName => 'Last Name';

  @override
  String get authBirthdate => 'Date of Birth';

  @override
  String get authRepeatEmail => 'Repeat Email';

  @override
  String get authRepeatPassword => 'Repeat Password';

  @override
  String get authPhone => 'Contact Phone';

  @override
  String get authAddress => 'Address';

  @override
  String get authBio => 'Bio / Service Description';

  @override
  String get authHourlyRate => 'Estimated hourly rate (\$)';

  @override
  String get authServiceRadius => 'Service radius (km)';

  @override
  String get authProfilePhoto => 'Mandatory Profile Photo';

  @override
  String get authCamera => 'Take photo with camera';

  @override
  String get authGallery => 'Choose from gallery';

  @override
  String get authNext => 'Next';

  @override
  String get authPrevious => 'Previous';

  @override
  String get authCompleteRegister => 'Submit Registration';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonSave => 'Save';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get versionUpdateTitle => 'Update Required';

  @override
  String get versionUpdateMessage =>
      'To continue receiving job requests safely, please update the app to the latest version.';

  @override
  String get versionUpdateBtn => 'Update in App Store';

  @override
  String get sessionExpired => 'Your session was opened on another device.';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSubtitle => 'Create your account to get started';

  @override
  String get registerStepPersonal => 'Personal Info';

  @override
  String get registerStepLocation => 'Location & Contact';

  @override
  String get registerStepLocationSubtitle =>
      'Fill in your contact details to continue';

  @override
  String get registerStepBio => 'Your Professional Experience';

  @override
  String get registerStepBioSubtitle =>
      'Tell future clients about your background, specialty and experience to stand out.';

  @override
  String get registerStepPhotos => 'Showcase Your Work';

  @override
  String get registerStepPhotosSubtitle =>
      'Upload your profile photo and past work photos to build trust with clients.';

  @override
  String get registerStepDocs => 'Identity Documents';

  @override
  String get registerStepDocsSubtitle =>
      'Next, upload a front and back photo of your ID Card';

  @override
  String get registerStepSummary => 'Your Profile is Ready!';

  @override
  String get registerStepSummarySubtitle =>
      'Review your registration summary before activating your professional profile on ClanShip.';

  @override
  String get registerEmailHint => 'Email address';

  @override
  String get registerRepeatEmailHint => 'Repeat email';

  @override
  String get registerPasswordHint => 'Password';

  @override
  String get registerRepeatPasswordHint => 'Repeat password';

  @override
  String get registerFirstNameHint => 'First Name';

  @override
  String get registerLastNameHint => 'Last Name';

  @override
  String get registerBirthdateHint => 'Date of Birth';

  @override
  String get registerAddressHint => 'My address';

  @override
  String get registerPhoneHint => 'Phone number';

  @override
  String get registerTagsTitle => 'Service Tags';

  @override
  String get registerTagsEmpty =>
      'No specialties selected. Select at least one to continue.';

  @override
  String registerTagsSelectedCount(int count) {
    return '$count specialties selected.';
  }

  @override
  String get registerTagsButton => 'Select Tags';

  @override
  String get registerTermsAccept => 'Read terms and conditions of use';

  @override
  String get registerTermsAgreement =>
      'By registering you accept our\nTerms & Conditions and Privacy Policy';

  @override
  String get registerPhotoFront => '+ Front Photo';

  @override
  String get registerPhotoFrontAttached => 'Front Attached ✓';

  @override
  String get registerPhotoBack => '+ Back Photo';

  @override
  String get registerPhotoBackAttached => 'Back Attached ✓';

  @override
  String get registerCedulaAttached => 'ID Card Attached';

  @override
  String get registerTradeProofHint =>
      'Upload a document proving your trade/profession\n(If you don\'t have one, you can skip this step)';

  @override
  String get registerUploadDocsOptional => '+ Upload Documents (optional)';

  @override
  String get registerDocNameDialogTitle => 'Document Name';

  @override
  String get registerDocNameDialogHint =>
      'e.g. Technical Degree, Certification';

  @override
  String get registerBioTemplatesTitle => 'Quick suggestion templates:';

  @override
  String get registerBioElectrician =>
      'Certified electrician with over 5 years of experience in residential installations, breaker panels and guaranteed emergency repairs.';

  @override
  String get registerBioPlumber =>
      'Specialist in plumbing, leaks, water heaters and drain cleaning. Fast response and guaranteed work.';

  @override
  String get registerBioPainter =>
      'Technician in interior and exterior painting and fine finishes. Committed to cleanliness and punctuality.';

  @override
  String get registerBioHint =>
      'Example: I have been providing repair and installation services for 8 years. I stand out for punctuality, transparent quotes and warranty on work done...';

  @override
  String get registerProfilePhotoTitle => 'Profile Photo ';

  @override
  String get registerProfilePhotoMandatory => '* (Required)';

  @override
  String get registerProfilePhotoUploaded => 'Photo uploaded ✓';

  @override
  String get registerProfilePhotoDesc =>
      'Upload a clear photo where your face is easily visible (it will be evaluated for profile verification).';

  @override
  String get registerWorkGalleryTitle => 'Past Work Gallery';

  @override
  String registerWorkPhotosCount(int count) {
    return '$count/6 photos';
  }

  @override
  String get registerAddPhoto => 'Add';

  @override
  String get registerSummaryTitle => 'Review your information';

  @override
  String get registerSummarySelectedTags => 'Selected specialties:';

  @override
  String get registerSummaryBio => 'Biography / Experience:';

  @override
  String get registerSummaryNoBio => 'No biography entered';

  @override
  String registerSummaryWorkPhotos(int count) {
    return '📷 Work photos: $count';
  }

  @override
  String registerSummaryIdCard(String status) {
    return '📄 ID: $status';
  }

  @override
  String get registerSummaryIdCardLoaded => 'Uploaded ✓';

  @override
  String get registerSummaryIdCardPending => 'Pending';

  @override
  String get registerCompleteButton => 'Complete Registration';

  @override
  String get registerErrorFillAll => 'Please fill in all fields.';

  @override
  String get registerErrorNameLength =>
      'First name cannot exceed 30 characters.';

  @override
  String get registerErrorLastNameLength =>
      'Last name cannot exceed 30 characters.';

  @override
  String get registerErrorEmailMismatch => 'Email addresses do not match.';

  @override
  String get registerErrorEmailInvalid => 'Please enter a valid email address.';

  @override
  String get registerErrorPasswordLength =>
      'Password must be at least 6 characters.';

  @override
  String get registerErrorPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerErrorEmailRegistered =>
      'This email address is already registered. Please log in or use another email.';

  @override
  String get registerErrorPhoneRegistered =>
      'This phone number is already registered by another user. Please use another number.';

  @override
  String get registerErrorCedulaMissing =>
      'Please upload the front and back photo of your ID Card.';

  @override
  String get registerErrorAvatarMissing =>
      'You must upload a clear profile photo of your face. It is required for profile verification.';

  @override
  String get registerErrorAgeRestriction =>
      'You must be at least 18 years old to register.';

  @override
  String get registerPickImageError => 'Sorry, could not select the image.';

  @override
  String get registerPickWorkPhotoError => 'Could not load the work image.';

  @override
  String get registerLoadingTags => 'Loading service tags...';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a verification code';

  @override
  String get forgotPasswordSendCode => 'Send Code';

  @override
  String get forgotPasswordEnterOtp =>
      'Enter the 6-digit code sent to your email';

  @override
  String get forgotPasswordVerifyCode => 'Verify Code';

  @override
  String get forgotPasswordNewPassword => 'New Password';

  @override
  String get forgotPasswordConfirmNewPassword => 'Confirm New Password';

  @override
  String get forgotPasswordResetButton => 'Change Password';

  @override
  String get forgotPasswordSuccessTitle => 'Password Updated!';

  @override
  String get forgotPasswordSuccessDesc =>
      'Your password has been successfully reset. You can now log in.';

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get mapSearchAddressHint => 'Search address...';

  @override
  String get mapCurrentGpsTooltip => 'Current GPS';

  @override
  String get mapSelectLocationHint => 'Select a location';

  @override
  String get mapConfirmLocation => 'Confirm Location';

  @override
  String get mapGpsDialogTitle => 'Current GPS';

  @override
  String get mapGpsDialogContent =>
      'This feature uses your device\'s GPS sensor to get your real-time geographic location, center the map on your exact coordinates, and auto-complete the address.';

  @override
  String get mapPinAddressDialogTitle => 'Set Address';

  @override
  String get mapPinAddressDialogContent =>
      'Confirm and save the exact point selected on the map as your registered address or primary service location.';

  @override
  String get mapPinAddressTooltip => 'Information about Setting Address';

  @override
  String get commonUnderstood => 'Got it';

  @override
  String get settingsAvatarUploadError =>
      'Sorry, the photo could not be uploaded.';

  @override
  String get settingsAvatarUploadSuccess =>
      'Profile photo updated successfully';

  @override
  String get settingsNotAuthenticatedError => 'Error: Not authenticated';

  @override
  String get settingsAvatarProcessError =>
      'Sorry, the photo could not be processed.';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsStatusValidated => '✓ Verified';

  @override
  String get settingsStatusRejected => '❌ Rejected';

  @override
  String get settingsStatusInProcess => '⌛ In progress';

  @override
  String get settingsSectionOtherSecurity => 'Other & Security';

  @override
  String get settingsReportContent => 'Report content or problem';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String settingsFooterVersion(String version, String buildNumber) {
    return 'Clanship Professional v$version (Build $buildNumber)';
  }

  @override
  String get settingsDefaultDisplayName => 'Tradesman';

  @override
  String get settingsDeleteAccountTitle => 'Delete Account';

  @override
  String get settingsDeleteAccountBody =>
      'Are you sure you want to delete your provider account?\n\nThis action is permanent and irreversible. Your profile data, certifications, and history will be deleted according to our privacy policy.';

  @override
  String get settingsDeleteAccountConfirm => 'Delete permanently';

  @override
  String get settingsAccountDeletedSuccess =>
      'Your account has been deleted successfully.';

  @override
  String get settingsReportDialogTitle => 'Report Content or Problem';

  @override
  String get settingsReportDialogSubtitle =>
      'Select the reason for the report so our team can review it:';

  @override
  String get settingsReportReasonInappropriate =>
      'Inappropriate or offensive content';

  @override
  String get settingsReportReasonSpam => 'Spam or fake request';

  @override
  String get settingsReportReasonPhotoProblem => 'Photo or document issue';

  @override
  String get settingsReportReasonCopyright => 'Copyright violation';

  @override
  String get settingsReportReasonOther => 'Other reason';

  @override
  String get settingsReportDetailsHint => 'Additional details (optional)';

  @override
  String get settingsReportSubmitBtn => 'Submit Report';

  @override
  String get settingsReportSubmittedSuccess =>
      'Report submitted successfully. Our team will review the information within 24 hours.';

  @override
  String get verificationModalRejectedTitle => 'Registration Rejected';

  @override
  String verificationModalRejectedBody(String reason) {
    return 'Your application was not approved due to the following observation:\n\n\"$reason\"\n\nYou can upload or replace your documents to request validation again.';
  }

  @override
  String get verificationModalRejectedBtn =>
      'Resolve observations and resubmit';

  @override
  String homeRegistrationObservedSnackBar(String reasonText) {
    return '⚠️ Your registration has been observed$reasonText. Please upload new documents.';
  }

  @override
  String get homeNotifNewRequest => 'New Request';

  @override
  String get homeNotifJobUpdated => 'Job Updated';

  @override
  String get homeNotifNewMessage => 'New Message';

  @override
  String get homeNotifDefaultBody => 'You have a job update';

  @override
  String get homeNotificationsTitle => 'Notifications';

  @override
  String get homeClearAllNotifications => 'Clear all';

  @override
  String get homeNoNewNotifications => 'You have no new notifications';

  @override
  String get homeGpsDisabledError =>
      'Location services are disabled on the device.';

  @override
  String get homeGpsPermissionDenied => 'Location permission denied.';

  @override
  String get homeGpsPermissionDeniedPermanent =>
      'Location permission permanently denied. Enable it in system settings.';

  @override
  String get homeGpsLocationFetchError => 'Could not get current location.';

  @override
  String get homeGpsCurrentLocationAddress => 'Current GPS Location';

  @override
  String get homeGpsUpdateSuccess => 'GPS location updated successfully.';

  @override
  String get homeGenericError => 'Sorry, an error occurred. Please try again.';

  @override
  String get homeFixAddressSuccess => 'Fixed address updated successfully.';

  @override
  String get homeGpsDialogInfoContent =>
      'This option uses your device\'s real-time GPS sensor to detect your exact geographic location right now. It is ideal if you are in the field and want to receive jobs near your current physical position.';

  @override
  String get homeUseMyGpsBtn => 'Use my GPS';

  @override
  String get homePinAddressInfoContent =>
      'This option allows you to select and set a static address on the map as your primary work base (for example, your home or workshop). That way you will receive requests in that sector without depending on your GPS location.';

  @override
  String get homeSelectOnMapBtn => 'Select on Map';

  @override
  String get homeNoAddressConfigured => 'No address configured';

  @override
  String get homeServiceAreaInfoTitle => 'Service Area';

  @override
  String get homeServiceAreaInfoGps =>
      '• Current GPS: Uses your live GPS location to receive requests near where you are physically located.';

  @override
  String get homeServiceAreaInfoPin =>
      '• Set Address: Defines a fixed point or workshop on the map to receive requests in that sector permanently.';
}
