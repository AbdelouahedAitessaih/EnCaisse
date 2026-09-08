// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'Empezar';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInSubtitle => 'Inicia sesión en tu cuenta de EnCaisse.';

  @override
  String get joinEncaisse => 'Únete a EnCaisse';

  @override
  String get signUpSubtitle =>
      'Controla el dinero compartido con total transparencia.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get displayName => 'Nombre visible';

  @override
  String get or => 'o';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get needAccount => '¿Necesitas una cuenta? Regístrate';

  @override
  String get haveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get enterEmail => 'Introduce tu correo';

  @override
  String get validEmail => 'Introduce un correo válido';

  @override
  String get passwordMin => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get rememberMe => 'Recuérdame';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get enterName => 'Introduce tu nombre';

  @override
  String get hello => 'Hola';

  @override
  String helloName(String name) {
    return 'Hola, $name';
  }

  @override
  String get noGroupsYet => 'Aún no hay grupos';

  @override
  String get noGroupsSubtitle =>
      'Crea una caja o únete con un código de invitación.';

  @override
  String get createAGroup => 'Crear un grupo';

  @override
  String get joinWithCode => 'Unirse con código';

  @override
  String get joinWithInviteCode => 'Unirse con código de invitación';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del teléfono';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get nameYourCaisse => 'Nombra tu caja';

  @override
  String get inviteCodeHint =>
      'Recibirás un código de invitación de 6 caracteres para compartir.';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get groupNameHint => 'Viaje de fin de semana, Piso…';

  @override
  String get enterGroupName => 'Introduce un nombre de grupo';

  @override
  String get currency => 'Moneda';

  @override
  String get selectCurrency => 'Elige una moneda';

  @override
  String get startingAmountOptional => 'Cantidad inicial (opcional)';

  @override
  String get startingAmountHelper =>
      'Solo tú (el creador) podrás editar esta cantidad después.';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get enterInviteCode => 'Introduce el código de invitación';

  @override
  String askForCode(int length) {
    return 'Pide a un miembro el código de $length caracteres.';
  }

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get joinGroup => 'Unirse al grupo';

  @override
  String enterCodeLength(int length) {
    return 'Introduce un código de $length caracteres';
  }

  @override
  String get noGroupForCode => 'No se encontró ningún grupo con este código.';

  @override
  String get balance => 'Saldo';

  @override
  String get inLabel => 'Entradas';

  @override
  String get outLabel => 'Salidas';

  @override
  String get members => 'Miembros';

  @override
  String get byCategory => 'Por categoría';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterUser => 'Usuario';

  @override
  String get filterDate => 'Fecha';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get noMatchingMovements =>
      'Ningún movimiento coincide con estos filtros.';

  @override
  String get inviteFriends => 'Invitar amigos';

  @override
  String get shareCodeSoFriends =>
      'Comparte este código para que tus amigos se unan.';

  @override
  String get shareThisCode => 'Comparte este código para que otros se unan.';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get share => 'Compartir';

  @override
  String inviteCodeCopied(String code) {
    return 'Código $code copiado';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'Únete a mi grupo EnCaisse \"$name\" con el código $code. EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'Únete a $name en EnCaisse';
  }

  @override
  String get notificationsMuted => 'Notificaciones silenciadas para este grupo';

  @override
  String get notificationsEnabled => 'Notificaciones activadas para este grupo';

  @override
  String get unmuteNotifications => 'Activar notificaciones';

  @override
  String get muteNotifications => 'Silenciar notificaciones';

  @override
  String get noMovementsYet => 'Aún no hay movimientos';

  @override
  String get noMovementsSubtitle =>
      'Añade el primer ingreso o gasto de esta caja.';

  @override
  String get addMovement => 'Añadir movimiento';

  @override
  String get editMovement => 'Editar movimiento';

  @override
  String get movement => 'Movimiento';

  @override
  String get startingBalance => 'Saldo inicial';

  @override
  String get editStartingBalance => 'Editar saldo inicial';

  @override
  String get type => 'Tipo';

  @override
  String get deposit => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get amount => 'Cantidad';

  @override
  String get startingAmount => 'Cantidad inicial';

  @override
  String get title => 'Título';

  @override
  String get titleHint => 'Compra, alquiler…';

  @override
  String get category => 'Categoría';

  @override
  String get addReceipt => 'Añadir foto del recibo (opcional)';

  @override
  String get receiptSelected => 'Recibo seleccionado';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get enterValidAmount => 'Introduce una cantidad válida';

  @override
  String get enterTitle => 'Introduce un título';

  @override
  String get onlyCreatorEditStarting =>
      'Solo tú (el creador) puedes cambiar esta cantidad.';

  @override
  String get onlyCreatorCanEditStarting =>
      'Solo quien creó la caja puede editar el saldo inicial.';

  @override
  String get onlyYouEditStarting =>
      'Solo tú puedes editar esta cantidad inicial.';

  @override
  String get onlyCreatorEditAmount =>
      'Solo el creador de la caja puede editar esta cantidad.';

  @override
  String get createdBy => 'Creado por';

  @override
  String get created => 'Creado';

  @override
  String get receipt => 'Recibo';

  @override
  String get attached => 'Adjunto';

  @override
  String get auditTrail => 'Historial de auditoría';

  @override
  String get auditTrailSubtitle =>
      'Historial solo de adición. Nadie puede editar ni borrar estas entradas.';

  @override
  String get noAuditYet => 'Aún no hay entradas de auditoría.';

  @override
  String get deleteMovement => '¿Eliminar movimiento?';

  @override
  String get deleteStartingBalance => '¿Eliminar saldo inicial?';

  @override
  String get softDeleteHint =>
      'Esto elimina temporalmente el movimiento durante 24 horas. Puedes deshacerlo desde el aviso o esta pantalla.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get movementDeletedUndo => 'Movimiento eliminado — Deshacer';

  @override
  String get undo => 'Deshacer';

  @override
  String get movementRestored => 'Movimiento restaurado';

  @override
  String get softDeletedCanUndo =>
      'Eliminado temporalmente — aún puedes deshacerlo en 24 horas.';

  @override
  String get softDeletedExpired =>
      'Eliminado temporalmente — el plazo para deshacer ha expirado.';

  @override
  String get undoDelete => 'Deshacer eliminación';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionUpdate => 'Actualizar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get groupNotFound => 'Grupo no encontrado';

  @override
  String get movementNotFound => 'Movimiento no encontrado';

  @override
  String get couldNotLoadGroups =>
      'No se pudieron cargar los grupos. Revisa la configuración de Firebase.';

  @override
  String get onboardingTitle1 => 'Una caja compartida';

  @override
  String get onboardingBody1 =>
      'Todos en el grupo pueden añadir ingresos y gastos. Sin jerarquía de administradores.';

  @override
  String get onboardingTitle2 => 'Historial completo';

  @override
  String get onboardingBody2 =>
      'Cada cambio queda registrado. La confianza viene de la transparencia, no de los permisos.';

  @override
  String get onboardingTitle3 => 'Invitar con un código';

  @override
  String get onboardingBody3 =>
      'Crea un grupo o únete con un código de 6 caracteres.';

  @override
  String get welcomeSubtitle =>
      'Dinero de grupo compartido, transparente para todos.';

  @override
  String get validStartingAmount =>
      'Introduce una cantidad inicial válida (o déjala vacía).';

  @override
  String get manageGroup => 'Gestionar grupo';

  @override
  String get renameGroup => 'Renombrar grupo';

  @override
  String get renameGroupHint => 'Introduce un nuevo nombre para esta caja.';

  @override
  String get save => 'Guardar';

  @override
  String get manageMembers => 'Gestionar miembros';

  @override
  String get removeMember => 'Eliminar';

  @override
  String removeMemberConfirm(String name) {
    return '¿Eliminar a $name de este grupo?';
  }

  @override
  String get memberRemoved => 'Miembro eliminado';

  @override
  String get cannotRemoveCreator => 'No puedes eliminar al creador del grupo.';

  @override
  String get deleteGroup => 'Eliminar grupo';

  @override
  String get deleteGroupConfirm => '¿Eliminar este grupo?';

  @override
  String get deleteGroupHint =>
      'Esto elimina permanentemente el grupo, los miembros y todos los movimientos. No se puede deshacer.';

  @override
  String get groupDeleted => 'Grupo eliminado';

  @override
  String get groupRenamed => 'Grupo renombrado';

  @override
  String get creator => 'Creador';

  @override
  String get changeGroupPhoto => 'Cambiar foto del grupo';

  @override
  String get groupPhotoUpdated => 'Foto del grupo actualizada';

  @override
  String get leaveGroup => 'Salir del grupo';

  @override
  String get leaveGroupHint =>
      'Saldrás de este grupo, pero tus movimientos permanecerán en el historial.';

  @override
  String get leftGroup => 'Has salido del grupo';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get incorrectCredentials =>
      'El correo o la contraseña son incorrectos.';

  @override
  String get firebaseNotConfigured =>
      'Firebase aún no está configurado. Añade tu google-services.json.';

  @override
  String get signInFailed => 'Error al iniciar sesión. Inténtalo de nuevo.';

  @override
  String get signUpFailed => 'Error al registrarse. Inténtalo de nuevo.';

  @override
  String get googleSignInCanceled => 'Inicio de sesión con Google cancelado.';

  @override
  String get googleSignInConfigError =>
      'Google Sign-In no está configurado. Añade el SHA-1 en Firebase y descarga un nuevo google-services.json.';

  @override
  String get googleSignInFailed =>
      'Error al iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get forceUpdateTitle => 'Actualización obligatoria';

  @override
  String get forceUpdateBody =>
      'Se requiere una nueva versión de EnCaisse para continuar. Actualiza desde Google Play.';

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String get updateAvailableBody =>
      'Hay una nueva versión de EnCaisse con mejoras importantes.';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get updateLater => 'Más tarde';

  @override
  String get emailAlreadyInUse => 'Ya existe una cuenta con este correo.';

  @override
  String get weakPassword => 'Elige una contraseña más segura.';

  @override
  String get member => 'Miembro';

  @override
  String get aMember => 'Un miembro';

  @override
  String get someoneJoined => 'Alguien se unió';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name se unió a $group';
  }

  @override
  String get joinAGroup => 'Unirse a un grupo';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get enterValidAmountGtZero =>
      'Introduce una cantidad válida mayor que cero.';

  @override
  String couldNotLoadAudit(String error) {
    return 'No se pudo cargar la auditoría: $error';
  }

  @override
  String get newMovementNotify => 'Nuevo movimiento';

  @override
  String get depositNotifyTitle => 'Nuevo ingreso';

  @override
  String get expenseNotifyTitle => 'Nuevo gasto';

  @override
  String get movementUpdatedNotify => 'Movimiento actualizado';

  @override
  String get movementDeletedNotify => 'Movimiento eliminado';

  @override
  String get movementRestoredNotify => 'Movimiento restaurado';

  @override
  String addedDeposit(String name, String title) {
    return '$name añadió un ingreso: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name añadió un gasto: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name añadió un ingreso de $amount: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name añadió un gasto de $amount: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name actualizó: $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name eliminó: $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name restauró: $title';
  }

  @override
  String get deletedMarker => 'eliminado';

  @override
  String get insufficientBalance =>
      'Saldo insuficiente. Esto dejaría la caja en negativo.';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get timeLabel => 'Hora';
}
