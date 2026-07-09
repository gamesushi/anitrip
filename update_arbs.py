import json

keys = {
    "settingsReset": {"zh": "恢复初始设置", "en": "Reset Settings", "fr": "Réinitialiser", "ko": "초기화", "zh_Hant": "恢復初始設置"},
    "settingsResetConfirmSubtitle": {"zh": "所有外观、拍摄和地图设置将恢复为默认值。", "en": "All appearance, camera, and map settings will be restored to defaults.", "fr": "Tous les paramètres d'apparence, d'appareil photo et de carte seront restaurés aux valeurs par défaut.", "ko": "모든 모양, 카메라 및 지도 설정이 기본값으로 복원됩니다.", "zh_Hant": "所有外觀、拍攝和地圖設置將恢復為默認值。"},
    "settingsThemeColor": {"zh": "主题色", "en": "Theme Color", "fr": "Couleur du thème", "ko": "테마 색상", "zh_Hant": "主題色"},
    "settingsThemeColorSubtitle": {"zh": "影响应用整体配色", "en": "Affects the overall color scheme", "fr": "Affecte le schéma de couleurs", "ko": "전체 색상 구성표에 영향", "zh_Hant": "影響應用整體配色"},
    "settingsThemeMode": {"zh": "主题模式", "en": "Theme Mode", "fr": "Mode du thème", "ko": "테마 모드", "zh_Hant": "主題模式"},
    "settingsThemeLight": {"zh": "浅色模式", "en": "Light Mode", "fr": "Mode clair", "ko": "라이트 모드", "zh_Hant": "淺色模式"},
    "settingsThemeDark": {"zh": "深色模式", "en": "Dark Mode", "fr": "Mode sombre", "ko": "다크 모드", "zh_Hant": "深色模式"},
    "settingsThemeSystem": {"zh": "跟随系统", "en": "System", "fr": "Système", "ko": "시스템", "zh_Hant": "跟隨系統"},
    "settingsUiScale": {"zh": "页面缩放", "en": "UI Scale", "fr": "Échelle UI", "ko": "UI 배율", "zh_Hant": "頁面縮放"},
    "settingsUiScaleSubtitle": {"zh": "调整界面整体大小（不影响参考图）", "en": "Adjust UI size (does not affect references)", "fr": "Ajuster la taille de l'UI (n'affecte pas les références)", "ko": "UI 크기 조정 (참고 이미지 영향 없음)", "zh_Hant": "調整界面整體大小（不影響參考圖）"},
    "settingsCameraRatio": {"zh": "拍摄图片比例", "en": "Camera Aspect Ratio", "fr": "Ratio de l'appareil", "ko": "카메라 비율", "zh_Hant": "拍攝圖片比例"},
    "settingsCameraZoom": {"zh": "相机缩放", "en": "Camera Zoom", "fr": "Zoom de la caméra", "ko": "카메라 확대", "zh_Hant": "相機縮放"},
    "settingsPhotoBackup": {"zh": "照片备份", "en": "Photo Backup", "fr": "Sauvegarde photo", "ko": "사진 백업", "zh_Hant": "照片備份"},
    "settingsPhotoBackupSubtitle": {"zh": "保存巡礼照片到相册", "en": "Save pilgrimage photos to gallery", "fr": "Enregistrer les photos dans la galerie", "ko": "성지순례 사진을 갤러리에 저장", "zh_Hant": "保存巡禮照片到相冊"},
    "settingsAutoSaveComparison": {"zh": "自动保存对比图", "en": "Auto-save Comparison", "fr": "Sauvegarde auto comp.", "ko": "비교 사진 자동 저장", "zh_Hant": "自動保存對比圖"},
    "settingsAutoSaveComparisonSubtitle": {"zh": "保存记录时保存到相册", "en": "Save to gallery when recording", "fr": "Enregistrer dans la galerie lors de l'enregistrement", "ko": "기록할 때 갤러리에 저장", "zh_Hant": "保存記錄時保存到相冊"},
    "settingsDesktop": {"zh": "桌面端", "en": "Desktop", "fr": "Bureau", "ko": "데스크톱", "zh_Hant": "桌面端"},
    "settingsDesktopSubtitle": {"zh": "启动器、数据目录等", "en": "Launcher, data dir, etc.", "fr": "Lanceur, rép. de données", "ko": "런처, 데이터 디렉토리 등", "zh_Hant": "啟動器、數據目錄等"},
    "desktopLauncherChecking": {"zh": "桌面启动器 检查中", "en": "Checking launcher...", "fr": "Vérification du lanceur...", "ko": "런처 확인 중...", "zh_Hant": "桌面啟動器 檢查中"},
    "desktopLauncherUnavailable": {"zh": "桌面启动器 不可用", "en": "Launcher unavailable", "fr": "Lanceur indisponible", "ko": "런처 사용 불가", "zh_Hant": "桌面啟動器 不可用"},
    "desktopSystemDataDir": {"zh": "系统数据目录", "en": "System Data Dir", "fr": "Rép. système", "ko": "시스템 데이터 폴더", "zh_Hant": "系統數據目錄"},
    "desktopPortableDir": {"zh": "便携目录", "en": "Portable Dir", "fr": "Rép. portable", "ko": "포터블 폴더", "zh_Hant": "便攜目錄"},
    "desktopAppDataDir": {"zh": "应用数据目录", "en": "App Data Dir", "fr": "Rép. application", "ko": "앱 데이터 폴더", "zh_Hant": "應用數據目錄"},
    "desktopLauncherAvailable": {"zh": "桌面启动器 可用", "en": "Launcher available", "fr": "Lanceur disponible", "ko": "런처 사용 가능", "zh_Hant": "桌面啟動器 可用"},
    "settingsFontSmall": {"zh": "小", "en": "Small", "fr": "Petit", "ko": "작게", "zh_Hant": "小"},
    "settingsFontStandard": {"zh": "标准", "en": "Standard", "fr": "Standard", "ko": "표준", "zh_Hant": "標準"},
    "settingsFontLarge": {"zh": "大", "en": "Large", "fr": "Grand", "ko": "크게", "zh_Hant": "大"},
    "settingsFontHuge": {"zh": "特大", "en": "Huge", "fr": "Très grand", "ko": "아주 크게", "zh_Hant": "特大"},
    "msgReplacingRef": {"zh": "正在替换参考图...", "en": "Replacing reference image...", "fr": "Remplacement de l'image de réf...", "ko": "참고 이미지 교체 중...", "zh_Hant": "正在替換參考圖..."},
    "msgReplaceRefFailed": {"zh": "参考图替换失败，请稍后重试。", "en": "Failed to replace reference image. Please try again later.", "fr": "Échec du remplacement. Veuillez réessayer.", "ko": "교체 실패. 나중에 다시 시도해주세요.", "zh_Hant": "參考圖替換失敗，請稍後重試。"},
    "msgReplaceRefSuccess": {"zh": "已替换参考图", "en": "Reference image replaced", "fr": "Image de référence remplacée", "ko": "참고 이미지 교체 완료", "zh_Hant": "已替換參考圖"},
    "msgCannotOpenMap": {"zh": "无法打开 Google Maps。", "en": "Cannot open Google Maps.", "fr": "Impossible d'ouvrir Google Maps.", "ko": "Google 지도를 열 수 없습니다.", "zh_Hant": "無法打開 Google Maps。"},
    "titleMoveToGroup": {"zh": "移动到片区", "en": "Move to Area", "fr": "Déplacer vers la zone", "ko": "그룹으로 이동", "zh_Hant": "移動到片區"},
    "copyLabelPointName": {"zh": "点位名称", "en": "Point Name", "fr": "Nom du point", "ko": "포인트 이름", "zh_Hant": "點位名稱"},
    "copyLabelGroupAnchor": {"zh": "片区关键点", "en": "Area Anchor", "fr": "Ancre de la zone", "ko": "그룹 앵커", "zh_Hant": "片區關鍵點"},
    "labelNote": {"zh": "备注", "en": "Note", "fr": "Note", "ko": "메모", "zh_Hant": "備註"}
}

files = {
    "zh": "lib/l10n/app_zh.arb",
    "en": "lib/l10n/app_en.arb",
    "fr": "lib/l10n/app_fr.arb",
    "ko": "lib/l10n/app_ko.arb",
    "zh_Hant": "lib/l10n/app_zh_Hant.arb"
}

for lang, filepath in files.items():
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, trans in keys.items():
        data[key] = trans[lang]
        
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

