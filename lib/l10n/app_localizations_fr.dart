// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInSubtitle => 'Connectez-vous à votre compte EnCaisse.';

  @override
  String get joinEncaisse => 'Rejoindre EnCaisse';

  @override
  String get signUpSubtitle =>
      'Suivez la caisse partagée en toute transparence.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get displayName => 'Nom affiché';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get needAccount => 'Pas de compte ? S\'inscrire';

  @override
  String get haveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get enterEmail => 'Entrez votre e-mail';

  @override
  String get validEmail => 'Entrez un e-mail valide';

  @override
  String get passwordMin =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get enterName => 'Entrez votre nom';

  @override
  String get hello => 'Bonjour';

  @override
  String helloName(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get noGroupsYet => 'Aucun groupe pour l\'instant';

  @override
  String get noGroupsSubtitle =>
      'Commencez seul avec une caisse personnelle, créez un groupe, ou rejoignez avec un code.';

  @override
  String get createAGroup => 'Créer un groupe';

  @override
  String get joinWithCode => 'Rejoindre avec un code';

  @override
  String get joinWithInviteCode => 'Rejoindre avec un code d\'invitation';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get themeMode => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get nameYourCaisse => 'Nommez votre caisse';

  @override
  String get inviteCodeHint =>
      'Vous recevrez un code d\'invitation de 6 caractères à partager.';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get groupNameHint => 'Week-end, Colocataires…';

  @override
  String get enterGroupName => 'Entrez un nom de groupe';

  @override
  String get currency => 'Devise';

  @override
  String get selectCurrency => 'Choisissez une devise';

  @override
  String get startingAmountOptional => 'Montant de départ (optionnel)';

  @override
  String get startingAmountHelper =>
      'Seul vous (le créateur) pourrez modifier ce montant plus tard.';

  @override
  String get createGroup => 'Créer le groupe';

  @override
  String get enterInviteCode => 'Entrez le code d\'invitation';

  @override
  String askForCode(int length) {
    return 'Demandez le code à $length caractères à un membre.';
  }

  @override
  String get inviteCode => 'Code d\'invitation';

  @override
  String get joinGroup => 'Rejoindre le groupe';

  @override
  String enterCodeLength(int length) {
    return 'Entrez un code de $length caractères';
  }

  @override
  String get noGroupForCode => 'Aucun groupe trouvé pour ce code.';

  @override
  String get balance => 'Solde';

  @override
  String get inLabel => 'Entrées';

  @override
  String get outLabel => 'Sorties';

  @override
  String get members => 'Membres';

  @override
  String get byCategory => 'Par catégorie';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterUser => 'Utilisateur';

  @override
  String get filterDate => 'Date';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get noMatchingMovements =>
      'Aucun mouvement ne correspond à ces filtres.';

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get shareCodeSoFriends =>
      'Partagez ce code pour que vos amis rejoignent.';

  @override
  String get shareThisCode => 'Partagez ce code pour que d\'autres rejoignent.';

  @override
  String get copyCode => 'Copier le code';

  @override
  String get share => 'Partager';

  @override
  String inviteCodeCopied(String code) {
    return 'Code $code copié';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'Rejoins mon groupe EnCaisse « $name » avec le code $code. EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'Rejoindre $name sur EnCaisse';
  }

  @override
  String get notificationsMuted => 'Notifications désactivées pour ce groupe';

  @override
  String get notificationsEnabled => 'Notifications activées pour ce groupe';

  @override
  String get unmuteNotifications => 'Réactiver les notifications';

  @override
  String get muteNotifications => 'Couper les notifications';

  @override
  String get noMovementsYet => 'Aucun mouvement pour l\'instant';

  @override
  String get noMovementsSubtitle =>
      'Ajoutez le premier dépôt ou la première dépense.';

  @override
  String get addMovement => 'Ajouter un mouvement';

  @override
  String get editMovement => 'Modifier le mouvement';

  @override
  String get movement => 'Mouvement';

  @override
  String get startingBalance => 'Solde de départ';

  @override
  String get editStartingBalance => 'Modifier le solde de départ';

  @override
  String get type => 'Type';

  @override
  String get deposit => 'Dépôt';

  @override
  String get expense => 'Dépense';

  @override
  String get amount => 'Montant';

  @override
  String get startingAmount => 'Montant de départ';

  @override
  String get title => 'Titre';

  @override
  String get titleHint => 'Courses, loyer…';

  @override
  String get category => 'Catégorie';

  @override
  String get addReceipt => 'Ajouter un reçu (optionnel)';

  @override
  String get receiptSelected => 'Reçu sélectionné';

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String get enterValidAmount => 'Entrez un montant valide';

  @override
  String get enterTitle => 'Entrez un titre';

  @override
  String get onlyCreatorEditStarting =>
      'Seul vous (le créateur) pouvez modifier ce montant.';

  @override
  String get onlyCreatorCanEditStarting =>
      'Seul le créateur de la caisse peut modifier le solde de départ.';

  @override
  String get onlyYouEditStarting =>
      'Seul vous pouvez modifier ce montant de départ.';

  @override
  String get onlyCreatorEditAmount =>
      'Seul le créateur de la caisse peut modifier ce montant.';

  @override
  String get createdBy => 'Créé par';

  @override
  String get created => 'Créé le';

  @override
  String get receipt => 'Reçu';

  @override
  String get attached => 'Joint';

  @override
  String get auditTrail => 'Historique';

  @override
  String get auditTrailSubtitle =>
      'Historique en ajout seul. Personne ne peut modifier ou supprimer ces entrées.';

  @override
  String get noAuditYet => 'Aucune entrée d\'historique.';

  @override
  String get deleteMovement => 'Supprimer le mouvement ?';

  @override
  String get deleteStartingBalance => 'Supprimer le solde de départ ?';

  @override
  String get softDeleteHint =>
      'Suppression temporaire pendant 24 h. Vous pouvez annuler via le bandeau ou cet écran.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get movementDeletedUndo => 'Mouvement supprimé — Annuler';

  @override
  String get undo => 'Annuler';

  @override
  String get movementRestored => 'Mouvement restauré';

  @override
  String get softDeletedCanUndo =>
      'Supprimé temporairement — vous pouvez encore annuler sous 24 h.';

  @override
  String get softDeletedExpired =>
      'Supprimé temporairement — délai d\'annulation expiré.';

  @override
  String get undoDelete => 'Annuler la suppression';

  @override
  String get actionCreate => 'Création';

  @override
  String get actionUpdate => 'Modification';

  @override
  String get actionDelete => 'Suppression';

  @override
  String get groupNotFound => 'Groupe introuvable';

  @override
  String get movementNotFound => 'Mouvement introuvable';

  @override
  String get couldNotLoadGroups =>
      'Impossible de charger les groupes. Vérifiez Firebase.';

  @override
  String get onboardingTitle1 => 'Une caisse partagée';

  @override
  String get onboardingBody1 =>
      'Suivez seul ou entre amis. Dans un groupe partagé, chacun peut ajouter dépôts et dépenses — pas de hiérarchie d\'admin.';

  @override
  String get onboardingTitle2 => 'Historique complet';

  @override
  String get onboardingBody2 =>
      'Chaque changement est enregistré. La confiance vient de la transparence.';

  @override
  String get onboardingTitle3 => 'Inviter avec un code';

  @override
  String get onboardingBody3 =>
      'Créez un groupe ou rejoignez-en un avec un code à 6 caractères.';

  @override
  String get welcomeSubtitle =>
      'Caisse de groupe partagée, transparente pour tous.';

  @override
  String get validStartingAmount =>
      'Entrez un montant de départ valide (ou laissez vide).';

  @override
  String get manageGroup => 'Gérer le groupe';

  @override
  String get renameGroup => 'Renommer le groupe';

  @override
  String get renameGroupHint => 'Entrez un nouveau nom pour cette caisse.';

  @override
  String get save => 'Enregistrer';

  @override
  String get manageMembers => 'Gérer les membres';

  @override
  String get removeMember => 'Retirer';

  @override
  String removeMemberConfirm(String name) {
    return 'Retirer $name de ce groupe ?';
  }

  @override
  String get memberRemoved => 'Membre retiré';

  @override
  String get cannotRemoveCreator =>
      'Vous ne pouvez pas retirer le créateur du groupe.';

  @override
  String get deleteGroup => 'Supprimer le groupe';

  @override
  String get deleteGroupConfirm => 'Supprimer ce groupe ?';

  @override
  String get deleteGroupHint =>
      'Cela supprime définitivement le groupe, les membres et tous les mouvements. Irréversible.';

  @override
  String get groupDeleted => 'Groupe supprimé';

  @override
  String get groupRenamed => 'Groupe renommé';

  @override
  String get creator => 'Créateur';

  @override
  String get changeGroupPhoto => 'Changer la photo du groupe';

  @override
  String get groupPhotoUpdated => 'Photo du groupe mise à jour';

  @override
  String get leaveGroup => 'Quitter le groupe';

  @override
  String get leaveGroupHint =>
      'Vous quitterez ce groupe, mais vos mouvements resteront dans l\'historique.';

  @override
  String get leftGroup => 'Vous avez quitté le groupe';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get incorrectCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get firebaseNotConfigured =>
      'Firebase n\'est pas encore configuré. Ajoutez google-services.json.';

  @override
  String get signInFailed => 'Échec de la connexion. Réessayez.';

  @override
  String get signUpFailed => 'Échec de l\'inscription. Réessayez.';

  @override
  String get googleSignInCanceled => 'Connexion Google annulée.';

  @override
  String get googleSignInConfigError =>
      'La connexion Google est temporairement indisponible. Créez un compte avec e-mail et mot de passe (recommandé), mettez à jour les services Google Play, puis réessayez Google.';

  @override
  String get googleSignInFailed =>
      'Échec de la connexion Google sur cet appareil. Créez un compte avec e-mail et mot de passe, ou mettez à jour les services Google Play puis réessayez.';

  @override
  String get forceUpdateTitle => 'Mise à jour obligatoire';

  @override
  String get forceUpdateBody =>
      'Une nouvelle version d’EnCaisse est requise pour continuer. Merci de mettre à jour depuis le store.';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String get updateAvailableBody =>
      'Une nouvelle version d’EnCaisse est disponible avec des améliorations importantes.';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get emailAlreadyInUse => 'Un compte existe déjà pour cet e-mail.';

  @override
  String get weakPassword => 'Choisissez un mot de passe plus fort.';

  @override
  String get member => 'Membre';

  @override
  String get aMember => 'Un membre';

  @override
  String get someoneJoined => 'Quelqu\'un a rejoint';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name a rejoint $group';
  }

  @override
  String get joinAGroup => 'Rejoindre un groupe';

  @override
  String errorWithDetails(String error) {
    return 'Erreur : $error';
  }

  @override
  String get enterValidAmountGtZero =>
      'Entrez un montant valide supérieur à zéro.';

  @override
  String couldNotLoadAudit(String error) {
    return 'Impossible de charger l\'historique : $error';
  }

  @override
  String get newMovementNotify => 'Nouveau mouvement';

  @override
  String get depositNotifyTitle => 'Nouvel encaissement';

  @override
  String get expenseNotifyTitle => 'Nouveau décaissement';

  @override
  String get movementUpdatedNotify => 'Mouvement modifié';

  @override
  String get movementDeletedNotify => 'Mouvement supprimé';

  @override
  String get movementRestoredNotify => 'Mouvement restauré';

  @override
  String addedDeposit(String name, String title) {
    return '$name a ajouté un dépôt : $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name a ajouté une dépense : $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name a ajouté un encaissement de $amount : $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name a ajouté un décaissement de $amount : $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name a modifié : $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name a supprimé : $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name a restauré : $title';
  }

  @override
  String get deletedMarker => 'supprimé';

  @override
  String get insufficientBalance =>
      'Solde insuffisant. Cela rendrait la caisse négative.';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Heure';

  @override
  String get verifyEmailTitle => 'Vérifiez votre e-mail';

  @override
  String verifyEmailBody(String email) {
    return 'Nous avons envoyé un lien à $email. Ouvrez-le, puis appuyez sur Continuer.';
  }

  @override
  String get resendVerification => 'Renvoyer l\'e-mail';

  @override
  String get verificationEmailSent => 'E-mail de vérification envoyé';

  @override
  String get emailVerifiedContinue => 'Continuer';

  @override
  String get emailNotVerifiedYet =>
      'E-mail pas encore vérifié. Vérifiez votre boîte de réception.';

  @override
  String get checkVerification => 'J\'ai vérifié';

  @override
  String get settleTitle => 'Qui doit combien';

  @override
  String get settleSubtitle =>
      'Répartition égale de la caisse selon dépôts et dépenses.';

  @override
  String get settleSettled => 'Tout le monde est à égalité';

  @override
  String settleOwes(String from, String to) {
    return '$from doit à $to';
  }

  @override
  String get memberNet => 'Net';

  @override
  String get chartsTitle => 'Graphiques';

  @override
  String get categoryBreakdown => 'Par catégorie';

  @override
  String get exportCsv => 'Exporter CSV';

  @override
  String get exportPdf => 'Exporter PDF';

  @override
  String get exportShared => 'Export prêt à partager';

  @override
  String get exportFailed => 'Impossible d\'exporter';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noNotificationsSubtitle =>
      'L\'activité de vos groupes apparaîtra ici.';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get offlineBanner =>
      'Hors ligne. Données en cache affichées si disponibles.';

  @override
  String get offlineRetry => 'Réessayer';

  @override
  String get forceUpdateBodyIos =>
      'Une nouvelle version d\'EnCaisse est requise. Mettez à jour depuis l\'App Store.';

  @override
  String get openStore => 'Ouvrir la boutique';

  @override
  String get insightsTitle => 'Analyses';

  @override
  String get insightsOpen => 'Répartition & graphiques';

  @override
  String get personalCaisse => 'Caisse personnelle';

  @override
  String get personalCaisseSubtitle =>
      'Suivez votre argent seul — sans groupe.';

  @override
  String get personalCaisseName => 'Ma caisse';

  @override
  String get personalBadge => 'Perso';

  @override
  String get howToUse => 'Comment utiliser EnCaisse';

  @override
  String get tourNext => 'Suivant';

  @override
  String get tourBack => 'Retour';

  @override
  String get tourSkip => 'Passer';

  @override
  String get tourDone => 'Compris';

  @override
  String get tourHome1Title => 'Votre accueil';

  @override
  String get tourHome1Body =>
      'Cette liste montre toutes vos caisses. Appuyez pour voir dépôts, dépenses et solde en direct.';

  @override
  String get tourHome2Title => 'Suivre seul';

  @override
  String get tourHome2Body =>
      'Besoin d’un carnet privé ? Appuyez sur + et choisissez Caisse personnelle. Pas de code, juste vous.';

  @override
  String get tourHome3Title => 'Partager';

  @override
  String get tourHome3Body =>
      'Créez un groupe ou rejoignez avec un code à 6 caractères. Tout le monde voit le même historique transparent.';

  @override
  String get tourGroup1Title => 'Solde en direct';

  @override
  String get tourGroup1Body =>
      'La carte verte est toujours calculée à partir des mouvements — dépôts moins dépenses. Impossible de tricher sur un total stocké.';

  @override
  String get tourGroup2Title => 'Ajouter un mouvement';

  @override
  String get tourGroup2Body =>
      'Appuyez sur + pour un dépôt ou une dépense. Vous pouvez joindre un reçu — chaque changement reste dans l’audit.';

  @override
  String get tourGroup3Title => 'Invitation & analyses';

  @override
  String get tourGroup3Body =>
      'Partagez le code pour inviter. Ouvrez Répartition & graphiques pour qui doit combien et les catégories.';

  @override
  String get tourGroup3BodyPersonal =>
      'Ouvrez Répartition & graphiques pour les catégories. Cette caisse est à vous seul — l’invitation est masquée.';

  @override
  String get tapPhotoToChange => 'Appuyer pour changer la photo';

  @override
  String get tapPhotoToView => 'Appuyer pour voir';

  @override
  String get creatingPersonal => 'Ouverture de votre caisse personnelle…';
}
