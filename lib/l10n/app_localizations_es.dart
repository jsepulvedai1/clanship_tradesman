// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Anti Gravity Tradesman';

  @override
  String get splashLoading => 'Cargando...';

  @override
  String get homeWelcomePrefix => '¡Hola,';

  @override
  String get homeRatingLabel => 'Mi calificación';

  @override
  String get homeReviewsText => 'reseñas';

  @override
  String get homeServicesLink => 'Servicios';

  @override
  String get homeStatsActive => 'Solicitudes\nde Trabajo';

  @override
  String get homeStatsCompleted => 'Solicitudes\nCompletadas';

  @override
  String get homeStatsRejected => 'Solicitudes\nRechazadas';

  @override
  String get homeStatsScheduled => 'Solicitudes\nProgramadas';

  @override
  String get homeAvailabilityTitle => 'Estado de disponibilidad';

  @override
  String get homeAvailabilitySubtitle =>
      'Controla cuándo puedes recibir solicitudes';

  @override
  String get homeRecentRequestsTitle => 'Solicitudes Recientes';

  @override
  String get homeGoToRequestAction => 'Ir a la solicitud';

  @override
  String get profileWhoAmI => 'Quien soy';

  @override
  String get profileProfessionalProfile => 'Cuéntanos sobre ti';

  @override
  String get profileEdit => 'Editar';

  @override
  String get profileServices => 'Servicios';

  @override
  String get profileServicesSubtitle => 'Los tipos de trabajos que ofreces';

  @override
  String get profileServiceTags => 'Tus etiquetas de servicio';

  @override
  String get profileAddServiceTag =>
      '¿Quieres agregar otra etiqueta de servicio?';

  @override
  String get profileSearchTags => 'Buscar Etiquetas';

  @override
  String get profileMaxTagsHint =>
      'Puedes tener un máximo de 6 etiquetas de servicios.';

  @override
  String get profilePhotosVideos => 'Fotos de tus trabajos';

  @override
  String get profilePlanReminder => 'Te quedan';

  @override
  String get profileDays => 'Días';

  @override
  String get profilePlanSuffix => 'de tu plan';

  @override
  String get profileWorkingRadiusTitle => 'Radio de trabajo';

  @override
  String get profileWorkingRadiusSubtitle =>
      'distancia máxima de trabajo de acuerdo a la ubicación de los clientes';

  @override
  String get profileDistance => 'Distancia';

  @override
  String get profileKm => 'Km';

  @override
  String get requestUrgentTitle => 'Solicitud urgente';

  @override
  String get requestContactClient =>
      'Ponte en contacto con el cliente para ver mayores detalles de la solicitud';

  @override
  String get requestClientInfo => 'Información del cliente';

  @override
  String get requestUserLabel => 'Usuario:';

  @override
  String get requestPhoneLabel => 'Teléfono:';

  @override
  String get requestAddressLabel => 'Dirección:';

  @override
  String get requestGoToMaps => 'ir a Google Maps';

  @override
  String get requestGoToWaze => 'ir a Waze';

  @override
  String get requestGoToChat => 'Ir al chat';

  @override
  String get requestReminderTitle => 'Recuerda';

  @override
  String get requestReminderTip1 =>
      'Asegurate de confirmar la fecha y hora con cliente';

  @override
  String get requestReminderTip2 =>
      'Verificar que tienes las herramientas necesarias';

  @override
  String get requestReminderTip3 => 'Llegar puntual a la cita programada';

  @override
  String get requestReminderTip4 =>
      'Haber pactado el precio previamente con el cliente';

  @override
  String get completedTitle => 'Completadas';

  @override
  String get completedFilterPrefix => 'En este/a';

  @override
  String get completedFilterSuffix => 'has completado:';

  @override
  String get completedWeek => 'Semana';

  @override
  String get completedMonth => 'Mes';

  @override
  String get completedYear => 'Año';

  @override
  String get completedJobsLabel => 'Trabajos';

  @override
  String get completedGeneratedLabel => 'generados';

  @override
  String get completedSectionTitle => 'Trabajos completados:';

  @override
  String get completedUrgentTag => 'Urgente';

  @override
  String get profileLinkSocial => 'Vincular redes sociales';

  @override
  String get profileClientReviews => 'Valoración de los clientes';

  @override
  String get profileViewDocuments => 'Visualización de documentos';

  @override
  String get docsTitle => 'Documentos o Certificados';

  @override
  String get docsSubtitle =>
      'Puedes activar o desactivar la visibilidad de tus documentos en tu perfil público';

  @override
  String get docsIdCard => 'Cédula de Identidad';

  @override
  String get docsIdCardFront => 'Cédula de Identidad (Frontal)';

  @override
  String get docsIdCardBack => 'Cédula de Identidad (Posterior)';

  @override
  String get docsDriverLicense => 'Licencia de Conducir';

  @override
  String get docsAdd => '+ Agregar Documentos';

  @override
  String get docsFooter =>
      'Aquí puedes agregar tus documentos, certificados o títulos';

  @override
  String get docsStatusApproved => 'Validado';

  @override
  String get docsStatusRejected => 'Rechazado';

  @override
  String get docsStatusPending => 'Pendiente de validación';

  @override
  String docsRejectionReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get docsVisiblePublicProfile => 'Visible en perfil público';

  @override
  String get docsAddTitle => 'Agregar Documento';

  @override
  String get docsAddInputLabel => 'Nombre del Documento/Título';

  @override
  String get docsAddInputHint => 'Ej: Certificado SEC, Título Técnico';

  @override
  String get docsAddNameError =>
      'Por favor ingresa un nombre para el documento';

  @override
  String get verificationModalApprovedTitle => 'Perfil Aprobado y Validado';

  @override
  String get verificationModalPendingTitle => 'En Proceso de Validación';

  @override
  String get verificationModalApprovedBody =>
      '¡Felicidades! Tu perfil profesional ha sido verificado. Cuentas con acceso completo para estar activo, recibir solicitudes directas de clientes y cotizar en la bolsa de requerimientos específicos.';

  @override
  String get verificationModalPendingBody =>
      'Tus antecedentes y documentos están en proceso de revisión por nuestro equipo administrativo. El proceso toma entre 24 a 48 horas laborables. Durante este periodo tu disponibilidad y acceso a cotizaciones permanecerán restringidos.';

  @override
  String get verificationModalApprovedBtn => 'Ver mis Documentos';

  @override
  String get verificationModalPendingBtn => 'Gestionar Mis Documentos';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsPersonalInfo => 'Información Personal';

  @override
  String get settingsEditData => 'Editar Datos';

  @override
  String get settingsMyPlan => 'Mi Plan';

  @override
  String get settingsMyDocs => 'Mis Documentos';

  @override
  String get settingsVerificationStatus => 'Estado de verificación';

  @override
  String get settingsChooseLanguage => 'Elegir idioma';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsDarkMode => 'Modo Oscuro';

  @override
  String get settingsTerms => 'Términos y condiciones de uso';

  @override
  String get requestsTitle => 'Solicitudes Activas';

  @override
  String get requestsTabPending => 'Solicitudes';

  @override
  String get requestsTabScheduled => 'Agendados';

  @override
  String get requestsNoPending => 'No hay solicitudes pendientes.';

  @override
  String get requestsNoScheduled => 'No hay trabajos agendados.';

  @override
  String get requestEnrichedDetailsTitle => 'Detalles Adicionales del Cliente';

  @override
  String get requestScheduleVisit => 'Agendar Visita';

  @override
  String get requestRescheduleVisit => 'Reprogramar Visita';

  @override
  String get requestScheduleLeadTitle => 'Tiempo de aviso previo';

  @override
  String get requestScheduleLeadBody =>
      '¿Con cuánto tiempo de anticipación deseas enviar la notificación push de recordatorio?';

  @override
  String get requestSchedule15Mins => '15 Minutos antes';

  @override
  String get requestSchedule30Mins => '30 Minutos antes';

  @override
  String get requestSchedule1Hour => '1 Hora antes';

  @override
  String get requestSchedule2Hours => '2 Horas antes';

  @override
  String get requestSchedule3Hours => '3 Horas antes';

  @override
  String get requestCancel => 'Cancelar';

  @override
  String get requestConfirm => 'Confirmar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navRequests => 'Solicitudes';

  @override
  String get navSearch => 'Busca';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get homePendingValidationTitle => 'En proceso de validación';

  @override
  String get homePendingValidationMessage =>
      'Tu cuenta está siendo revisada por el equipo administrativo. Una vez aprobada podrás activar tu disponibilidad.';

  @override
  String get homeRejectedValidationTitle => 'Registro Observado / Rechazado';

  @override
  String get homeRejectedValidationSubtitle =>
      'Tu solicitud no pudo ser validada debido a observaciones en tus antecedentes o fotos:';

  @override
  String get homeRejectedReasonLabel => 'Motivo del rechazo:';

  @override
  String get homeRejectedReuploadBtn =>
      'Actualizar documentos y reenviar a revisión';

  @override
  String get homeServiceAreaTitle => 'Mi Área de Servicio / Ubicación';

  @override
  String get homeCoordinatesLabel => 'Coordenadas';

  @override
  String get homeGpsActualBtn => 'GPS Actual';

  @override
  String get homeFixAddressBtn => 'Fijar Dirección';

  @override
  String get planSelect => 'Seleccionar Plan';

  @override
  String get planActive => 'Activo';

  @override
  String get planFree => 'Gratis';

  @override
  String get planDurationDays => 'días';

  @override
  String get planTitle => 'Planes de Suscripción';

  @override
  String get planCurrentTitle => 'Tu Plan Actual';

  @override
  String get planAvailableTitle => 'Planes Disponibles';

  @override
  String get planUpgradeSuccess => '¡Plan actualizado con éxito!';

  @override
  String get loginTitle => 'Bienvenido Maestro';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginSignInButton => 'Iniciar sesión';

  @override
  String get loginInvalidCredentials => 'Correo o contraseña incorrecta';

  @override
  String get loginChangeLanguage => 'Idioma';

  @override
  String get loginSloganPrefix => 'Tu red de confianza ';

  @override
  String get loginSloganSuffix => 'para resolver';

  @override
  String get loginConceptTrust => 'Confianza';

  @override
  String get loginConceptTrustDesc => 'Verificación\ny seguridad';

  @override
  String get loginConceptSpeed => 'Rapidez';

  @override
  String get loginConceptSpeedDesc => 'Respuesta\ninmediata';

  @override
  String get loginConceptConnection => 'Conexión';

  @override
  String get loginConceptConnectionDesc => 'Personas que\nresuelven';

  @override
  String get loginBenefitVerified => 'Especialistas\nverificados';

  @override
  String get loginBenefitReviews => 'Evaluaciones\nreales';

  @override
  String get loginBenefitTracking => 'Seguimiento\nde servicios';

  @override
  String get authSubtitle =>
      'Inicia sesión para recibir solicitudes de clientes';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authNoAccount => '¿No estás registrado como especialista?';

  @override
  String get authRegisterHere => 'Regístrate como Maestro';

  @override
  String get authRegisterTitle => 'Registro de Especialista';

  @override
  String get authPersonalData => 'Datos Personales';

  @override
  String get authProfessionalData => 'Perfil Profesional';

  @override
  String get authDocuments => 'Documentación y Certificados';

  @override
  String get authFirstName => 'Nombre';

  @override
  String get authLastName => 'Apellido';

  @override
  String get authBirthdate => 'Fecha de Nacimiento';

  @override
  String get authRepeatEmail => 'Repetir correo electrónico';

  @override
  String get authRepeatPassword => 'Repetir contraseña';

  @override
  String get authPhone => 'Teléfono de contacto';

  @override
  String get authAddress => 'Dirección';

  @override
  String get authBio => 'Biografía / Descripción del servicio';

  @override
  String get authHourlyRate => 'Valor hora estimado (\$)';

  @override
  String get authServiceRadius => 'Radio de servicio (km)';

  @override
  String get authProfilePhoto => 'Foto de Perfil Obligatoria';

  @override
  String get authCamera => 'Tomar foto con la cámara';

  @override
  String get authGallery => 'Elegir de la galería';

  @override
  String get authNext => 'Siguiente';

  @override
  String get authPrevious => 'Anterior';

  @override
  String get authCompleteRegister => 'Enviar Solicitud de Registro';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get versionUpdateTitle => 'Actualización Requerida';

  @override
  String get versionUpdateMessage =>
      'Para continuar recibiendo solicitudes de trabajos de manera segura, por favor actualiza la aplicación a la última versión.';

  @override
  String get versionUpdateBtn => 'Actualizar en la Tienda';

  @override
  String get sessionExpired =>
      'Tu sesión ha sido iniciada en otro dispositivo.';

  @override
  String get registerTitle => 'Registro';

  @override
  String get registerSubtitle => 'Crea tu cuenta para comenzar';

  @override
  String get registerStepPersonal => 'Datos Personales';

  @override
  String get registerStepLocation => 'Ubicación y Contacto';

  @override
  String get registerStepLocationSubtitle =>
      'Completa tus datos de contacto para continuar';

  @override
  String get registerStepBio => 'Tu Experiencia Profesional';

  @override
  String get registerStepBioSubtitle =>
      'Cuéntale a tus futuros clientes sobre tu trayectoria, especialidad y años en el oficio para destacar tu perfil.';

  @override
  String get registerStepPhotos => 'Muestra tu Trabajo';

  @override
  String get registerStepPhotosSubtitle =>
      'Sube tu foto de perfil y fotos de trabajos realizados para generar confianza en tus clientes.';

  @override
  String get registerStepDocs => 'Documentos de Identidad';

  @override
  String get registerStepDocsSubtitle =>
      'A continuación, sube una foto frontal y posterior de tu Cédula de Identidad';

  @override
  String get registerStepSummary => '¡Tu Perfil está listo!';

  @override
  String get registerStepSummarySubtitle =>
      'Revisa el resumen de tu registro antes de activar tu perfil profesional en ClanShip.';

  @override
  String get registerEmailHint => 'Correo electrónico';

  @override
  String get registerRepeatEmailHint => 'Repite el correo';

  @override
  String get registerPasswordHint => 'Contraseña';

  @override
  String get registerRepeatPasswordHint => 'Repite la contraseña';

  @override
  String get registerFirstNameHint => 'Nombre';

  @override
  String get registerLastNameHint => 'Apellido';

  @override
  String get registerBirthdateHint => 'Fecha de Nacimiento';

  @override
  String get registerAddressHint => 'Mi dirección';

  @override
  String get registerPhoneHint => 'Número de teléfono';

  @override
  String get registerTagsTitle => 'Etiquetas de Servicio';

  @override
  String get registerTagsEmpty =>
      'No has seleccionado ninguna especialidad. Selecciona al menos una para continuar.';

  @override
  String registerTagsSelectedCount(int count) {
    return '$count especialidades seleccionadas.';
  }

  @override
  String get registerTagsButton => 'Seleccionar Etiquetas';

  @override
  String get registerTermsAccept => 'Lee los términos y condiciones de uso';

  @override
  String get registerTermsAgreement =>
      'Al registrarte aceptas nuestros\nTérminos y Condiciones y Política de Privacidad';

  @override
  String get registerPhotoFront => '+ Foto Frontal';

  @override
  String get registerPhotoFrontAttached => 'Frontal Adjunta ✓';

  @override
  String get registerPhotoBack => '+ Foto Posterior';

  @override
  String get registerPhotoBackAttached => 'Posterior Adjunta ✓';

  @override
  String get registerCedulaAttached => 'Cédula Identidad Adjunta';

  @override
  String get registerTradeProofHint =>
      'Sube el documento que acredite tu oficio/profesión\n(Si no los tienes, puedes ignorar este paso)';

  @override
  String get registerUploadDocsOptional => '+ Subir Documentos (opcional)';

  @override
  String get registerDocNameDialogTitle => 'Nombre del Documento';

  @override
  String get registerDocNameDialogHint =>
      'Ej: Título Técnico, Certificación SEC';

  @override
  String get registerBioTemplatesTitle => 'Plantillas rápidas de sugerencia:';

  @override
  String get registerBioElectrician =>
      'Maestro electricista con más de 5 años de experiencia en instalaciones residenciales, tableros y reparaciones de urgencia garantizadas.';

  @override
  String get registerBioPlumber =>
      'Especialista en instalaciones de agua, filtraciones, calefón y destapes. Atención rápida y trabajos garantizados.';

  @override
  String get registerBioPainter =>
      'Técnico en pintura de interiores, fachadas y acabados finos. Compromiso con la limpieza y la puntualidad.';

  @override
  String get registerBioHint =>
      'Ejemplo: Llevo 8 años ofreciendo servicios de reparación e instalaciones. Me caracterizo por la puntualidad, transparencia en presupuestos y garantía por trabajo realizado...';

  @override
  String get registerProfilePhotoTitle => 'Foto de Perfil ';

  @override
  String get registerProfilePhotoMandatory => '* (Obligatoria)';

  @override
  String get registerProfilePhotoUploaded => 'Foto cargada ✓';

  @override
  String get registerProfilePhotoDesc =>
      'Sube una foto clara donde se aprecie bien tu rostro (será evaluada para la validación de tu perfil).';

  @override
  String get registerWorkGalleryTitle => 'Galería de Trabajos Realizados';

  @override
  String registerWorkPhotosCount(int count) {
    return '$count/6 fotos';
  }

  @override
  String get registerAddPhoto => 'Añadir';

  @override
  String get registerSummaryTitle => 'Revisa tu información';

  @override
  String get registerSummarySelectedTags => 'Especialidades seleccionadas:';

  @override
  String get registerSummaryBio => 'Biografía / Experiencia:';

  @override
  String get registerSummaryNoBio => 'Sin biografía redactada';

  @override
  String registerSummaryWorkPhotos(int count) {
    return '📷 Fotos de trabajos: $count';
  }

  @override
  String registerSummaryIdCard(String status) {
    return '📄 Cédula: $status';
  }

  @override
  String get registerSummaryIdCardLoaded => 'Cargada ✓';

  @override
  String get registerSummaryIdCardPending => 'Pendiente';

  @override
  String get registerCompleteButton => 'Completar Registro';

  @override
  String get registerErrorFillAll => 'Por favor completa todos los campos.';

  @override
  String get registerErrorNameLength =>
      'El nombre no puede superar los 30 caracteres.';

  @override
  String get registerErrorLastNameLength =>
      'El apellido no puede superar los 30 caracteres.';

  @override
  String get registerErrorEmailMismatch =>
      'Los correos electrónicos no coinciden.';

  @override
  String get registerErrorEmailInvalid =>
      'Por favor ingresa un correo electrónico válido.';

  @override
  String get registerErrorPasswordLength =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get registerErrorPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get registerErrorEmailRegistered =>
      'El correo electrónico ya se encuentra registrado. Por favor inicia sesión o utiliza otro correo.';

  @override
  String get registerErrorPhoneRegistered =>
      'El número de teléfono ya está registrado por otro usuario. Por favor utiliza otro número.';

  @override
  String get registerErrorCedulaMissing =>
      'Por favor sube la foto frontal y posterior de tu Cédula de Identidad.';

  @override
  String get registerErrorAvatarMissing =>
      'Debes subir una foto de perfil clara de tu rostro. Es obligatoria para la validación de tu perfil.';

  @override
  String get registerErrorAgeRestriction =>
      'Debes ser mayor de 18 años para registrarte.';

  @override
  String get registerPickImageError =>
      'Lo sentimos, no se pudo seleccionar la imagen.';

  @override
  String get registerPickWorkPhotoError =>
      'No se pudo cargar la imagen del trabajo.';

  @override
  String get registerLoadingTags => 'Cargando etiquetas de servicio...';

  @override
  String get forgotPasswordTitle => 'Recuperar Contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu correo para recibir un código de verificación';

  @override
  String get forgotPasswordSendCode => 'Enviar Código';

  @override
  String get forgotPasswordEnterOtp =>
      'Ingresa el código de 6 dígitos enviado a tu correo';

  @override
  String get forgotPasswordVerifyCode => 'Verificar Código';

  @override
  String get forgotPasswordNewPassword => 'Nueva Contraseña';

  @override
  String get forgotPasswordConfirmNewPassword => 'Confirmar Nueva Contraseña';

  @override
  String get forgotPasswordResetButton => 'Cambiar Contraseña';

  @override
  String get forgotPasswordSuccessTitle => '¡Contraseña Actualizada!';

  @override
  String get forgotPasswordSuccessDesc =>
      'Tu contraseña ha sido restablecida exitosamente. Ya puedes iniciar sesión.';

  @override
  String get forgotPasswordBackToLogin => 'Volver a Iniciar Sesión';

  @override
  String get mapSearchAddressHint => 'Buscar dirección...';

  @override
  String get mapCurrentGpsTooltip => 'GPS Actual';

  @override
  String get mapSelectLocationHint => 'Selecciona una ubicación';

  @override
  String get mapConfirmLocation => 'Confirmar Ubicación';

  @override
  String get mapGpsDialogTitle => 'GPS Actual';

  @override
  String get mapGpsDialogContent =>
      'Esta función utiliza el sensor GPS de tu dispositivo para obtener tu ubicación geográfica en tiempo real, centrar el mapa en tus coordenadas exactas y autocompletar la dirección.';

  @override
  String get mapPinAddressDialogTitle => 'Fijar Dirección';

  @override
  String get mapPinAddressDialogContent =>
      'Confirma y guarda el punto exacto seleccionado en el mapa como tu dirección registrada o punto base de atención.';

  @override
  String get mapPinAddressTooltip => 'Información sobre Fijar Dirección';

  @override
  String get commonUnderstood => 'Entendido';

  @override
  String get settingsAvatarUploadError =>
      'Lo sentimos, no se pudo subir la foto.';

  @override
  String get settingsAvatarUploadSuccess =>
      'Foto de perfil actualizada con éxito';

  @override
  String get settingsNotAuthenticatedError => 'Error: No autenticado';

  @override
  String get settingsAvatarProcessError =>
      'Lo sentimos, no se pudo procesar la foto.';

  @override
  String get settingsSectionAccount => 'Cuenta';

  @override
  String get settingsSectionPreferences => 'Preferencias';

  @override
  String get settingsStatusValidated => '✓ Validado';

  @override
  String get settingsStatusRejected => '❌ Rechazado';

  @override
  String get settingsStatusInProcess => '⌛ En proceso';

  @override
  String get settingsSectionOtherSecurity => 'Otros y Seguridad';

  @override
  String get settingsReportContent => 'Reportar contenido o problema';

  @override
  String get settingsAppVersion => 'Versión de la app';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String settingsFooterVersion(String version, String buildNumber) {
    return 'Clanship Profesional v$version (Build $buildNumber)';
  }

  @override
  String get settingsDefaultDisplayName => 'Maestro';

  @override
  String get settingsDeleteAccountTitle => 'Eliminar Cuenta';

  @override
  String get settingsDeleteAccountBody =>
      '¿Estás seguro de que deseas eliminar tu cuenta de prestador?\n\nEsta acción es permanente e irreversible. Se borrarán tus datos de perfil, certificaciones e historial según nuestras políticas de privacidad.';

  @override
  String get settingsDeleteAccountConfirm => 'Eliminar definitivamente';

  @override
  String get settingsAccountDeletedSuccess =>
      'Tu cuenta ha sido eliminada con éxito.';

  @override
  String get settingsReportDialogTitle => 'Reportar Contenido o Problema';

  @override
  String get settingsReportDialogSubtitle =>
      'Selecciona el motivo del reporte para que nuestro equipo lo revise:';

  @override
  String get settingsReportReasonInappropriate =>
      'Contenido inapropiado u ofensivo';

  @override
  String get settingsReportReasonSpam => 'Spam o solicitud falsa';

  @override
  String get settingsReportReasonPhotoProblem =>
      'Foto o documento con problema';

  @override
  String get settingsReportReasonCopyright => 'Violación de derechos de autor';

  @override
  String get settingsReportReasonOther => 'Otro motivo';

  @override
  String get settingsReportDetailsHint => 'Detalles adicionales (opcional)';

  @override
  String get settingsReportSubmitBtn => 'Enviar Reporte';

  @override
  String get settingsReportSubmittedSuccess =>
      'Reporte enviado con éxito. Nuestro equipo revisará la información dentro de 24 horas.';

  @override
  String get verificationModalRejectedTitle => 'Registro Rechazado';

  @override
  String verificationModalRejectedBody(String reason) {
    return 'Tu solicitud no fue aprobada por la siguiente observación:\n\n\"$reason\"\n\nPuedes subir o reemplazar tus documentos para volver a solicitar la validación.';
  }

  @override
  String get verificationModalRejectedBtn =>
      'Resolver observaciones y reenviar';

  @override
  String homeRegistrationObservedSnackBar(String reasonText) {
    return '⚠️ Tu registro ha sido observado$reasonText. Por favor sube nuevos documentos.';
  }

  @override
  String get homeNotifNewRequest => 'Nueva Solicitud';

  @override
  String get homeNotifJobUpdated => 'Trabajo Actualizado';

  @override
  String get homeNotifNewMessage => 'Mensaje Nuevo';

  @override
  String get homeNotifDefaultBody => 'Tienes una actualización de trabajo';

  @override
  String get homeNotificationsTitle => 'Notificaciones';

  @override
  String get homeClearAllNotifications => 'Limpiar todo';

  @override
  String get homeNoNewNotifications => 'No tienes nuevas notificaciones';

  @override
  String get homeGpsDisabledError =>
      'Los servicios de ubicación están desactivados en el dispositivo.';

  @override
  String get homeGpsPermissionDenied => 'Permiso de ubicación denegado.';

  @override
  String get homeGpsPermissionDeniedPermanent =>
      'Permiso de ubicación denegado permanentemente. Actívalo en los ajustes del sistema.';

  @override
  String get homeGpsLocationFetchError =>
      'No se pudo obtener la ubicación actual.';

  @override
  String get homeGpsCurrentLocationAddress => 'Ubicación GPS actual';

  @override
  String get homeGpsUpdateSuccess => 'Ubicación GPS actualizada con éxito.';

  @override
  String get homeGenericError =>
      'Lo sentimos, hubo un error. Por favor, intenta de nuevo.';

  @override
  String get homeFixAddressSuccess => 'Dirección fija actualizada con éxito.';

  @override
  String get homeGpsDialogInfoContent =>
      'Esta opción utiliza el sensor GPS en tiempo real de tu dispositivo para detectar tu ubicación geográfica exacta en este momento. Es ideal si te encuentras en terreno y deseas recibir trabajos cercanos a tu posición física actual.';

  @override
  String get homeUseMyGpsBtn => 'Usar mi GPS';

  @override
  String get homePinAddressInfoContent =>
      'Esta opción te permite seleccionar y fijar una dirección estática en el mapa como tu punto base de trabajo (por ejemplo tu hogar o taller). Así recibirás solicitudes en ese sector sin depender de tu ubicación GPS.';

  @override
  String get homeSelectOnMapBtn => 'Seleccionar en Mapa';

  @override
  String get homeNoAddressConfigured => 'Sin dirección configurada';

  @override
  String get homeServiceAreaInfoTitle => 'Área de Servicio';

  @override
  String get homeServiceAreaInfoGps =>
      '• GPS Actual: Utiliza tu ubicación en vivo por GPS para recibir solicitudes cerca de donde te encuentres físicamente.';

  @override
  String get homeServiceAreaInfoPin =>
      '• Fijar Dirección: Define un punto fijo o taller en el mapa para recibir solicitudes en ese sector de forma permanente.';
}
