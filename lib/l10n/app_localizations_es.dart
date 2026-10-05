// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sahaaya';

  @override
  String get welcomeTitle => '¡Bienvenido a Sahaaya!';

  @override
  String get welcomeSubtitle =>
      'Tu camino para ayudar y apoyar comienza aquí.\nInicia sesión o regístrate para continuar.';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get email => 'Correo electrónico';

  @override
  String get enterValidEmail => 'Ingresa un correo válido';

  @override
  String get password => 'Contraseña';

  @override
  String get min6Chars => 'Mínimo 6 caracteres';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signIn => 'Ingresar';

  @override
  String get signInWithGoogle => 'Ingresar con Google';

  @override
  String get noAccount => '¿No tienes una cuenta? ';

  @override
  String get registerNow => 'Regístrate ahora';

  @override
  String get pleaseEnterEmailFirst => 'Primero ingresa tu correo.';

  @override
  String get resetEmailSent =>
      'Correo de restablecimiento enviado. Revisa tu bandeja.';

  @override
  String get resetEmailFailed =>
      'Falló el envío del correo de restablecimiento';

  @override
  String get userNotFound => 'No se encontró usuario con ese correo.';

  @override
  String get wrongPassword => 'Contraseña incorrecta. Inténtalo de nuevo.';

  @override
  String get invalidEmail => 'Formato de correo inválido.';

  @override
  String get loginFailed => 'Error al iniciar sesión. Inténtalo de nuevo.';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get enterUsername => 'Ingresa nombre de usuario';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get signUpWithGoogle => 'Registrarse con Google';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get signInCta => 'Inicia sesión';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get dashboard => 'Panel';

  @override
  String get assistQuestion => '¿Cómo podemos ayudarte hoy?';

  @override
  String get ivrDemo => 'Demostración IVR';

  @override
  String get nearbyShelters => 'Refugios cercanos';

  @override
  String get emergencySos => 'Emergencia (SOS)';

  @override
  String get askForSupport => 'Pedir ayuda';

  @override
  String get chatbotCare => 'Chatbot de cuidado';

  @override
  String get floodAlerts => 'Alertas de inundación';

  @override
  String get quickViewIVROutcomes => 'Vista rápida (resultados IVR)';

  @override
  String get emergencies1 => 'Emergencias (1)';

  @override
  String get foodShelter2 => 'Comida/Refugio (2)';

  @override
  String get volunteers3 => 'Voluntarios (3)';

  @override
  String get actions => 'Acciones';

  @override
  String get openIVRKeypad => 'Abrir teclado IVR';

  @override
  String get recordFreshResponse => 'Registrar respuesta nueva (1/2/3)';

  @override
  String get safetyTip => 'Consejo de seguridad:';

  @override
  String get safetyTipContent =>
      'Ten una bolsa lista con agua, comida no perecedera y documentos esenciales.';

  @override
  String get appInfo => 'Información de la app';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get sosEmergency => 'Emergencia SOS';

  @override
  String get sendLiveSos => 'Enviar alerta SOS en vivo';

  @override
  String get liveSosSent => '¡Alerta SOS enviada con éxito!';

  @override
  String get failedToSendSos => 'No se pudo enviar el SOS';

  @override
  String get sosAlertsOverview => 'Resumen de alertas SOS';

  @override
  String get liveReportsDemo => 'Reportes en vivo con datos de demostración.';

  @override
  String get highRiskZones => 'Zonas de alto riesgo';

  @override
  String get noHighRiskZones => 'Aún no se detectan zonas de alto riesgo';

  @override
  String get zonesAppearAuto =>
      'Las zonas aparecen automáticamente tras tres alertas cercanas.';

  @override
  String get allAlerts => 'Todas las alertas';

  @override
  String get noSosAlertsYet => 'Aún no hay alertas SOS';

  @override
  String get pressSosToSend => 'Pulsa el botón SOS para enviar una alerta.';

  @override
  String clusterOfAlerts(Object count) {
    return 'Agrupación de $count alertas';
  }

  @override
  String get demoData => 'Datos de demo';

  @override
  String get liveData => 'Datos en vivo';

  @override
  String alertsCountLabel(Object count) {
    return '$count alertas';
  }
}
