"""
Spot configurations, constants, and defaults for Windsurf Gliding Analytics.
"""

COMPASS_POINTS = ("N", "NE", "E", "SE", "S", "SW", "W", "NW")

# Each spot has coordinates, timezone, and default "working" wind directions.
# Directions that blow offshore or cross-shore (rideable) are pre-selected;
# onshore directions are excluded by default.
LOCATIONS = {
    "Стамбул (Мимарсинан)": {
        "lat": 41.0025,
        "lon": 28.5305,
        "tz": "Europe/Istanbul",
        "default_dirs": ["N", "NE", "E"],  # Пойраз (N/NE) — основной, E — кросс
        "description": "Мраморное море. Северный ветер «Пойраз».",
    },
    "Чешме (Алачати)": {
        "lat": 38.3243,
        "lon": 26.3031,
        "tz": "Europe/Istanbul",
        "default_dirs": ["N", "NW", "W"],  # Мельтеми — N/NW, термический
        "description": "Культовый спот. Сильный термический ветер.",
    },
    "Дахаб": {
        "lat": 28.5010,
        "lon": 34.5126,
        "tz": "Africa/Cairo",
        "default_dirs": ["N", "NW", "NE"],  # Ветер вдоль гор с севера
        "description": "Красное море. Стабильный ровный ветер вдоль гор.",
    },
    "Санкт-Петербург": {
        "lat": 59.9386,
        "lon": 30.3141,
        "tz": "Europe/Moscow",
        "default_dirs": ["W", "SW", "S"],  # Финский залив — западные ветра
        "description": "Финский залив, Сестрорецк / Дюны.",
    },
    "Тбилиси": {
        "lat": 41.6941,
        "lon": 44.8337,
        "tz": "Asia/Tbilisi",
        "default_dirs": list(COMPASS_POINTS),  # Водохранилище — подходит всё
        "description": "Тбилисское водохранилище, порывистый локальный ветер.",
    },
}

MONTH_NAMES_RU = {
    1: "Янв", 2: "Фев", 3: "Мар", 4: "Апр", 5: "Май", 6: "Июн",
    7: "Июл", 8: "Авг", 9: "Сен", 10: "Окт", 11: "Ноя", 12: "Дек",
}

MONTH_NAMES_FULL_RU = {
    1: "Январь", 2: "Февраль", 3: "Март", 4: "Апрель",
    5: "Май", 6: "Июнь", 7: "Июль", 8: "Август",
    9: "Сентябрь", 10: "Октябрь", 11: "Ноябрь", 12: "Декабрь",
}

# Sail size recommendations by average wind speed range (knots).
# Approximate, for a 75-80 kg rider on a freeride board.
SAIL_RECOMMENDATIONS = [
    (14, 18, "7.0 – 7.8 м²", "Лёгкий глиссинг"),
    (18, 22, "5.5 – 6.5 м²", "Комфортный ветер"),
    (22, 28, "4.5 – 5.3 м²", "Сильный ветер"),
    (28, 50, "3.7 – 4.5 м²", "Шторм / экстрим"),
]


def degrees_to_compass(deg: float) -> str:
    """Convert wind direction in degrees (0-360) to 8-point compass label."""
    idx = int((deg + 22.5) / 45) % 8
    return COMPASS_POINTS[idx]


def recommend_sail(avg_wind_knots: float) -> str:
    """Return sail size recommendation string for a given average wind speed."""
    for low, high, sail, label in SAIL_RECOMMENDATIONS:
        if low <= avg_wind_knots < high:
            return f"{sail} ({label})"
    if avg_wind_knots < 14:
        return "Нет глиссирования (< 14 узлов)"
    return "3.7 м² или меньше (экстрим)"
