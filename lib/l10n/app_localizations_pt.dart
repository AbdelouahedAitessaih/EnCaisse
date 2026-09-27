// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'Começar';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Seguinte';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get signIn => 'Entrar';

  @override
  String get signOut => 'Sair';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get signInSubtitle => 'Entre na sua conta EnCaisse.';

  @override
  String get joinEncaisse => 'Junte-se ao EnCaisse';

  @override
  String get signUpSubtitle =>
      'Acompanhe o dinheiro partilhado com total transparência.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Palavra-passe';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get needAccount => 'Precisa de uma conta? Registe-se';

  @override
  String get haveAccount => 'Já tem uma conta? Entrar';

  @override
  String get enterEmail => 'Introduza o seu e-mail';

  @override
  String get validEmail => 'Introduza um e-mail válido';

  @override
  String get passwordMin => 'A palavra-passe deve ter pelo menos 6 caracteres';

  @override
  String get rememberMe => 'Lembrar-me';

  @override
  String get showPassword => 'Mostrar palavra-passe';

  @override
  String get hidePassword => 'Ocultar palavra-passe';

  @override
  String get enterName => 'Introduza o seu nome';

  @override
  String get hello => 'Olá';

  @override
  String helloName(String name) {
    return 'Olá, $name';
  }

  @override
  String get noGroupsYet => 'Ainda sem grupos';

  @override
  String get noGroupsSubtitle =>
      'Comece sozinho com uma caixa pessoal, crie um grupo ou entre com um código.';

  @override
  String get createAGroup => 'Criar um grupo';

  @override
  String get joinWithCode => 'Entrar com código';

  @override
  String get joinWithInviteCode => 'Entrar com código de convite';

  @override
  String get settings => 'Definições';

  @override
  String get appearance => 'Aparência';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma do telemóvel';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageChinese => 'Chinês';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get nameYourCaisse => 'Nomeie a sua caixa';

  @override
  String get inviteCodeHint =>
      'Receberá um código de convite de 6 caracteres para partilhar.';

  @override
  String get groupName => 'Nome do grupo';

  @override
  String get groupNameHint => 'Fim de semana, Colegas de casa…';

  @override
  String get enterGroupName => 'Introduza um nome de grupo';

  @override
  String get currency => 'Moeda';

  @override
  String get selectCurrency => 'Selecione uma moeda';

  @override
  String get startingAmountOptional => 'Montante inicial (opcional)';

  @override
  String get startingAmountHelper =>
      'Só você (o criador) poderá editar este montante mais tarde.';

  @override
  String get createGroup => 'Criar grupo';

  @override
  String get enterInviteCode => 'Introduza o código de convite';

  @override
  String askForCode(int length) {
    return 'Peça a um membro o código de $length caracteres.';
  }

  @override
  String get inviteCode => 'Código de convite';

  @override
  String get joinGroup => 'Entrar no grupo';

  @override
  String enterCodeLength(int length) {
    return 'Introduza um código de $length caracteres';
  }

  @override
  String get noGroupForCode => 'Nenhum grupo encontrado para este código.';

  @override
  String get balance => 'Saldo';

  @override
  String get inLabel => 'Entradas';

  @override
  String get outLabel => 'Saídas';

  @override
  String get members => 'Membros';

  @override
  String get byCategory => 'Por categoria';

  @override
  String get filterAll => 'Todos';

  @override
  String get filters => 'Filtros';

  @override
  String get applyFilters => 'Aplicar';

  @override
  String get filterUser => 'Utilizador';

  @override
  String get filterDate => 'Data';

  @override
  String get filterAnyTime => 'Qualquer data';

  @override
  String get filterThisMonth => 'Este mês';

  @override
  String get filterLast30Days => 'Últimos 30 dias';

  @override
  String get filterChooseDates => 'Escolher datas';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get noMatchingMovements =>
      'Nenhum movimento corresponde a estes filtros.';

  @override
  String get inviteFriends => 'Convidar amigos';

  @override
  String get shareCodeSoFriends =>
      'Partilhe este código para os amigos entrarem.';

  @override
  String get shareThisCode => 'Partilhe este código para outros entrarem.';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get share => 'Partilhar';

  @override
  String inviteCodeCopied(String code) {
    return 'Código $code copiado';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'Entra no meu grupo EnCaisse \"$name\" com o código $code. EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'Entrar em $name no EnCaisse';
  }

  @override
  String get notificationsMuted => 'Notificações silenciadas para este grupo';

  @override
  String get notificationsEnabled => 'Notificações ativadas para este grupo';

  @override
  String get unmuteNotifications => 'Reativar notificações';

  @override
  String get muteNotifications => 'Silenciar notificações';

  @override
  String get noMovementsYet => 'Ainda sem movimentos';

  @override
  String get noMovementsSubtitle =>
      'Adicione o primeiro depósito ou despesa desta caixa.';

  @override
  String get addMovement => 'Adicionar movimento';

  @override
  String get editMovement => 'Editar movimento';

  @override
  String get movement => 'Movimento';

  @override
  String get startingBalance => 'Saldo inicial';

  @override
  String get editStartingBalance => 'Editar saldo inicial';

  @override
  String get type => 'Tipo';

  @override
  String get deposit => 'Depósito';

  @override
  String get expense => 'Despesa';

  @override
  String get amount => 'Montante';

  @override
  String get startingAmount => 'Montante inicial';

  @override
  String get title => 'Título';

  @override
  String get titleHint => 'Compras, renda…';

  @override
  String get category => 'Categoria';

  @override
  String get addReceipt => 'Adicionar foto do recibo (opcional)';

  @override
  String get receiptSelected => 'Recibo selecionado';

  @override
  String get saveChanges => 'Guardar alterações';

  @override
  String get enterValidAmount => 'Introduza um montante válido';

  @override
  String get enterTitle => 'Introduza um título';

  @override
  String get onlyCreatorEditStarting =>
      'Só você (o criador) pode alterar este montante.';

  @override
  String get onlyCreatorCanEditStarting =>
      'Só quem criou a caixa pode editar o saldo inicial.';

  @override
  String get onlyYouEditStarting =>
      'Só você pode editar este montante inicial.';

  @override
  String get onlyCreatorEditAmount =>
      'Só o criador da caixa pode editar este montante.';

  @override
  String get createdBy => 'Criado por';

  @override
  String get created => 'Criado';

  @override
  String get receipt => 'Recibo';

  @override
  String get attached => 'Anexado';

  @override
  String get auditTrail => 'Histórico de auditoria';

  @override
  String get auditTrailSubtitle =>
      'Histórico só de adição. Ninguém pode editar ou apagar estas entradas.';

  @override
  String get noAuditYet => 'Ainda sem entradas de auditoria.';

  @override
  String get deleteMovement => 'Eliminar movimento?';

  @override
  String get deleteStartingBalance => 'Eliminar saldo inicial?';

  @override
  String get softDeleteHint =>
      'Isto elimina temporariamente o movimento durante 24 horas. Pode anular a partir do aviso ou deste ecrã.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get movementDeletedUndo => 'Movimento eliminado — Anular';

  @override
  String get undo => 'Anular';

  @override
  String get movementRestored => 'Movimento restaurado';

  @override
  String get softDeletedCanUndo =>
      'Eliminado temporariamente — ainda pode anular em 24 horas.';

  @override
  String get softDeletedExpired =>
      'Eliminado temporariamente — o prazo para anular expirou.';

  @override
  String get undoDelete => 'Anular eliminação';

  @override
  String get actionCreate => 'Criar';

  @override
  String get actionUpdate => 'Atualizar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get groupNotFound => 'Grupo não encontrado';

  @override
  String get movementNotFound => 'Movimento não encontrado';

  @override
  String get couldNotLoadGroups =>
      'Não foi possível carregar os grupos. Verifique a configuração do Firebase.';

  @override
  String get onboardingTitle1 => 'Uma caixa partilhada';

  @override
  String get onboardingBody1 =>
      'Controlo sozinho ou com amigos. Num grupo partilhado todos podem adicionar depósitos e despesas — sem hierarquia de admins.';

  @override
  String get onboardingTitle2 => 'Histórico completo';

  @override
  String get onboardingBody2 =>
      'Cada alteração é registada. A confiança vem da transparência, não das permissões.';

  @override
  String get onboardingTitle3 => 'Convidar com um código';

  @override
  String get onboardingBody3 =>
      'Crie um grupo ou entre com um código de 6 caracteres.';

  @override
  String get welcomeSubtitle =>
      'Controle o seu dinheiro sozinho ou com outras pessoas.';

  @override
  String get validStartingAmount =>
      'Introduza um montante inicial válido (ou deixe vazio).';

  @override
  String get manageGroup => 'Gerir grupo';

  @override
  String get renameGroup => 'Mudar nome do grupo';

  @override
  String get renameGroupHint => 'Introduza um novo nome para esta caixa.';

  @override
  String get save => 'Guardar';

  @override
  String get manageMembers => 'Gerir membros';

  @override
  String get removeMember => 'Remover';

  @override
  String removeMemberConfirm(String name) {
    return 'Remover $name deste grupo?';
  }

  @override
  String get memberRemoved => 'Membro removido';

  @override
  String get cannotRemoveCreator => 'Não pode remover o criador do grupo.';

  @override
  String get deleteGroup => 'Eliminar grupo';

  @override
  String get deleteGroupConfirm => 'Eliminar este grupo?';

  @override
  String get deleteGroupHint =>
      'Isto elimina permanentemente o grupo, os membros e todos os movimentos. Não pode ser anulado.';

  @override
  String get groupDeleted => 'Grupo eliminado';

  @override
  String get groupRenamed => 'Grupo renomeado';

  @override
  String get creator => 'Criador';

  @override
  String get changeGroupPhoto => 'Alterar foto do grupo';

  @override
  String get groupPhotoUpdated => 'Foto do grupo atualizada';

  @override
  String get leaveGroup => 'Sair do grupo';

  @override
  String get leaveGroupHint =>
      'Vai sair deste grupo, mas os seus movimentos permanecem no histórico.';

  @override
  String get leftGroup => 'Saiu do grupo';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get changePhoto => 'Alterar foto';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get incorrectCredentials => 'E-mail ou palavra-passe incorretos.';

  @override
  String get firebaseNotConfigured =>
      'O Firebase ainda não está configurado. Adicione o google-services.json.';

  @override
  String get signInFailed => 'Falha ao entrar. Tente novamente.';

  @override
  String get signUpFailed => 'Falha no registo. Tente novamente.';

  @override
  String get googleSignInCanceled => 'Início de sessão com Google cancelado.';

  @override
  String get googleSignInConfigError =>
      'O Google Sign-In não está configurado. Adicione o SHA-1 no Firebase e descarregue um novo google-services.json.';

  @override
  String get googleSignInFailed =>
      'Falha no início de sessão com Google. Tente novamente.';

  @override
  String get forceUpdateTitle => 'Atualização obrigatória';

  @override
  String get forceUpdateBody =>
      'É necessária uma nova versão do EnCaisse. Atualize na loja.';

  @override
  String get updateAvailableTitle => 'Atualização disponível';

  @override
  String get updateAvailableBody =>
      'Há uma nova versão do EnCaisse com melhorias importantes.';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get updateLater => 'Mais tarde';

  @override
  String get emailAlreadyInUse => 'Já existe uma conta com este e-mail.';

  @override
  String get weakPassword => 'Escolha uma palavra-passe mais forte.';

  @override
  String get member => 'Membro';

  @override
  String get aMember => 'Um membro';

  @override
  String get someoneJoined => 'Alguém entrou';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name entrou em $group';
  }

  @override
  String get joinAGroup => 'Entrar num grupo';

  @override
  String errorWithDetails(String error) {
    return 'Erro: $error';
  }

  @override
  String get enterValidAmountGtZero =>
      'Introduza um montante válido maior que zero.';

  @override
  String couldNotLoadAudit(String error) {
    return 'Não foi possível carregar a auditoria: $error';
  }

  @override
  String get newMovementNotify => 'Novo movimento';

  @override
  String get depositNotifyTitle => 'Novo depósito';

  @override
  String get expenseNotifyTitle => 'Nova despesa';

  @override
  String get movementUpdatedNotify => 'Movimento atualizado';

  @override
  String get movementDeletedNotify => 'Movimento eliminado';

  @override
  String get movementRestoredNotify => 'Movimento restaurado';

  @override
  String addedDeposit(String name, String title) {
    return '$name adicionou um depósito: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name adicionou uma despesa: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name adicionou um depósito de $amount: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name adicionou uma despesa de $amount: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name atualizou: $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name eliminou: $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name restaurou: $title';
  }

  @override
  String get deletedMarker => 'eliminado';

  @override
  String get insufficientBalance =>
      'Saldo insuficiente. Isto deixaria a caixa negativa.';

  @override
  String get dateLabel => 'Data';

  @override
  String get timeLabel => 'Hora';

  @override
  String get verifyEmailTitle => 'Verifique o seu e-mail';

  @override
  String verifyEmailBody(String email) {
    return 'Enviámos um link para $email. Abra-o e depois toque em Continuar.';
  }

  @override
  String get resendVerification => 'Reenviar e-mail';

  @override
  String get verificationEmailSent => 'E-mail de verificação enviado';

  @override
  String get emailVerifiedContinue => 'Continuar';

  @override
  String get emailNotVerifiedYet =>
      'E-mail ainda não verificado. Verifique a caixa de entrada.';

  @override
  String get checkVerification => 'Já verifiquei';

  @override
  String get settleTitle => 'Quem deve a quem';

  @override
  String get settleSubtitle =>
      'Divisão igual da caixa com base em depósitos e despesas.';

  @override
  String get settleSettled => 'Todos estão equilibrados';

  @override
  String settleOwes(String from, String to) {
    return '$from deve a $to';
  }

  @override
  String get memberNet => 'Líquido';

  @override
  String get chartsTitle => 'Gráficos';

  @override
  String get categoryBreakdown => 'Por categoria';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get exportShared => 'Exportação pronta para partilhar';

  @override
  String get exportFailed => 'Não foi possível exportar';

  @override
  String get notifications => 'Notificações';

  @override
  String get noNotifications => 'Ainda sem notificações';

  @override
  String get noNotificationsSubtitle =>
      'A atividade dos seus grupos aparecerá aqui.';

  @override
  String get markAllRead => 'Marcar tudo como lido';

  @override
  String get offlineBanner =>
      'Sem rede. A mostrar dados em cache quando disponíveis.';

  @override
  String get offlineRetry => 'Tentar novamente';

  @override
  String get forceUpdateBodyIos =>
      'É necessária uma nova versão do EnCaisse. Atualize na App Store.';

  @override
  String get openStore => 'Abrir loja';

  @override
  String get insightsTitle => 'Análises';

  @override
  String get insightsOpen => 'Análises';

  @override
  String get yourCaisses => 'As suas caixas';

  @override
  String get homeOverview => 'O seu dinheiro, num só lugar.';

  @override
  String get personalCaisse => 'Caixa pessoal';

  @override
  String get personalCaisseSubtitle =>
      'Um espaço privado para acompanhar o seu dinheiro.';

  @override
  String get personalCaisseName => 'A minha caixa';

  @override
  String get personalBadge => 'Pessoal';

  @override
  String get manageCaisse => 'Gerir a sua caixa';

  @override
  String get renameCaisse => 'Renomear caixa';

  @override
  String get changeCaissePhoto => 'Alterar foto da caixa';

  @override
  String get caissePhotoUpdated => 'Foto da caixa atualizada';

  @override
  String get caisseRenamed => 'Caixa renomeada';

  @override
  String get deleteCaisse => 'Eliminar caixa';

  @override
  String get deleteCaisseConfirm => 'Eliminar esta caixa?';

  @override
  String get deleteCaisseHint =>
      'Isto elimina permanentemente a sua caixa e todos os movimentos. Não é possível desfazer.';

  @override
  String get caisseDeleted => 'Caixa eliminada';

  @override
  String get howToUse => 'Como usar o EnCaisse';

  @override
  String get tourNext => 'Seguinte';

  @override
  String get tourBack => 'Voltar';

  @override
  String get tourSkip => 'Saltar';

  @override
  String get tourDone => 'Percebi';

  @override
  String get tourHome1Title => 'O seu início';

  @override
  String get tourHome1Body =>
      'Esta lista mostra todas as suas caixas. Toque numa para ver depósitos, despesas e o saldo em direto.';

  @override
  String get tourHome2Title => 'Seguir sozinho';

  @override
  String get tourHome2Body =>
      'Precisa de um bloco privado? Toque em + e escolha Caixa pessoal. Sem código, só você.';

  @override
  String get tourHome3Title => 'Partilhar com outros';

  @override
  String get tourHome3Body =>
      'Crie um grupo ou entre com um código de 6 caracteres. Todos veem o mesmo histórico transparente.';

  @override
  String get tourGroup1Title => 'Saldo em direto';

  @override
  String get tourGroup1Body =>
      'O cartão verde é sempre calculado a partir dos movimentos — depósitos menos despesas. Nunca é um total guardado que se possa manipular.';

  @override
  String get tourGroup2Title => 'Adicionar um movimento';

  @override
  String get tourGroup2Body =>
      'Toque em + para um depósito ou despesa. Pode anexar um recibo; cada alteração fica no histórico de auditoria.';

  @override
  String get tourGroup3Title => 'Convite e análises';

  @override
  String get tourGroup3Body =>
      'Partilhe o código para os amigos entrarem. Abra Acerto e gráficos para ver quem deve a quem e o gasto por categoria.';

  @override
  String get tourGroup3BodyPersonal =>
      'Abra Análises para ver as despesas por categoria. Esta caixa é só sua.';

  @override
  String get tapPhotoToChange => 'Toque na foto para alterar';

  @override
  String get tapPhotoToView => 'Toque para ver';

  @override
  String get creatingPersonal => 'A abrir a sua caixa pessoal…';
}
