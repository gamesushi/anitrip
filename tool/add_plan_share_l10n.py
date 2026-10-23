#!/usr/bin/env python3
"""Adds the plan-package share (B4) l10n keys to every lib/l10n/app_*.arb file.

Usage: python3 tool/add_plan_share_l10n.py && flutter gen-l10n
"""
import json
import pathlib

L10N = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"

# key -> {lang: text}
T = {
    "planShareSection": {
        "zh": "分享此巡礼清单", "zh_Hant": "分享此巡禮清單",
        "en": "Share this pilgrimage list", "ja": "この巡礼リストを共有",
        "ko": "이 순례 목록 공유",
        "es": "Compartir esta lista de peregrinación",
        "fr": "Partager cette liste de pèlerinage",
        "it": "Condividi questo elenco di pellegrinaggio",
        "pt": "Compartilhar esta lista de peregrinação",
        "ru": "Поделиться этим списком паломничества",
        "th": "แชร์รายการจาริกแสวงบุญนี้",
        "vi": "Chia sẻ danh sách hành hương này",
        "ms": "Kongsi senarai ziarah ini",
    },
    "planShareSectionDesc": {
        "zh": "把 .sjhplan 连同这段说明一起发到群里或社交平台，对方用 anitrip 打开即可导入同一份清单。",
        "zh_Hant": "把 .sjhplan 連同這段說明一起發到群組或社群平台，對方用 anitrip 開啟即可匯入同一份清單。",
        "en": "Send the .sjhplan file together with this description — the recipient can open it with anitrip to import the exact same list.",
        "ja": ".sjhplan をこの説明と一緒に送れば、受け取った人が anitrip で開いて同じリストを取り込めます。",
        "ko": ".sjhplan 파일을 이 설명과 함께 보내면, 받는 사람이 anitrip으로 열어 동일한 목록을 가져올 수 있습니다.",
        "es": "Envía el archivo .sjhplan junto con esta descripción; quien lo reciba puede abrirlo con anitrip e importar la misma lista.",
        "fr": "Envoyez le fichier .sjhplan avec cette description : le destinataire peut l’ouvrir avec anitrip pour importer exactement la même liste.",
        "it": "Invia il file .sjhplan insieme a questa descrizione: chi lo riceve può aprirlo con anitrip e importare la stessa lista.",
        "pt": "Envie o arquivo .sjhplan junto com esta descrição; quem receber pode abri-lo com o anitrip e importar a mesma lista.",
        "ru": "Отправьте файл .sjhplan вместе с этим описанием — получатель сможет открыть его в anitrip и импортировать тот же список.",
        "th": "ส่งไฟล์ .sjhplan พร้อมคำอธิบายนี้ไปได้เลย ผู้รับสามารถเปิดด้วย anitrip เพื่อนำเข้ารายการเดียวกัน",
        "vi": "Gửi tệp .sjhplan kèm đoạn mô tả này — người nhận có thể mở bằng anitrip để nhập chính xác cùng một danh sách.",
        "ms": "Hantar fail .sjhplan bersama penerangan ini — penerima boleh membukanya dengan anitrip untuk mengimport senarai yang sama.",
    },
    "planShareTitle": {
        "zh": "{name} 巡礼清单", "zh_Hant": "{name} 巡禮清單",
        "en": "{name} pilgrimage list", "ja": "{name} 巡礼リスト",
        "ko": "{name} 순례 목록",
        "es": "Lista de peregrinación: {name}",
        "fr": "Liste de pèlerinage : {name}",
        "it": "Elenco di pellegrinaggio: {name}",
        "pt": "Lista de peregrinação: {name}",
        "ru": "Список паломничества: {name}",
        "th": "รายการจาริกแสวงบุญ {name}",
        "vi": "Danh sách hành hương {name}",
        "ms": "Senarai ziarah {name}",
    },
    "planShareStats": {
        "zh": "{works} 部作品 · {points} 个巡礼点",
        "zh_Hant": "{works} 部作品 · {points} 個巡禮點",
        "en": "{works} works · {points} spots",
        "ja": "作品 {works} 件 · 巡礼地 {points} 件",
        "ko": "작품 {works}개 · 순례지 {points}곳",
        "es": "{works} obras · {points} lugares",
        "fr": "{works} œuvres · {points} lieux",
        "it": "{works} opere · {points} luoghi",
        "pt": "{works} obras · {points} locais",
        "ru": "Работ: {works} · мест: {points}",
        "th": "{works} เรื่อง · {points} จุด",
        "vi": "{works} tác phẩm · {points} địa điểm",
        "ms": "{works} karya · {points} lokasi",
    },
    "planShareArea": {
        "zh": "地区：{area}", "zh_Hant": "地區：{area}",
        "en": "Area: {area}", "ja": "エリア：{area}", "ko": "지역: {area}",
        "es": "Zona: {area}", "fr": "Région : {area}", "it": "Zona: {area}",
        "pt": "Área: {area}", "ru": "Регион: {area}",
        "th": "พื้นที่: {area}", "vi": "Khu vực: {area}",
        "ms": "Kawasan: {area}",
    },
    "planShareProgress": {
        "zh": "已打卡 {completed}/{total}（{percent}%）",
        "zh_Hant": "已打卡 {completed}/{total}（{percent}%）",
        "en": "Checked in {completed}/{total} ({percent}%)",
        "ja": "巡礼済み {completed}/{total}（{percent}%）",
        "ko": "인증 {completed}/{total} ({percent}%)",
        "es": "Visitados {completed}/{total} ({percent}%)",
        "fr": "Visités {completed}/{total} ({percent} %)",
        "it": "Visitati {completed}/{total} ({percent}%)",
        "pt": "Visitados {completed}/{total} ({percent}%)",
        "ru": "Отмечено {completed}/{total} ({percent}%)",
        "th": "เช็คอินแล้ว {completed}/{total} ({percent}%)",
        "vi": "Đã check-in {completed}/{total} ({percent}%)",
        "ms": "Telah dikunjungi {completed}/{total} ({percent}%)",
    },
    "planShareRecords": {
        "zh": "含 {count} 条巡礼记录", "zh_Hant": "含 {count} 條巡禮記錄",
        "en": "Includes {count} visit records",
        "ja": "巡礼記録 {count} 件を含む", "ko": "순례 기록 {count}건 포함",
        "es": "Incluye {count} registros de visita",
        "fr": "Comprend {count} relevés de visite",
        "it": "Include {count} registrazioni di visita",
        "pt": "Inclui {count} registos de visita",
        "ru": "Включает {count} записей посещений",
        "th": "รวมบันทึกการจาริก {count} รายการ",
        "vi": "Bao gồm {count} bản ghi hành hương",
        "ms": "Termasuk {count} rekod lawatan",
    },
    "planShareFooter": {
        "zh": "用 anitrip 打开 .sjhplan 即可导入同一份清单",
        "zh_Hant": "用 anitrip 開啟 .sjhplan 即可匯入同一份清單",
        "en": "Open the .sjhplan with anitrip to import the same list",
        "ja": ".sjhplan を anitrip で開けば同じリストを取り込めます",
        "ko": ".sjhplan을 anitrip으로 열면 동일한 목록을 가져올 수 있습니다",
        "es": "Abre el .sjhplan con anitrip para importar la misma lista",
        "fr": "Ouvrez le .sjhplan avec anitrip pour importer la même liste",
        "it": "Apri il .sjhplan con anitrip per importare la stessa lista",
        "pt": "Abra o .sjhplan com o anitrip para importar a mesma lista",
        "ru": "Откройте .sjhplan в anitrip, чтобы импортировать тот же список",
        "th": "เปิด .sjhplan ด้วย anitrip เพื่อนำเข้ารายการเดียวกัน",
        "vi": "Mở .sjhplan bằng anitrip để nhập cùng một danh sách",
        "ms": "Buka .sjhplan dengan anitrip untuk mengimport senarai yang sama",
    },
    "planShareEmpty": {
        "zh": "还没有巡礼点，先添加几个再分享吧",
        "zh_Hant": "還沒有巡禮點，先新增幾個再分享吧",
        "en": "No spots yet — add a few before sharing",
        "ja": "巡礼地がまだありません。いくつか追加してから共有しましょう",
        "ko": "아직 순례지가 없습니다. 몇 개 추가한 뒤 공유하세요",
        "es": "Todavía no hay lugares: añade algunos antes de compartir",
        "fr": "Aucun lieu pour l’instant : ajoutez-en quelques-uns avant de partager",
        "it": "Nessun luogo ancora: aggiungine alcuni prima di condividere",
        "pt": "Ainda sem locais: adicione alguns antes de compartilhar",
        "ru": "Пока нет мест — добавьте несколько перед публикацией",
        "th": "ยังไม่มีจุดจาริก เพิ่มสักสองสามจุดก่อนแชร์",
        "vi": "Chưa có địa điểm nào — hãy thêm vài địa điểm trước khi chia sẻ",
        "ms": "Belum ada lokasi ziarah — tambah beberapa sebelum berkongsi",
    },
    "planShareCopy": {
        "zh": "复制分享文案", "zh_Hant": "複製分享文案",
        "en": "Copy share text", "ja": "共有文をコピー",
        "ko": "공유 문구 복사", "es": "Copiar texto para compartir",
        "fr": "Copier le texte de partage",
        "it": "Copia il testo di condivisione",
        "pt": "Copiar texto de partilha", "ru": "Скопировать текст",
        "th": "คัดลอกข้อความแชร์", "vi": "Sao chép nội dung chia sẻ",
        "ms": "Salin teks kongsi",
    },
    "planShareCopied": {
        "zh": "分享文案已复制", "zh_Hant": "分享文案已複製",
        "en": "Share text copied", "ja": "共有文をコピーしました",
        "ko": "공유 문구를 복사했습니다",
        "es": "Texto para compartir copiado",
        "fr": "Texte de partage copié",
        "it": "Testo di condivisione copiato",
        "pt": "Texto de partilha copiado", "ru": "Текст скопирован",
        "th": "คัดลอกข้อความแชร์แล้ว", "vi": "Đã sao chép nội dung chia sẻ",
        "ms": "Teks kongsi disalin",
    },
    "planShareFile": {
        "zh": "分享 .sjhplan 文件", "zh_Hant": "分享 .sjhplan 檔案",
        "en": "Share .sjhplan file", "ja": ".sjhplan を共有",
        "ko": ".sjhplan 파일 공유", "es": "Compartir archivo .sjhplan",
        "fr": "Partager le fichier .sjhplan",
        "it": "Condividi il file .sjhplan",
        "pt": "Compartilhar arquivo .sjhplan",
        "ru": "Поделиться файлом .sjhplan", "th": "แชร์ไฟล์ .sjhplan",
        "vi": "Chia sẻ tệp .sjhplan", "ms": "Kongsi fail .sjhplan",
    },
    "planShareFileDesc": {
        "zh": "调起系统分享，把数据包和上面的说明一起发出去",
        "zh_Hant": "叫出系統分享，把資料包和上面的說明一起送出",
        "en": "Opens the system share sheet with the package and the text above",
        "ja": "システム共有を開き、パッケージと上記の説明を一緒に送ります",
        "ko": "시스템 공유를 열어 데이터 패키지와 위 설명을 함께 보냅니다",
        "es": "Abre el panel de compartir con el paquete y el texto de arriba",
        "fr": "Ouvre le menu de partage avec le paquet et le texte ci-dessus",
        "it": "Apre la condivisione di sistema con il pacchetto e il testo sopra",
        "pt": "Abre a partilha do sistema com o pacote e o texto acima",
        "ru": "Открывает системный экспорт с пакетом и текстом выше",
        "th": "เปิดแชร์ของระบบพร้อมแพ็กเกจและข้อความด้านบน",
        "vi": "Mở chia sẻ hệ thống với gói dữ liệu và nội dung ở trên",
        "ms": "Buka perkongsian sistem dengan pakej dan teks di atas",
    },
}

PLACEHOLDERS = {
    "planShareTitle": {"name": "String"},
    "planShareStats": {"works": "int", "points": "int"},
    "planShareArea": {"area": "String"},
    "planShareProgress": {
        "completed": "int",
        "total": "int",
        "percent": "int",
    },
    "planShareRecords": {"count": "int"},
}


def main() -> None:
    for path in sorted(L10N.glob("app_*.arb")):
        lang = path.stem[len("app_"):]
        data = json.loads(path.read_text(encoding="utf-8"))
        for key, texts in T.items():
            value = texts.get(lang) or texts["zh"]
            data[key] = value
            if key in PLACEHOLDERS:
                data["@" + key] = {
                    "placeholders": {
                        name: {"type": kind}
                        for name, kind in PLACEHOLDERS[key].items()
                    }
                }
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print("updated", path.name)


if __name__ == "__main__":
    main()
