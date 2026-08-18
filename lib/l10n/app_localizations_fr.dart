// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Anti Gravity Tradesman';

  @override
  String get splashLoading => 'Chargement...';

  @override
  String get homeWelcomePrefix => 'Bonjour,';

  @override
  String get homeRatingLabel => 'Ma note';

  @override
  String get homeReviewsText => 'avis';

  @override
  String get homeServicesLink => 'Services';

  @override
  String get homeStatsActive => 'Demandes\nde travail';

  @override
  String get homeStatsCompleted => 'Demandes\nterminées';

  @override
  String get homeStatsRejected => 'Demandes\nrefusées';

  @override
  String get homeStatsScheduled => 'Demandes\nprogrammées';

  @override
  String get homeAvailabilityTitle => 'Statut de disponibilité';

  @override
  String get homeAvailabilitySubtitle =>
      'Contrôlez quand vous pouvez recevoir des demandes';

  @override
  String get homeRecentRequestsTitle => 'Demandes récentes';

  @override
  String get homeGoToRequestAction => 'Voir la demande';

  @override
  String get profileWhoAmI => 'Qui suis-je';

  @override
  String get profileProfessionalProfile => 'Profil professionnel';

  @override
  String get profileEdit => 'Modifier';

  @override
  String get profileServices => 'Services';

  @override
  String get profileServicesSubtitle =>
      'Les types de travaux que vous proposez';

  @override
  String get profileServiceTags => 'Vos étiquettes de service';

  @override
  String get profileAddServiceTag =>
      'Voulez-vous ajouter une autre étiquette ?';

  @override
  String get profileSearchTags => 'Rechercher des étiquettes';

  @override
  String get profileMaxTagsHint =>
      'Vous pouvez avoir un maximum de 6 étiquettes.';

  @override
  String get profilePhotosVideos => 'Photos de vos travaux';

  @override
  String get profilePlanReminder => 'Il vous reste';

  @override
  String get profileDays => 'Jours';

  @override
  String get profilePlanSuffix => 'de votre forfait';

  @override
  String get profileWorkingRadiusTitle => 'Rayon d\'intervention';

  @override
  String get profileWorkingRadiusSubtitle =>
      'distance maximale d\'intervention selon la position des clients';

  @override
  String get profileDistance => 'Distance';

  @override
  String get profileKm => 'Km';

  @override
  String get requestUrgentTitle => 'Demande urgente';

  @override
  String get requestContactClient => 'Contactez le client pour plus de détails';

  @override
  String get requestClientInfo => 'Informations du client';

  @override
  String get requestUserLabel => 'Utilisateur :';

  @override
  String get requestPhoneLabel => 'Téléphone :';

  @override
  String get requestAddressLabel => 'Adresse :';

  @override
  String get requestGoToMaps => 'ouvrir Google Maps';

  @override
  String get requestGoToWaze => 'ouvrir Waze';

  @override
  String get requestGoToChat => 'Aller au chat';

  @override
  String get requestReminderTitle => 'Rappel';

  @override
  String get requestReminderTip1 =>
      'Assurez-vous de confirmer la date et l\'heure avec le client';

  @override
  String get requestReminderTip2 =>
      'Vérifiez que vous avez les outils nécessaires';

  @override
  String get requestReminderTip3 => 'Soyez ponctuel au rendez-vous programmé';

  @override
  String get requestReminderTip4 =>
      'Convenez du prix au préalable avec le client';

  @override
  String get completedTitle => 'Terminées';

  @override
  String get completedFilterPrefix => 'Cette';

  @override
  String get completedFilterSuffix => 'vous avez terminé :';

  @override
  String get completedWeek => 'Semaine';

  @override
  String get completedMonth => 'Mois';

  @override
  String get completedYear => 'Année';

  @override
  String get completedJobsLabel => 'Travaux';

  @override
  String get completedGeneratedLabel => 'générés';

  @override
  String get completedSectionTitle => 'Travaux terminés :';

  @override
  String get completedUrgentTag => 'Urgent';

  @override
  String get profileLinkSocial => 'Lier les réseaux sociaux';

  @override
  String get profileClientReviews => 'Avis des clients';

  @override
  String get profileViewDocuments => 'Visualisation des documents';

  @override
  String get docsTitle => 'Documents ou Certificats';

  @override
  String get docsSubtitle =>
      'Vous pouvez activer ou désactiver la visibilité de vos documents sur votre profil public';

  @override
  String get docsIdCard => 'Carte d\'identité';

  @override
  String get docsIdCardFront => 'Carte d\'identité (Recto)';

  @override
  String get docsIdCardBack => 'Carte d\'identité (Verso)';

  @override
  String get docsDriverLicense => 'Permis de conduire';

  @override
  String get docsAdd => '+ Ajouter des documents';

  @override
  String get docsFooter => 'Ici vous pouvez ajouter vos documents ou diplômes';

  @override
  String get docsStatusApproved => 'Validé';

  @override
  String get docsStatusRejected => 'Refusé';

  @override
  String get docsStatusPending => 'En attente de validation';

  @override
  String docsRejectionReason(String reason) {
    return 'Motif : $reason';
  }

  @override
  String get docsVisiblePublicProfile => 'Visible sur le profil public';

  @override
  String get docsAddTitle => 'Ajouter un document';

  @override
  String get docsAddInputLabel => 'Nom du document/titre';

  @override
  String get docsAddInputHint => 'ex. Certificat SEC, Diplôme technique';

  @override
  String get docsAddNameError => 'Veuillez saisir un nom pour le document';

  @override
  String get verificationModalApprovedTitle => 'Profil approuvé et validé';

  @override
  String get verificationModalPendingTitle => 'En cours de validation';

  @override
  String get verificationModalApprovedBody =>
      'Félicitations ! Votre profil professionnel a été vérifié. Vous disposez d\'un accès complet pour être actif, recevoir des demandes directes de clients et chiffrer des besoins spécifiques.';

  @override
  String get verificationModalPendingBody =>
      'Vos antécédents et documents sont en cours d\'examen par notre équipe administrative. Le processus prend entre 24 et 48 heures ouvrables. Pendant cette période, votre disponibilité et votre accès aux devis resteront restreints.';

  @override
  String get verificationModalApprovedBtn => 'Voir mes documents';

  @override
  String get verificationModalPendingBtn => 'Gérer mes documents';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPersonalInfo => 'Informations personnelles';

  @override
  String get settingsEditData => 'Modifier les données';

  @override
  String get settingsMyPlan => 'Mon Forfait';

  @override
  String get settingsMyDocs => 'Mes Documents';

  @override
  String get settingsVerificationStatus => 'Statut de vérification';

  @override
  String get settingsChooseLanguage => 'Choisir la langue';

  @override
  String get settingsSupport => 'Support technique';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get requestsTitle => 'Demandes actives';

  @override
  String get requestsTabPending => 'Demandes';

  @override
  String get requestsTabScheduled => 'Programmées';

  @override
  String get requestsNoPending => 'Aucune demande en attente.';

  @override
  String get requestsNoScheduled => 'Aucun travail programmé.';

  @override
  String get requestEnrichedDetailsTitle => 'Détails supplémentaires du client';

  @override
  String get requestScheduleVisit => 'Planifier une visite';

  @override
  String get requestRescheduleVisit => 'Replanifier la visite';

  @override
  String get requestScheduleLeadTitle => 'Délai de préavis';

  @override
  String get requestScheduleLeadBody =>
      'Combien de temps à l\'avance souhaitez-vous envoyer la notification de rappel ?';

  @override
  String get requestSchedule15Mins => '15 minutes avant';

  @override
  String get requestSchedule30Mins => '30 minutes avant';

  @override
  String get requestSchedule1Hour => '1 heure avant';

  @override
  String get requestSchedule2Hours => '2 heures avant';

  @override
  String get requestSchedule3Hours => '3 heures avant';

  @override
  String get requestCancel => 'Annuler';

  @override
  String get requestConfirm => 'Confirmer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navRequests => 'Demandes';

  @override
  String get navSearch => 'Recherches';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get homePendingValidationTitle => 'En cours de validation';

  @override
  String get homePendingValidationMessage =>
      'Votre compte est en cours d\'examen par l\'équipe administrative. Une fois approuvé, vous pourrez activer votre disponibilité.';

  @override
  String get homeRejectedValidationTitle => 'Inscription Rejetée / À Réviser';

  @override
  String get homeRejectedValidationSubtitle =>
      'Votre demande n\'a pas pu être validée en raison de remarques sur vos documents ou photos :';

  @override
  String get homeRejectedReasonLabel => 'Motif du rejet :';

  @override
  String get homeRejectedReuploadBtn =>
      'Mettre à jour les documents et soumettre à nouveau';

  @override
  String get homeServiceAreaTitle => 'Ma zone de service / Emplacement';

  @override
  String get homeCoordinatesLabel => 'Coordonnées';

  @override
  String get homeGpsActualBtn => 'GPS Actuel';

  @override
  String get homeFixAddressBtn => 'Définir l\'adresse';

  @override
  String get planSelect => 'Choisir ce forfait';

  @override
  String get planActive => 'Actif';

  @override
  String get planFree => 'Gratuit';

  @override
  String get planDurationDays => 'jours';

  @override
  String get planTitle => 'Forfaits d\'abonnement';

  @override
  String get planCurrentTitle => 'Votre forfait actuel';

  @override
  String get planAvailableTitle => 'Forfaits disponibles';

  @override
  String get planUpgradeSuccess => 'Forfait mis à jour avec succès !';

  @override
  String get loginTitle => 'Bienvenue Spécialiste';

  @override
  String get loginEmailLabel => 'Adresse e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSignInButton => 'Se connecter';

  @override
  String get loginInvalidCredentials => 'Email ou mot de passe incorrect';

  @override
  String get loginChangeLanguage => 'Langue';

  @override
  String get loginSloganPrefix => 'Votre réseau de confiance ';

  @override
  String get loginSloganSuffix => 'pour résoudre';

  @override
  String get loginConceptTrust => 'Confiance';

  @override
  String get loginConceptTrustDesc => 'Vérification\net sécurité';

  @override
  String get loginConceptSpeed => 'Rapidité';

  @override
  String get loginConceptSpeedDesc => 'Réponse\nimmédiate';

  @override
  String get loginConceptConnection => 'Connexion';

  @override
  String get loginConceptConnectionDesc => 'Des pros qui\nrésolvent';

  @override
  String get loginBenefitVerified => 'Spécialistes\nvérifiés';

  @override
  String get loginBenefitReviews => 'Avis\nréels';

  @override
  String get loginBenefitTracking => 'Suivi des\nservices';

  @override
  String get authSubtitle => 'Connectez-vous pour recevoir des demandes';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authNoAccount => 'Non inscrit comme spécialiste ?';

  @override
  String get authRegisterHere => 'S\'inscrire comme spécialiste';

  @override
  String get authRegisterTitle => 'Inscription Spécialiste';

  @override
  String get authPersonalData => 'Données personnelles';

  @override
  String get authProfessionalData => 'Profil professionnel';

  @override
  String get authDocuments => 'Documentation & Certificats';

  @override
  String get authFirstName => 'Prénom';

  @override
  String get authLastName => 'Nom';

  @override
  String get authBirthdate => 'Date de naissance';

  @override
  String get authRepeatEmail => 'Répéter l\'e-mail';

  @override
  String get authRepeatPassword => 'Répéter le mot de passe';

  @override
  String get authPhone => 'Téléphone de contact';

  @override
  String get authAddress => 'Adresse';

  @override
  String get authBio => 'Biographie / Description des services';

  @override
  String get authHourlyRate => 'Tarif horaire estimé (\$)';

  @override
  String get authServiceRadius => 'Rayon d\'intervention (km)';

  @override
  String get authProfilePhoto => 'Photo de profil obligatoire';

  @override
  String get authCamera => 'Prendre une photo avec l\'appareil';

  @override
  String get authGallery => 'Choisir dans la galerie';

  @override
  String get authNext => 'Suivant';

  @override
  String get authPrevious => 'Précédent';

  @override
  String get authCompleteRegister => 'Soumettre l\'inscription';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonAccept => 'Accepter';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get versionUpdateTitle => 'Mise à jour requise';

  @override
  String get versionUpdateMessage =>
      'Pour continuer à recevoir des demandes en toute sécurité, veuillez mettre à jour l\'application.';

  @override
  String get versionUpdateBtn => 'Mettre à jour sur le Store';

  @override
  String get sessionExpired =>
      'Votre session a été ouverte sur un autre appareil.';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerSubtitle => 'Créez votre compte pour commencer';

  @override
  String get registerStepPersonal => 'Données Personnelles';

  @override
  String get registerStepLocation => 'Emplacement et Contact';

  @override
  String get registerStepLocationSubtitle =>
      'Remplissez vos coordonnées pour continuer';

  @override
  String get registerStepBio => 'Votre Expérience Professionnelle';

  @override
  String get registerStepBioSubtitle =>
      'Parlez à vos futurs clients de votre parcours, spécialité et expérience pour vous démarquer.';

  @override
  String get registerStepPhotos => 'Montrez Votre Travail';

  @override
  String get registerStepPhotosSubtitle =>
      'Téléchargez votre photo de profil et vos réalisations pour inspirer confiance.';

  @override
  String get registerStepDocs => 'Documents d\'Identité';

  @override
  String get registerStepDocsSubtitle =>
      'Ensuite, téléchargez une photo recto et verso de votre Carte d\'Identité';

  @override
  String get registerStepSummary => 'Votre Profil est Prêt !';

  @override
  String get registerStepSummarySubtitle =>
      'Vérifiez le résumé de votre inscription avant d\'activer votre profil professionnel sur ClanShip.';

  @override
  String get registerEmailHint => 'Adresse email';

  @override
  String get registerRepeatEmailHint => 'Répétez l\'email';

  @override
  String get registerPasswordHint => 'Mot de passe';

  @override
  String get registerRepeatPasswordHint => 'Répétez le mot de passe';

  @override
  String get registerFirstNameHint => 'Prénom';

  @override
  String get registerLastNameHint => 'Nom';

  @override
  String get registerBirthdateHint => 'Date de Naissance';

  @override
  String get registerAddressHint => 'Mon adresse';

  @override
  String get registerPhoneHint => 'Numéro de téléphone';

  @override
  String get registerTagsTitle => 'Étiquettes de Service';

  @override
  String get registerTagsEmpty =>
      'Aucune spécialité sélectionnée. Sélectionnez-en au moins une pour continuer.';

  @override
  String registerTagsSelectedCount(int count) {
    return '$count spécialités sélectionnées.';
  }

  @override
  String get registerTagsButton => 'Sélectionner les Étiquettes';

  @override
  String get registerTermsAccept => 'Lire les conditions d\'utilisation';

  @override
  String get registerTermsAgreement =>
      'En vous inscrivant, vous acceptez nos\nConditions Générales et Politique de Confidentialité';

  @override
  String get registerPhotoFront => '+ Photo Recto';

  @override
  String get registerPhotoFrontAttached => 'Recto Joint ✓';

  @override
  String get registerPhotoBack => '+ Photo Verso';

  @override
  String get registerPhotoBackAttached => 'Verso Joint ✓';

  @override
  String get registerCedulaAttached => 'Carte d\'Identité Jointe';

  @override
  String get registerTradeProofHint =>
      'Téléchargez un document prouvant votre métier/profession\n(Si vous n\'en avez pas, vous pouvez ignorer cette étape)';

  @override
  String get registerUploadDocsOptional =>
      '+ Télécharger des documents (facultatif)';

  @override
  String get registerDocNameDialogTitle => 'Nom du Document';

  @override
  String get registerDocNameDialogHint =>
      'ex. Diplôme technique, Certification';

  @override
  String get registerBioTemplatesTitle => 'Modèles de suggestion rapide :';

  @override
  String get registerBioElectrician =>
      'Électricien certifié avec plus de 5 ans d\'expérience dans les installations résidentielles, tableaux et dépannages d\'urgence garantis.';

  @override
  String get registerBioPlumber =>
      'Spécialiste en plomberie, fuites, chauffe-eau et débouchage. Intervention rapide et travaux garantis.';

  @override
  String get registerBioPainter =>
      'Artisan en peinture intérieure/extérieure et finitions soignées. Engagement de propreté et ponctualité.';

  @override
  String get registerBioHint =>
      'Exemple : J\'offre des services de dépannage et d\'installation depuis 8 ans. Ponctualité, devis clairs et garantie...';

  @override
  String get registerProfilePhotoTitle => 'Photo de Profil ';

  @override
  String get registerProfilePhotoMandatory => '* (Obligatoire)';

  @override
  String get registerProfilePhotoUploaded => 'Photo téléchargée ✓';

  @override
  String get registerProfilePhotoDesc =>
      'Téléchargez une photo claire de votre visage (elle sera évaluée pour la validation de votre profil).';

  @override
  String get registerWorkGalleryTitle => 'Galerie de Réalisations';

  @override
  String registerWorkPhotosCount(int count) {
    return '$count/6 photos';
  }

  @override
  String get registerAddPhoto => 'Ajouter';

  @override
  String get registerSummaryTitle => 'Vérifiez vos informations';

  @override
  String get registerSummarySelectedTags => 'Spécialités sélectionnées :';

  @override
  String get registerSummaryBio => 'Biographie / Expérience :';

  @override
  String get registerSummaryNoBio => 'Aucune biographie rédigée';

  @override
  String registerSummaryWorkPhotos(int count) {
    return '📷 Photos de travaux : $count';
  }

  @override
  String registerSummaryIdCard(String status) {
    return '📄 Carte d\'identité : $status';
  }

  @override
  String get registerSummaryIdCardLoaded => 'Téléchargée ✓';

  @override
  String get registerSummaryIdCardPending => 'En attente';

  @override
  String get registerCompleteButton => 'Terminer l\'Inscription';

  @override
  String get registerErrorFillAll => 'Veuillez remplir tous les champs.';

  @override
  String get registerErrorNameLength =>
      'Le prénom ne peut pas dépasser 30 caractères.';

  @override
  String get registerErrorLastNameLength =>
      'Le nom ne peut pas dépasser 30 caractères.';

  @override
  String get registerErrorEmailMismatch =>
      'Les adresses email ne correspondent pas.';

  @override
  String get registerErrorEmailInvalid =>
      'Veuillez entrer une adresse email valide.';

  @override
  String get registerErrorPasswordLength =>
      'Le mot de passe doit comporter au moins 6 caractères.';

  @override
  String get registerErrorPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get registerErrorEmailRegistered =>
      'Cet email est déjà enregistré. Veuillez vous connecter ou utiliser un autre email.';

  @override
  String get registerErrorPhoneRegistered =>
      'Ce numéro de téléphone est déjà enregistré par un autre utilisateur. Veuillez en utiliser un autre.';

  @override
  String get registerErrorCedulaMissing =>
      'Veuillez télécharger la photo recto et verso de votre Carte d\'Identité.';

  @override
  String get registerErrorAvatarMissing =>
      'Vous devez télécharger une photo de profil claire de votre visage. Elle est obligatoire pour la validation.';

  @override
  String get registerErrorAgeRestriction =>
      'Vous devez avoir au moins 18 ans pour vous inscrire.';

  @override
  String get registerPickImageError =>
      'Désolé, impossible de sélectionner l\'image.';

  @override
  String get registerPickWorkPhotoError =>
      'Impossible de charger l\'image du travail.';

  @override
  String get registerLoadingTags => 'Chargement des étiquettes de service...';

  @override
  String get forgotPasswordTitle => 'Récupérer le Mot de Passe';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre email pour recevoir un code de vérification';

  @override
  String get forgotPasswordSendCode => 'Envoyer le Code';

  @override
  String get forgotPasswordEnterOtp =>
      'Entrez le code à 6 chiffres envoyé à votre email';

  @override
  String get forgotPasswordVerifyCode => 'Vérifier le Code';

  @override
  String get forgotPasswordNewPassword => 'Nouveau Mot de Passe';

  @override
  String get forgotPasswordConfirmNewPassword =>
      'Confirmer le Nouveau Mot de Passe';

  @override
  String get forgotPasswordResetButton => 'Changer le Mot de Passe';

  @override
  String get forgotPasswordSuccessTitle => 'Mot de Passe Mis à Jour !';

  @override
  String get forgotPasswordSuccessDesc =>
      'Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter.';

  @override
  String get forgotPasswordBackToLogin => 'Retour à la Connexion';

  @override
  String get mapSearchAddressHint => 'Rechercher une adresse...';

  @override
  String get mapCurrentGpsTooltip => 'GPS Actuel';

  @override
  String get mapSelectLocationHint => 'Sélectionnez un emplacement';

  @override
  String get mapConfirmLocation => 'Confirmer l\'emplacement';

  @override
  String get mapGpsDialogTitle => 'GPS Actuel';

  @override
  String get mapGpsDialogContent =>
      'Cette fonction utilise le capteur GPS de votre appareil pour obtenir votre position géographique en temps réel, centrer la carte sur vos coordonnées exactes et renseigner automatiquement l\'adresse.';

  @override
  String get mapPinAddressDialogTitle => 'Définir l\'adresse';

  @override
  String get mapPinAddressDialogContent =>
      'Confirmez et enregistrez le point exact sélectionné sur la carte comme votre adresse enregistrée ou lieu de service principal.';

  @override
  String get mapPinAddressTooltip =>
      'Informations sur la définition de l\'adresse';

  @override
  String get commonUnderstood => 'Compris';

  @override
  String get settingsAvatarUploadError =>
      'Désolé, la photo n\'a pas pu être téléchargée.';

  @override
  String get settingsAvatarUploadSuccess =>
      'Photo de profil mise à jour avec succès';

  @override
  String get settingsNotAuthenticatedError => 'Erreur : Non authentifié';

  @override
  String get settingsAvatarProcessError =>
      'Désolé, la photo n\'a pas pu être traitée.';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsSectionPreferences => 'Préférences';

  @override
  String get settingsStatusValidated => '✓ Vérifié';

  @override
  String get settingsStatusRejected => '❌ Rejeté';

  @override
  String get settingsStatusInProcess => '⌛ En cours';

  @override
  String get settingsSectionOtherSecurity => 'Autres & Sécurité';

  @override
  String get settingsReportContent => 'Signaler un contenu ou un problème';

  @override
  String get settingsAppVersion => 'Version de l\'application';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String settingsFooterVersion(String version, String buildNumber) {
    return 'Clanship Professionnel v$version (Build $buildNumber)';
  }

  @override
  String get settingsDefaultDisplayName => 'Artisan';

  @override
  String get settingsDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountBody =>
      'Êtes-vous sûr de vouloir supprimer votre compte de prestataire ?\n\nCette action est permanente et irréversible. Vos données de profil, certifications et historique seront supprimés conformément à notre politique de confidentialité.';

  @override
  String get settingsDeleteAccountConfirm => 'Supprimer définitivement';

  @override
  String get settingsAccountDeletedSuccess =>
      'Votre compte a été supprimé avec succès.';

  @override
  String get settingsReportDialogTitle => 'Signaler un contenu ou un problème';

  @override
  String get settingsReportDialogSubtitle =>
      'Sélectionnez le motif du signalement afin que notre équipe puisse l\'examiner :';

  @override
  String get settingsReportReasonInappropriate =>
      'Contenu inapproprié ou offensant';

  @override
  String get settingsReportReasonSpam => 'Spam ou demande frauduleuse';

  @override
  String get settingsReportReasonPhotoProblem =>
      'Problème de photo ou de document';

  @override
  String get settingsReportReasonCopyright => 'Violation des droits d\'auteur';

  @override
  String get settingsReportReasonOther => 'Autre motif';

  @override
  String get settingsReportDetailsHint =>
      'Détails supplémentaires (facultatif)';

  @override
  String get settingsReportSubmitBtn => 'Envoyer le signalement';

  @override
  String get settingsReportSubmittedSuccess =>
      'Signalement envoyé avec succès. Notre équipe examinera les informations dans les 24 heures.';

  @override
  String get verificationModalRejectedTitle => 'Inscription rejetée';

  @override
  String verificationModalRejectedBody(String reason) {
    return 'Votre demande n\'a pas été approuvée pour la raison suivante :\n\n\"$reason\"\n\nVous pouvez télécharger ou remplacer vos documents pour demander à nouveau la validation.';
  }

  @override
  String get verificationModalRejectedBtn =>
      'Résoudre les remarques et renvoyer';

  @override
  String homeRegistrationObservedSnackBar(String reasonText) {
    return '⚠️ Votre inscription a été observée$reasonText. Veuillez télécharger de nouveaux documents.';
  }

  @override
  String get homeNotifNewRequest => 'Nouvelle Demande';

  @override
  String get homeNotifJobUpdated => 'Travail Mis à Jour';

  @override
  String get homeNotifNewMessage => 'Nouveau Message';

  @override
  String get homeNotifDefaultBody => 'Vous avez une mise à jour de travail';

  @override
  String get homeNotificationsTitle => 'Notifications';

  @override
  String get homeClearAllNotifications => 'Tout effacer';

  @override
  String get homeNoNewNotifications =>
      'Vous n\'avez pas de nouvelles notifications';

  @override
  String get homeGpsDisabledError =>
      'Les services de localisation sont désactivés sur l\'appareil.';

  @override
  String get homeGpsPermissionDenied => 'Autorisation de localisation refusée.';

  @override
  String get homeGpsPermissionDeniedPermanent =>
      'Autorisation de localisation refusée définitivement. Activez-la dans les paramètres système.';

  @override
  String get homeGpsLocationFetchError =>
      'Impossible d\'obtenir la localisation actuelle.';

  @override
  String get homeGpsCurrentLocationAddress => 'Position GPS actuelle';

  @override
  String get homeGpsUpdateSuccess => 'Position GPS mise à jour avec succès.';

  @override
  String get homeGenericError =>
      'Désolé, une erreur est survenue. Veuillez réessayer.';

  @override
  String get homeFixAddressSuccess => 'Adresse fixe mise à jour avec succès.';

  @override
  String get homeGpsDialogInfoContent =>
      'Cette option utilise le capteur GPS en temps réel de votre appareil pour détecter votre position géographique exacte en ce moment. C\'est idéal si vous êtes sur le terrain et souhaitez recevoir des travaux à proximité de votre position physique actuelle.';

  @override
  String get homeUseMyGpsBtn => 'Utiliser mon GPS';

  @override
  String get homePinAddressInfoContent =>
      'Cette option vous permet de sélectionner et de fixer une adresse statique sur la carte comme point de base de travail (par exemple votre domicile ou atelier). Ainsi, vous recevrez des demandes dans ce secteur sans dépendre de votre position GPS.';

  @override
  String get homeSelectOnMapBtn => 'Sélectionner sur la carte';

  @override
  String get homeNoAddressConfigured => 'Aucune adresse configurée';

  @override
  String get homeServiceAreaInfoTitle => 'Zone de Service';

  @override
  String get homeServiceAreaInfoGps =>
      '• GPS Actuel : Utilise votre position GPS en direct pour recevoir des demandes à proximité de votre emplacement physique.';

  @override
  String get homeServiceAreaInfoPin =>
      '• Définir l\'adresse : Définit un point fixe ou un atelier sur la carte pour recevoir des demandes dans ce secteur de manière permanente.';
}
