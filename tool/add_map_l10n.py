#!/usr/bin/env python3
"""Adds the multi-work map l10n keys to every lib/l10n/app_*.arb file."""
import json
import pathlib

L10N = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"

# key -> {lang: text}. Placeholders: {selected} {total} {count} {done} {title}
T = {
    "mapWorkFilterAllLabel": {
        "zh": "全部作品 ({total})", "zh_Hant": "全部作品 ({total})",
        "en": "All works ({total})", "ja": "すべての作品 ({total})",
        "ko": "모든 작품 ({total})", "es": "Todas las obras ({total})",
        "fr": "Toutes les œuvres ({total})", "it": "Tutte le opere ({total})",
        "pt": "Todas as obras ({total})", "ru": "Все работы ({total})",
        "th": "ทุกเรื่อง ({total})", "vi": "Tất cả tác phẩm ({total})",
        "ms": "Semua karya ({total})",
    },
    "mapWorkFilterSelectedLabel": {
        "zh": "作品 {selected}/{total}", "zh_Hant": "作品 {selected}/{total}",
        "en": "Works {selected}/{total}", "ja": "作品 {selected}/{total}",
        "ko": "작품 {selected}/{total}", "es": "Obras {selected}/{total}",
        "fr": "Œuvres {selected}/{total}", "it": "Opere {selected}/{total}",
        "pt": "Obras {selected}/{total}", "ru": "Работы {selected}/{total}",
        "th": "เรื่อง {selected}/{total}", "vi": "Tác phẩm {selected}/{total}",
        "ms": "Karya {selected}/{total}",
    },
    "mapWorkFilterTitle": {
        "zh": "选择想去的作品", "zh_Hant": "選擇想去的作品",
        "en": "Choose works to visit", "ja": "行きたい作品を選ぶ",
        "ko": "가고 싶은 작품 선택", "es": "Elige las obras que quieres visitar",
        "fr": "Choisissez les œuvres à visiter",
        "it": "Scegli le opere da visitare",
        "pt": "Escolha as obras que quer visitar",
        "ru": "Выберите работы для посещения",
        "th": "เลือกเรื่องที่อยากไป", "vi": "Chọn tác phẩm muốn đến",
        "ms": "Pilih karya yang ingin dilawati",
    },
    "mapWorkFilterSelectAll": {
        "zh": "全选", "zh_Hant": "全選", "en": "Select all", "ja": "すべて選択",
        "ko": "모두 선택", "es": "Seleccionar todo", "fr": "Tout sélectionner",
        "it": "Seleziona tutto", "pt": "Selecionar tudo",
        "ru": "Выбрать все", "th": "เลือกทั้งหมด", "vi": "Chọn tất cả",
        "ms": "Pilih semua",
    },
    "mapWorkFilterHideUnselected": {
        "zh": "隐藏未勾选的作品", "zh_Hant": "隱藏未勾選的作品",
        "en": "Hide unchecked works", "ja": "未選択の作品を隠す",
        "ko": "선택하지 않은 작품 숨기기", "es": "Ocultar obras sin marcar",
        "fr": "Masquer les œuvres non cochées",
        "it": "Nascondi le opere non selezionate",
        "pt": "Ocultar obras não marcadas",
        "ru": "Скрыть непомеченные работы",
        "th": "ซ่อนเรื่องที่ไม่ได้เลือก", "vi": "Ẩn tác phẩm chưa chọn",
        "ms": "Sembunyikan karya yang tidak ditanda",
    },
    "mapWorkFilterProgress": {
        "zh": "已打卡 {done}/{total}", "zh_Hant": "已打卡 {done}/{total}",
        "en": "Visited {done}/{total}", "ja": "訪問済み {done}/{total}",
        "ko": "방문 {done}/{total}", "es": "Visitados {done}/{total}",
        "fr": "Visités {done}/{total}", "it": "Visitati {done}/{total}",
        "pt": "Visitados {done}/{total}", "ru": "Посещено {done}/{total}",
        "th": "ไปแล้ว {done}/{total}", "vi": "Đã đến {done}/{total}",
        "ms": "Dilawati {done}/{total}",
    },
    "mapSpotTitle": {
        "zh": "该地点有 {count} 部作品", "zh_Hant": "此地點有 {count} 部作品",
        "en": "{count} works at this spot", "ja": "この場所には {count} 作品",
        "ko": "이 장소에는 작품 {count}개", "es": "{count} obras en este lugar",
        "fr": "{count} œuvres à cet endroit", "it": "{count} opere in questo luogo",
        "pt": "{count} obras neste local", "ru": "Работ в этом месте: {count}",
        "th": "สถานที่นี้มี {count} เรื่อง", "vi": "Địa điểm này có {count} tác phẩm",
        "ms": "{count} karya di lokasi ini",
    },
    "mapSpotHint": {
        "zh": "勾选想去的作品，地图只高亮已勾选的作品",
        "zh_Hant": "勾選想去的作品，地圖只會突顯已勾選的作品",
        "en": "Check the works you want to visit; the map highlights only those",
        "ja": "行きたい作品にチェックすると、地図ではその作品だけが強調されます",
        "ko": "가고 싶은 작품을 체크하면 지도에서 해당 작품만 강조됩니다",
        "es": "Marca las obras que quieres visitar; el mapa solo resalta esas",
        "fr": "Cochez les œuvres à visiter ; la carte ne met en avant que celles-ci",
        "it": "Seleziona le opere da visitare: la mappa evidenzia solo quelle",
        "pt": "Marque as obras que quer visitar; o mapa destaca só essas",
        "ru": "Отметьте нужные работы — на карте будут выделены только они",
        "th": "ติ๊กเรื่องที่อยากไป แผนที่จะเน้นเฉพาะเรื่องที่เลือก",
        "vi": "Chọn tác phẩm muốn đến; bản đồ chỉ làm nổi bật các tác phẩm đã chọn",
        "ms": "Tanda karya yang ingin dilawati; peta hanya menonjolkan karya itu",
    },
    "mapFocusBanner": {
        "zh": "仅显示：{title}", "zh_Hant": "僅顯示：{title}",
        "en": "Showing only: {title}", "ja": "表示中：{title}のみ",
        "ko": "표시 중: {title}만", "es": "Mostrando solo: {title}",
        "fr": "Affichage seul : {title}", "it": "Solo: {title}",
        "pt": "Mostrando apenas: {title}", "ru": "Только: {title}",
        "th": "แสดงเฉพาะ: {title}", "vi": "Chỉ hiển thị: {title}",
        "ms": "Hanya papar: {title}",
    },
    "mapFocusClear": {
        "zh": "显示全部作品", "zh_Hant": "顯示全部作品",
        "en": "Show all works", "ja": "すべての作品を表示",
        "ko": "모든 작품 표시", "es": "Mostrar todas las obras",
        "fr": "Afficher toutes les œuvres", "it": "Mostra tutte le opere",
        "pt": "Mostrar todas as obras", "ru": "Показать все работы",
        "th": "แสดงทุกเรื่อง", "vi": "Hiển thị tất cả tác phẩm",
        "ms": "Papar semua karya",
    },
}

PLACEHOLDERS = {
    "mapWorkFilterAllLabel": {"total": "int"},
    "mapWorkFilterSelectedLabel": {"selected": "int", "total": "int"},
    "mapWorkFilterProgress": {"done": "int", "total": "int"},
    "mapSpotTitle": {"count": "int"},
    "mapFocusBanner": {"title": "String"},
}


def main() -> None:
    for path in sorted(L10N.glob("app_*.arb")):
        lang = path.stem[len("app_"):]
        data = json.loads(path.read_text(encoding="utf-8"))
        for key, texts in T.items():
            if key in data:
                continue
            data[key] = texts[lang]
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
