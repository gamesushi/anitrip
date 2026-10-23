#!/usr/bin/env python3
"""Adds the radar l10n keys to every lib/l10n/app_*.arb file."""
import json
import pathlib

L10N = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"

T = {
    "radarTooltip": {
        "zh": "周边圣地雷达", "zh_Hant": "周邊聖地雷達",
        "en": "Nearby Pilgrimage Radar", "ja": "周辺の聖地レーダー",
        "ko": "주변 성지 레이더", "es": "Radar de lugares sagrados cercanos",
        "fr": "Radar des lieux de pèlerinage proches", "it": "Radar dei luoghi anime vicini",
        "pt": "Radar de locais sagrados próximos", "ru": "Радар аниме-мест поблизости",
        "th": "เรดาร์สถานที่อนิเมะใกล้เคียง", "vi": "Radar thánh địa anime lân cận",
        "ms": "Radar tempat anime berhampiran",
    },
    "radarScanning": {
        "zh": "正在扫描周边圣地...", "zh_Hant": "正在掃描周邊聖地...",
        "en": "Scanning nearby pilgrimage spots...", "ja": "周辺の巡礼スポットをスキャン中...",
        "ko": "주변 순례 포인트를 스캔하는 중...", "es": "Escaneando lugares sagrados cercanos...",
        "fr": "Recherche des lieux de pèlerinage proches...", "it": "Scansione dei luoghi anime nelle vicinanze...",
        "pt": "Escaneando locais de peregrinação próximos...", "ru": "Сканирование мест паломничества поблизости...",
        "th": "กำลังสแกนสถานที่อนิเมะใกล้เคียง...", "vi": "Đang quét các điểm thánh địa lân cận...",
        "ms": "Mengimbas tempat anime berhampiran...",
    },
    "radarFoundCount": {
        "zh": "附近发现 {count} 处动漫圣地", "zh_Hant": "附近發現 {count} 處動漫聖地",
        "en": "Found {count} anime spots nearby", "ja": "近くに {count} か所のアニメ聖地を発見",
        "ko": "주변에서 애니 성지 {count}곳 발견", "es": "Se encontraron {count} lugares de anime cercanos",
        "fr": "{count} lieux d'anime trouvés à proximité", "it": "Trovati {count} luoghi anime nelle vicinanze",
        "pt": "{count} locais de anime encontrados por perto", "ru": "Найдено аниме-мест поблизости: {count}",
        "th": "พบสถานที่อนิเมะใกล้เคียง {count} แห่ง", "vi": "Tìm thấy {count} thánh địa anime gần đây",
        "ms": "Menemui {count} tempat anime berdekatan",
    },
    "radarNoSpotsFound": {
        "zh": "周边 5km 内未收录动漫圣地", "zh_Hant": "周邊 5km 內未收錄動漫聖地",
        "en": "No anime spots found within 5 km", "ja": "周辺5km以内にアニメ聖地は見つかりませんでした",
        "ko": "주변 5km 이내에 등록된 애니 성지가 없습니다", "es": "No se encontraron lugares de anime en un radio de 5 km",
        "fr": "Aucun lieu d'anime trouvé dans un rayon de 5 km", "it": "Nessun luogo anime trovato entro 5 km",
        "pt": "Nenhum local de anime encontrado em um raio de 5 km", "ru": "В радиусе 5 км аниме-мест не найдено",
        "th": "ไม่พบสถานที่อนิเมะในรัศมี 5 กม.", "vi": "Không tìm thấy thánh địa anime nào trong bán kính 5 km",
        "ms": "Tiada tempat anime ditemui dalam lingkungan 5 km",
    },
    "radarRescanArea": {
        "zh": "在此区域扫描", "zh_Hant": "在此區域掃描",
        "en": "Scan this area", "ja": "このエリアを再スキャン",
        "ko": "이 지역 다시 스캔", "es": "Escanear esta zona",
        "fr": "Scanner cette zone", "it": "Scansiona quest'area",
        "pt": "Escanear esta área", "ru": "Сканировать эту область",
        "th": "สแกนบริเวณนี้", "vi": "Quét khu vực này",
        "ms": "Imbas kawasan ini",
    },
    "radarClose": {
        "zh": "关闭雷达", "zh_Hant": "關閉雷達",
        "en": "Close radar", "ja": "レーダーを閉じる",
        "ko": "레이더 닫기", "es": "Cerrar radar",
        "fr": "Fermer le radar", "it": "Chiudi radar",
        "pt": "Fechar radar", "ru": "Закрыть радар",
        "th": "ปิดเรดาร์", "vi": "Đóng radar",
        "ms": "Tutup radar",
    },
    "radarDistance": {
        "zh": "距扫描中心 {distance}", "zh_Hant": "距掃描中心 {distance}",
        "en": "{distance} from scan center", "ja": "スキャン中心から {distance}",
        "ko": "스캔 중심에서 {distance}", "es": "A {distance} del centro de escaneo",
        "fr": "À {distance} du centre de recherche", "it": "A {distance} dal centro di scansione",
        "pt": "A {distance} do centro de escaneamento", "ru": "{distance} от центра сканирования",
        "th": "{distance} จากจุดศูนย์กลางการสแกน", "vi": "Cách tâm quét {distance}",
        "ms": "{distance} dari pusat imbasan",
    },
    "radarAddToPlan": {
        "zh": "导入此作品至计划", "zh_Hant": "匯入此作品至計劃",
        "en": "Import work to plan", "ja": "作品を計画に追加",
        "ko": "작품을 계획에 추가", "es": "Importar obra al plan",
        "fr": "Importer l'œuvre dans le plan", "it": "Importa opera nel piano",
        "pt": "Importar obra para o plano", "ru": "Добавить работу в план",
        "th": "นำเข้าเรื่องนี้ลงแผน", "vi": "Thêm tác phẩm vào kế hoạch",
        "ms": "Import karya ke dalam pelan",
    },
    "radarAlreadyInPlan": {
        "zh": "已在计划中", "zh_Hant": "已在計劃中",
        "en": "Already in plan", "ja": "計画に追加済み",
        "ko": "이미 계획에 있음", "es": "Ya en el plan",
        "fr": "Déjà dans le plan", "it": "Già nel piano",
        "pt": "Já no plano", "ru": "Уже в плане",
        "th": "มีอยู่ในแผนแล้ว", "vi": "Đã có trong kế hoạch",
        "ms": "Sudah ada dalam pelan",
    },
    "radarViewInPlan": {
        "zh": "在计划中查看", "zh_Hant": "在計劃中查看",
        "en": "View in plan", "ja": "計画内で表示",
        "ko": "계획에서 보기", "es": "Ver en el plan",
        "fr": "Voir dans le plan", "it": "Visualizza nel piano",
        "pt": "Ver no plano", "ru": "Посмотреть в плане",
        "th": "ดูในแผน", "vi": "Xem trong kế hoạch",
        "ms": "Lihat dalam pelan",
    },
    "radarImportSuccess": {
        "zh": "已成功导入 {count} 个巡礼点", "zh_Hant": "已成功匯入 {count} 個巡禮點",
        "en": "Successfully imported {count} spots", "ja": "{count} か所の巡礼ポイントを追加しました",
        "ko": "성지 순례 포인트 {count}개를 추가했습니다", "es": "Se importaron {count} puntos con éxito",
        "fr": "{count} points importés avec succès", "it": "Importati con successo {count} punti",
        "pt": "{count} pontos importados com sucesso", "ru": "Успешно импортировано точек: {count}",
        "th": "นำเข้าสำเร็จ {count} จุด", "vi": "Đã nhập thành công {count} điểm",
        "ms": "Berjaya mengimport {count} tempat",
    },
    "radarSpotDetail": {
        "zh": "圣地详情", "zh_Hant": "聖地詳情",
        "en": "Spot details", "ja": "聖地の詳細",
        "ko": "성지 상세 정보", "es": "Detalles del lugar",
        "fr": "Détails du lieu", "it": "Dettagli del luogo",
        "pt": "Detalhes do local", "ru": "О месте",
        "th": "รายละเอียดสถานที่", "vi": "Chi tiết thánh địa",
        "ms": "Butiran tempat",
    },
    "radarLoadingPoint": {
        "zh": "正在加载点位信息...", "zh_Hant": "正在載入點位資訊...",
        "en": "Loading spot info...", "ja": "スポット情報を読み込み中...",
        "ko": "포인트 정보를 불러오는 중...", "es": "Cargando información del lugar...",
        "fr": "Chargement des informations du lieu...", "it": "Caricamento informazioni del luogo...",
        "pt": "Carregando informações do local...", "ru": "Загрузка информации о точке...",
        "th": "กำลังโหลดข้อมูลจุด...", "vi": "Đang tải thông tin địa điểm...",
        "ms": "Memuatkan maklumat tempat...",
    },
}

PLACEHOLDERS = {
    "radarFoundCount": {"count": "int"},
    "radarDistance": {"distance": "String"},
    "radarImportSuccess": {"count": "int"},
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
