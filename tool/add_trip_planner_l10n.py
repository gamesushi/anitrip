#!/usr/bin/env python3
"""Adds the trip planner (D2) l10n keys to every lib/l10n/app_*.arb file.

Usage: python3 tool/add_trip_planner_l10n.py && flutter gen-l10n
"""
import json
import pathlib

L10N = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"

T = {
    "tripPlannerTitle": {
        "zh": "行程规划", "zh_Hant": "行程規劃",
        "en": "Trip Planner", "ja": "行程プラン", "ko": "일정 계획",
        "es": "Planificador de viaje", "fr": "Planificateur de voyage",
        "it": "Pianificatore di viaggio", "pt": "Planejador de viagem",
        "ru": "Планировщик поездки", "th": "วางแผนการเดินทาง",
        "vi": "Lập kế hoạch hành trình", "ms": "Perancang perjalanan",
    },
    "tripPlannerEmpty": {
        "zh": "还没有巡礼点，先添加几个再规划行程",
        "zh_Hant": "還沒有巡禮點，先新增幾個再規劃行程",
        "en": "Add a few spots before planning the trip",
        "ja": "巡礼地がまだありません。いくつか追加してから行程を組みましょう",
        "ko": "아직 순례지가 없습니다. 몇 곳 추가한 뒤 일정을 계획하세요",
        "es": "Añade algunos lugares antes de planificar el viaje",
        "fr": "Ajoutez quelques lieux avant de planifier le voyage",
        "it": "Aggiungi alcuni luoghi prima di pianificare il viaggio",
        "pt": "Adicione alguns locais antes de planejar a viagem",
        "ru": "Добавьте несколько мест, прежде чем планировать поездку",
        "th": "ยังไม่มีจุดจาริก เพิ่มสักสองสามจุดก่อนวางแผน",
        "vi": "Chưa có địa điểm nào — hãy thêm vài điểm trước khi lập kế hoạch",
        "ms": "Belum ada lokasi ziarah — tambah beberapa sebelum merancang perjalanan",
    },
    "tripPlannerOverview": {
        "zh": "概览", "zh_Hant": "總覽", "en": "Overview", "ja": "概要",
        "ko": "개요", "es": "Resumen", "fr": "Vue d’ensemble",
        "it": "Panoramica", "pt": "Visão geral", "ru": "Обзор",
        "th": "ภาพรวม", "vi": "Tổng quan", "ms": "Gambaran keseluruhan",
    },
    "tripPlannerDaysNeeded": {
        "zh": "建议 {count} 天", "zh_Hant": "建議 {count} 天",
        "en": "{count} days suggested", "ja": "{count} 日間の提案",
        "ko": "{count}일 추천", "es": "{count} días sugeridos",
        "fr": "{count} jours suggérés", "it": "{count} giorni suggeriti",
        "pt": "{count} dias sugeridos", "ru": "Рекомендуется {count} дн.",
        "th": "แนะนำ {count} วัน", "vi": "Gợi ý {count} ngày",
        "ms": "Cadangkan {count} hari",
    },
    "tripPlannerTotalDistance": {
        "zh": "移动距离 {distance}", "zh_Hant": "移動距離 {distance}",
        "en": "Moving distance {distance}", "ja": "移動距離 {distance}",
        "ko": "이동 거리 {distance}", "es": "Distancia a recorrer {distance}",
        "fr": "Distance à parcourir {distance}",
        "it": "Distanza da percorrere {distance}",
        "pt": "Distância a percorrer {distance}", "ru": "Расстояние {distance}",
        "th": "ระยะทาง {distance}", "vi": "Quãng đường {distance}",
        "ms": "Jarak pergerakan {distance}",
    },
    "tripPlannerTotalDuration": {
        "zh": "合计约 {duration}", "zh_Hant": "合計約 {duration}",
        "en": "About {duration} in total", "ja": "合計およそ {duration}",
        "ko": "총 약 {duration}", "es": "Unos {duration} en total",
        "fr": "Environ {duration} au total",
        "it": "Circa {duration} in totale",
        "pt": "Cerca de {duration} no total", "ru": "Всего около {duration}",
        "th": "รวมประมาณ {duration}", "vi": "Tổng khoảng {duration}",
        "ms": "Jumlah kira-kira {duration}",
    },
    "tripPlannerModeLabel": {
        "zh": "出行方式", "zh_Hant": "交通方式", "en": "Travel mode",
        "ja": "移動手段", "ko": "이동 수단", "es": "Modo de viaje",
        "fr": "Mode de déplacement", "it": "Modalità di viaggio",
        "pt": "Modo de viagem", "ru": "Способ передвижения",
        "th": "รูปแบบการเดินทาง", "vi": "Phương thức di chuyển",
        "ms": "Cara pergerakan",
    },
    "tripPlannerModeWalk": {
        "zh": "步行", "zh_Hant": "步行", "en": "On foot", "ja": "徒歩",
        "ko": "도보", "es": "A pie", "fr": "À pied", "it": "A piedi",
        "pt": "A pé", "ru": "Пешком", "th": "เดินเท้า", "vi": "Đi bộ",
        "ms": "Berjalan kaki",
    },
    "tripPlannerModeTransit": {
        "zh": "公共交通", "zh_Hant": "公共交通", "en": "Public transit",
        "ja": "公共交通機関", "ko": "대중교통", "es": "Transporte público",
        "fr": "Transports en commun", "it": "Mezzi pubblici",
        "pt": "Transporte público", "ru": "Общественный транспорт",
        "th": "ขนส่งสาธารณะ", "vi": "Giao thông công cộng",
        "ms": "Pengangkutan awam",
    },
    "tripPlannerModeDrive": {
        "zh": "驾车", "zh_Hant": "駕車", "en": "Driving", "ja": "車",
        "ko": "자가용", "es": "En coche", "fr": "En voiture", "it": "In auto",
        "pt": "De carro", "ru": "На автомобиле", "th": "ขับรถ", "vi": "Lái xe",
        "ms": "Memandu",
    },
    "tripPlannerBudgetLabel": {
        "zh": "每天可用", "zh_Hant": "每天可用", "en": "Daily budget",
        "ja": "1日の目安時間", "ko": "하루 가능 시간", "es": "Tiempo diario",
        "fr": "Temps quotidien", "it": "Tempo giornaliero",
        "pt": "Tempo diário", "ru": "Время в день", "th": "เวลาต่อวัน",
        "vi": "Thời gian mỗi ngày", "ms": "Masa setiap hari",
    },
    "tripPlannerBudgetOption": {
        "zh": "{hours} 小时", "zh_Hant": "{hours} 小時", "en": "{hours} h",
        "ja": "{hours} 時間", "ko": "{hours}시간", "es": "{hours} h",
        "fr": "{hours} h", "it": "{hours} h", "pt": "{hours} h",
        "ru": "{hours} ч", "th": "{hours} ชม.", "vi": "{hours} giờ",
        "ms": "{hours} jam",
    },
    "tripPlannerSpotLabel": {
        "zh": "每点停留", "zh_Hant": "每點停留", "en": "Time per spot",
        "ja": "1箇所あたり", "ko": "지점당 체류", "es": "Tiempo por lugar",
        "fr": "Temps par lieu", "it": "Tempo per luogo",
        "pt": "Tempo por local", "ru": "Время на точку", "th": "เวลาต่อจุด",
        "vi": "Thời gian mỗi điểm", "ms": "Masa setiap lokasi",
    },
    "tripPlannerSpotOption": {
        "zh": "{minutes} 分钟", "zh_Hant": "{minutes} 分鐘",
        "en": "{minutes} min", "ja": "{minutes} 分", "ko": "{minutes}분",
        "es": "{minutes} min", "fr": "{minutes} min", "it": "{minutes} min",
        "pt": "{minutes} min", "ru": "{minutes} мин", "th": "{minutes} นาที",
        "vi": "{minutes} phút", "ms": "{minutes} minit",
    },
    "tripPlannerDayTitle": {
        "zh": "第 {index} 天", "zh_Hant": "第 {index} 天", "en": "Day {index}",
        "ja": "{index} 日目", "ko": "{index}일차", "es": "Día {index}",
        "fr": "Jour {index}", "it": "Giorno {index}", "pt": "Dia {index}",
        "ru": "День {index}", "th": "วันที่ {index}", "vi": "Ngày {index}",
        "ms": "Hari {index}",
    },
    "tripPlannerDayMeta": {
        "zh": "{count} 个点 · {distance} · {duration}",
        "zh_Hant": "{count} 個點 · {distance} · {duration}",
        "en": "{count} spots · {distance} · {duration}",
        "ja": "{count} 箇所 · {distance} · {duration}",
        "ko": "{count}곳 · {distance} · {duration}",
        "es": "{count} lugares · {distance} · {duration}",
        "fr": "{count} lieux · {distance} · {duration}",
        "it": "{count} luoghi · {distance} · {duration}",
        "pt": "{count} locais · {distance} · {duration}",
        "ru": "{count} мест · {distance} · {duration}",
        "th": "{count} จุด · {distance} · {duration}",
        "vi": "{count} điểm · {distance} · {duration}",
        "ms": "{count} lokasi · {distance} · {duration}",
    },
    "tripPlannerDeparture": {
        "zh": "出发 {time}", "zh_Hant": "出發 {time}", "en": "Depart {time}",
        "ja": "出発 {time}", "ko": "출발 {time}", "es": "Salida {time}",
        "fr": "Départ {time}", "it": "Partenza {time}", "pt": "Partida {time}",
        "ru": "Выезд {time}", "th": "ออกเดินทาง {time}",
        "vi": "Khởi hành {time}", "ms": "Berlepas {time}",
    },
    "tripPlannerNote": {
        "zh": "按直线距离 × 绕行系数 ÷ 平均速度估算，未含爬升、路况与营业时间，请自行留余量。",
        "zh_Hant": "依直線距離 × 繞行係數 ÷ 平均速度估算，未含爬升、路況與營業時間，請自行保留彈性。",
        "en": "Estimated from straight-line distance × detour factor ÷ average speed. Elevation, road conditions and opening hours are not included — keep some slack.",
        "ja": "直線距離 × 迂回係数 ÷ 平均速度で算出した目安です。勾配や道路状況、営業時間は含まれません。余裕を持って計画してください。",
        "ko": "직선거리 × 우회 계수 ÷ 평균 속도로 추정합니다. 고도, 도로 상황, 영업시간은 반영되지 않으니 여유를 두세요.",
        "es": "Estimado a partir de la distancia en línea recta × factor de desvío ÷ velocidad media. No incluye desnivel, estado de las carreteras ni horarios: deja margen.",
        "fr": "Estimé à partir de la distance à vol d’oiseau × facteur de détour ÷ vitesse moyenne. Dénivelé, état des routes et horaires non inclus : prévoyez de la marge.",
        "it": "Stimato da distanza in linea d’aria × fattore di deviazione ÷ velocità media. Non include dislivello, condizioni stradali e orari: tenete un margine.",
        "pt": "Estimado a partir da distância em linha reta × fator de desvio ÷ velocidade média. Não inclui desnível, condições das estradas nem horários: deixe margem.",
        "ru": "Оценка по прямой дистанции × коэффициент объезда ÷ средняя скорость. Перепад высот, состояние дорог и часы работы не учитываются — закладывайте запас.",
        "th": "ประเมินจากระยะทางเส้นตรง × ค่าอ้อม ÷ ความเร็วเฉลี่ย ไม่รวมความชัน สภาพถนน และเวลาเปิดทำการ ควรเผื่อเวลาไว้",
        "vi": "Ước tính từ khoảng cách đường thẳng × hệ số vòng ÷ tốc độ trung bình. Không bao gồm độ cao, tình trạng đường và giờ mở cửa — hãy chừa thời gian dự phòng.",
        "ms": "Anggaran daripada jarak garis lurus × faktor lencongan ÷ kelajuan purata. Tidak termasuk ketinggian, keadaan jalan dan waktu operasi — sediakan masa tambahan.",
    },
}

PLACEHOLDERS = {
    "tripPlannerDaysNeeded": {"count": "int"},
    "tripPlannerTotalDistance": {"distance": "String"},
    "tripPlannerTotalDuration": {"duration": "String"},
    "tripPlannerBudgetOption": {"hours": "int"},
    "tripPlannerSpotOption": {"minutes": "int"},
    "tripPlannerDayTitle": {"index": "int"},
    "tripPlannerDayMeta": {
        "count": "int",
        "distance": "String",
        "duration": "String",
    },
    "tripPlannerDeparture": {"time": "String"},
}


def main() -> None:
    for path in sorted(L10N.glob("app_*.arb")):
        lang = path.stem[len("app_"):]
        data = json.loads(path.read_text(encoding="utf-8"))
        for key, texts in T.items():
            data[key] = texts.get(lang) or texts["zh"]
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
