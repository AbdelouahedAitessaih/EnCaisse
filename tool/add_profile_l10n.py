from pathlib import Path

root = Path(r"c:\Users\abdel\Bureau\EnCaisse\lib\l10n")
translations = {
    "fr": {
        "changeGroupPhoto": "Changer la photo du groupe",
        "groupPhotoUpdated": "Photo du groupe mise à jour",
        "leaveGroup": "Quitter le groupe",
        "leaveGroupHint": "Vous quitterez ce groupe, mais vos mouvements resteront dans l'historique.",
        "leftGroup": "Vous avez quitté le groupe",
        "profile": "Profil",
        "editProfile": "Modifier le profil",
        "changePhoto": "Changer la photo",
        "profileUpdated": "Profil mis à jour",
    },
    "ar": {
        "changeGroupPhoto": "تغيير صورة المجموعة",
        "groupPhotoUpdated": "تم تحديث صورة المجموعة",
        "leaveGroup": "مغادرة المجموعة",
        "leaveGroupHint": "ستغادر هذه المجموعة، لكن حركاتك تبقى في السجل.",
        "leftGroup": "غادرت المجموعة",
        "profile": "الملف الشخصي",
        "editProfile": "تعديل الملف الشخصي",
        "changePhoto": "تغيير الصورة",
        "profileUpdated": "تم تحديث الملف الشخصي",
    },
    "es": {
        "changeGroupPhoto": "Cambiar foto del grupo",
        "groupPhotoUpdated": "Foto del grupo actualizada",
        "leaveGroup": "Salir del grupo",
        "leaveGroupHint": "Saldrás de este grupo, pero tus movimientos permanecerán en el historial.",
        "leftGroup": "Has salido del grupo",
        "profile": "Perfil",
        "editProfile": "Editar perfil",
        "changePhoto": "Cambiar foto",
        "profileUpdated": "Perfil actualizado",
    },
    "pt": {
        "changeGroupPhoto": "Alterar foto do grupo",
        "groupPhotoUpdated": "Foto do grupo atualizada",
        "leaveGroup": "Sair do grupo",
        "leaveGroupHint": "Vai sair deste grupo, mas os seus movimentos permanecem no histórico.",
        "leftGroup": "Saiu do grupo",
        "profile": "Perfil",
        "editProfile": "Editar perfil",
        "changePhoto": "Alterar foto",
        "profileUpdated": "Perfil atualizado",
    },
    "zh": {
        "changeGroupPhoto": "更改群组照片",
        "groupPhotoUpdated": "群组照片已更新",
        "leaveGroup": "退出群组",
        "leaveGroupHint": "您将退出此群组，但您的流水仍保留在历史记录中。",
        "leftGroup": "已退出群组",
        "profile": "个人资料",
        "editProfile": "编辑资料",
        "changePhoto": "更换照片",
        "profileUpdated": "资料已更新",
    },
    "hi": {
        "changeGroupPhoto": "समूह फ़ोटो बदलें",
        "groupPhotoUpdated": "समूह फ़ोटो अपडेट हुई",
        "leaveGroup": "समूह छोड़ें",
        "leaveGroupHint": "आप यह समूह छोड़ देंगे, लेकिन आपके लेन-देन इतिहास में रहेंगे।",
        "leftGroup": "आपने समूह छोड़ दिया",
        "profile": "प्रोफ़ाइल",
        "editProfile": "प्रोफ़ाइल संपादित करें",
        "changePhoto": "फ़ोटो बदलें",
        "profileUpdated": "प्रोफ़ाइल अपडेट हुई",
    },
    "ru": {
        "changeGroupPhoto": "Изменить фото группы",
        "groupPhotoUpdated": "Фото группы обновлено",
        "leaveGroup": "Покинуть группу",
        "leaveGroupHint": "Вы покинете группу, но ваши операции останутся в истории.",
        "leftGroup": "Вы покинули группу",
        "profile": "Профиль",
        "editProfile": "Редактировать профиль",
        "changePhoto": "Изменить фото",
        "profileUpdated": "Профиль обновлён",
    },
    "ja": {
        "changeGroupPhoto": "グループ写真を変更",
        "groupPhotoUpdated": "グループ写真を更新しました",
        "leaveGroup": "グループを退出",
        "leaveGroupHint": "グループを退出しますが、取引履歴は残ります。",
        "leftGroup": "グループを退出しました",
        "profile": "プロフィール",
        "editProfile": "プロフィールを編集",
        "changePhoto": "写真を変更",
        "profileUpdated": "プロフィールを更新しました",
    },
}

needle = '  "incorrectCredentials"'
for locale, vals in translations.items():
    path = root / f"app_{locale}.arb"
    text = path.read_text(encoding="utf-8")
    if '"changeGroupPhoto"' in text:
        print("already", locale)
        continue
    insert = "".join(f'  "{k}": "{v}",\n' for k, v in vals.items())
    if needle not in text:
        raise SystemExit(f"missing marker in {path}")
    path.write_text(text.replace(needle, insert + needle, 1), encoding="utf-8", newline="\n")
    print("updated", locale)
