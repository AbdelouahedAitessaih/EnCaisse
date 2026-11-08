import json
from pathlib import Path

root = Path("lib/l10n")

meta = {"resetPasswordSent": {"email": {"type": "String"}}}

translations = {
    "en": {
        "forgotPassword": "Forgot password?",
        "resetPasswordTitle": "Reset your password",
        "resetPasswordBody": "Enter your account email and we'll send you a link to choose a new password.",
        "resetPasswordSend": "Send link",
        "resetPasswordSent": "If an account exists for {email}, a reset link is on its way. Check your inbox and spam folder.",
        "resetPasswordTooMany": "Too many attempts. Please wait a few minutes and try again.",
        "resetPasswordFailed": "Could not send the reset email. Check your connection and try again.",
    },
    "fr": {
        "forgotPassword": "Mot de passe oublié ?",
        "resetPasswordTitle": "Réinitialiser le mot de passe",
        "resetPasswordBody": "Saisissez l'e-mail de votre compte et nous vous enverrons un lien pour choisir un nouveau mot de passe.",
        "resetPasswordSend": "Envoyer le lien",
        "resetPasswordSent": "Si un compte existe pour {email}, un lien de réinitialisation arrive. Vérifiez votre boîte de réception et vos spams.",
        "resetPasswordTooMany": "Trop de tentatives. Patientez quelques minutes puis réessayez.",
        "resetPasswordFailed": "Impossible d'envoyer l'e-mail. Vérifiez votre connexion et réessayez.",
    },
    "es": {
        "forgotPassword": "¿Olvidaste tu contraseña?",
        "resetPasswordTitle": "Restablecer contraseña",
        "resetPasswordBody": "Introduce el correo de tu cuenta y te enviaremos un enlace para elegir una nueva contraseña.",
        "resetPasswordSend": "Enviar enlace",
        "resetPasswordSent": "Si existe una cuenta para {email}, recibirás un enlace. Revisa tu bandeja de entrada y el spam.",
        "resetPasswordTooMany": "Demasiados intentos. Espera unos minutos e inténtalo de nuevo.",
        "resetPasswordFailed": "No se pudo enviar el correo. Revisa tu conexión e inténtalo de nuevo.",
    },
    "pt": {
        "forgotPassword": "Esqueceu a palavra-passe?",
        "resetPasswordTitle": "Redefinir palavra-passe",
        "resetPasswordBody": "Introduza o e-mail da sua conta e enviaremos um link para escolher uma nova palavra-passe.",
        "resetPasswordSend": "Enviar link",
        "resetPasswordSent": "Se existir uma conta para {email}, receberá um link. Verifique a caixa de entrada e o spam.",
        "resetPasswordTooMany": "Demasiadas tentativas. Aguarde alguns minutos e tente novamente.",
        "resetPasswordFailed": "Não foi possível enviar o e-mail. Verifique a ligação e tente novamente.",
    },
    "ar": {
        "forgotPassword": "نسيت كلمة المرور؟",
        "resetPasswordTitle": "إعادة تعيين كلمة المرور",
        "resetPasswordBody": "أدخل بريد حسابك وسنرسل لك رابطًا لاختيار كلمة مرور جديدة.",
        "resetPasswordSend": "إرسال الرابط",
        "resetPasswordSent": "إذا كان هناك حساب لـ {email} فسيصلك رابط إعادة التعيين. تحقق من البريد الوارد والرسائل غير المرغوب فيها.",
        "resetPasswordTooMany": "محاولات كثيرة جدًا. انتظر بضع دقائق ثم أعد المحاولة.",
        "resetPasswordFailed": "تعذّر إرسال البريد. تحقق من اتصالك وأعد المحاولة.",
    },
    "zh": {
        "forgotPassword": "忘记密码？",
        "resetPasswordTitle": "重置密码",
        "resetPasswordBody": "输入账户邮箱，我们会发送一个设置新密码的链接。",
        "resetPasswordSend": "发送链接",
        "resetPasswordSent": "如果 {email} 存在账户，重置链接即将送达。请查看收件箱和垃圾邮件。",
        "resetPasswordTooMany": "尝试次数过多，请稍等几分钟后再试。",
        "resetPasswordFailed": "无法发送重置邮件，请检查网络后重试。",
    },
    "hi": {
        "forgotPassword": "पासवर्ड भूल गए?",
        "resetPasswordTitle": "पासवर्ड रीसेट करें",
        "resetPasswordBody": "अपने खाते का ईमेल दर्ज करें, हम नया पासवर्ड चुनने का लिंक भेजेंगे।",
        "resetPasswordSend": "लिंक भेजें",
        "resetPasswordSent": "यदि {email} के लिए खाता है, तो रीसेट लिंक आ रहा है। इनबॉक्स और स्पैम देखें।",
        "resetPasswordTooMany": "बहुत अधिक प्रयास। कुछ मिनट रुककर फिर कोशिश करें।",
        "resetPasswordFailed": "ईमेल नहीं भेजा जा सका। कनेक्शन जाँचें और फिर कोशिश करें।",
    },
    "ru": {
        "forgotPassword": "Забыли пароль?",
        "resetPasswordTitle": "Сброс пароля",
        "resetPasswordBody": "Введите email аккаунта, и мы пришлём ссылку для выбора нового пароля.",
        "resetPasswordSend": "Отправить ссылку",
        "resetPasswordSent": "Если для {email} есть аккаунт, ссылка для сброса уже в пути. Проверьте входящие и спам.",
        "resetPasswordTooMany": "Слишком много попыток. Подождите несколько минут и повторите.",
        "resetPasswordFailed": "Не удалось отправить письмо. Проверьте подключение и повторите.",
    },
    "ja": {
        "forgotPassword": "パスワードをお忘れですか？",
        "resetPasswordTitle": "パスワードの再設定",
        "resetPasswordBody": "アカウントのメールアドレスを入力すると、新しいパスワードを設定するリンクをお送りします。",
        "resetPasswordSend": "リンクを送信",
        "resetPasswordSent": "{email} のアカウントが存在する場合、再設定リンクを送信しました。受信トレイと迷惑メールをご確認ください。",
        "resetPasswordTooMany": "試行回数が多すぎます。数分待ってから再度お試しください。",
        "resetPasswordFailed": "メールを送信できませんでした。接続を確認して再度お試しください。",
    },
}

expected = set(translations["en"])
for locale, values in translations.items():
    assert set(values) == expected, locale
    path = root / f"app_{locale}.arb"
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    data.update(values)
    if locale == "en":
        for key, placeholders in meta.items():
            data[f"@{key}"] = {"placeholders": placeholders}
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8-sig",
    )
    print(locale, len(values))
