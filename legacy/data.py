"""
Data loading from Open-Meteo Historical Weather API.
"""

import datetime
import logging

import pandas as pd
import requests
import streamlit as st

from config import degrees_to_compass

logger = logging.getLogger(__name__)

OPEN_METEO_ARCHIVE_URL = "https://archive-api.open-meteo.com/v1/archive"

# Open-Meteo allows ~10 000 days per request (~27 years), so a single call is fine
# for the 2010-2025 range. For wider ranges, chunking would be needed.
MAX_YEARS_PER_REQUEST = 27


@st.cache_data(show_spinner="Загрузка данных с Open-Meteo...", ttl=3600)
def load_meteo(
    lat: float,
    lon: float,
    start_year: int,
    end_year: int,
    timezone: str,
) -> pd.DataFrame:
    """
    Fetch hourly wind data from Open-Meteo archive:
    wind_speed_10m, wind_gusts_10m, wind_direction_10m.

    Returns a DataFrame with columns:
        time, wind_speed, wind_gust, wind_dir_deg, direction,
        date, hour, month, year, iso_week
    or an empty DataFrame on failure.
    """
    params = {
        "latitude": lat,
        "longitude": lon,
        "start_date": f"{start_year}-01-01",
        "end_date": min(
            datetime.date(end_year, 12, 31),
            datetime.date.today() - datetime.timedelta(days=1),
        ).isoformat(),
        "hourly": "wind_speed_10m,wind_gusts_10m,wind_direction_10m",
        "wind_speed_unit": "kn",
        "timezone": timezone,
    }

    try:
        resp = requests.get(OPEN_METEO_ARCHIVE_URL, params=params, timeout=30)
        resp.raise_for_status()
        data = resp.json()
    except requests.RequestException as exc:
        logger.error("Open-Meteo API request failed: %s", exc)
        return pd.DataFrame()
    except ValueError as exc:
        logger.error("Failed to parse Open-Meteo response as JSON: %s", exc)
        return pd.DataFrame()

    hourly = data.get("hourly")
    if not hourly or "time" not in hourly:
        logger.error("Unexpected API response structure: %s", list(data.keys()))
        return pd.DataFrame()

    time_series = pd.to_datetime(hourly["time"])
    wind_speed = pd.array(hourly["wind_speed_10m"], dtype="Float64")
    wind_gust = pd.array(hourly.get("wind_gusts_10m", [None] * len(time_series)), dtype="Float64")
    wind_dir = pd.array(hourly["wind_direction_10m"], dtype="Float64")

    df = pd.DataFrame({
        "time": time_series,
        "wind_speed": wind_speed,
        "wind_gust": wind_gust,
        "wind_dir_deg": wind_dir,
    })

    # Drop rows where the API returned null (data gaps)
    df = df.dropna(subset=["wind_speed", "wind_dir_deg"])

    # Derived columns
    df["direction"] = df["wind_dir_deg"].apply(degrees_to_compass)
    df["date"] = df["time"].dt.date
    df["hour"] = df["time"].dt.hour
    df["month"] = df["time"].dt.month
    df["year"] = df["time"].dt.year
    # ISO week: 1-53, consistent across years
    df["iso_week"] = df["time"].dt.isocalendar().week.astype(int)

    return df
