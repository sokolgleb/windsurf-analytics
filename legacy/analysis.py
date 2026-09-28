"""
Gliding day analysis engine.

Vectorized where possible; falls back to per-day groupby only for the
continuous-chain detection (inherently sequential per day).
"""

from typing import Set

import numpy as np
import pandas as pd


def filter_and_tag(
    df: pd.DataFrame,
    start_hour: int,
    end_hour: int,
    allowed_dirs: Set[str],
    min_wind: float,
    use_gusts: bool = False,
) -> pd.DataFrame:
    """
    From raw hourly data, produce a daytime-only DataFrame with:
      - valid_speed: wind metric (avg or gust) if direction is allowed, else 0
      - is_windy: valid_speed >= min_wind

    Returns a copy; does not mutate the input.
    """
    mask_hour = (df["hour"] >= start_hour) & (df["hour"] <= end_hour)
    result = df.loc[mask_hour].copy()

    # Choose which wind metric to evaluate against threshold
    if use_gusts and "wind_gust" in result.columns:
        speed_col = result["wind_gust"].fillna(result["wind_speed"])
    else:
        speed_col = result["wind_speed"]

    # Vectorized direction filter (no row-level apply)
    dir_ok = result["direction"].isin(allowed_dirs)
    result["valid_speed"] = np.where(dir_ok, speed_col, 0.0)
    result["is_windy"] = result["valid_speed"] >= min_wind

    return result


def _max_consecutive_true(arr: np.ndarray) -> int:
    """
    Return the length of the longest run of True values in a boolean array.
    Pure numpy, no Python-level loop over elements.
    """
    if len(arr) == 0:
        return 0
    if not arr.any():
        return 0

    # Pad with False at both ends to detect edges
    padded = np.concatenate(([False], arr, [False]))
    diffs = np.diff(padded.astype(int))
    starts = np.where(diffs == 1)[0]
    ends = np.where(diffs == -1)[0]
    if len(starts) == 0:
        return 0
    return int((ends - starts).max())


def evaluate_days(
    df_daytime: pd.DataFrame,
    min_wind: float,
    min_duration: int,
    min_pct: float,
    window_hours: int,
) -> pd.DataFrame:
    """
    For each calendar day, determine if it qualifies as a gliding day.

    Parameters
    ----------
    df_daytime : DataFrame with columns [date, year, month, iso_week,
                 wind_speed, valid_speed, is_windy]
    min_wind : minimum wind speed in knots
    min_duration : minimum consecutive hours of wind >= min_wind
    min_pct : minimum percentage of window hours with wind >= min_wind
    window_hours : total hours in the daily observation window

    Returns
    -------
    DataFrame with columns [date, year, month, iso_week, is_gliding,
                            max_chain, density_pct, avg_wind]
    """
    records = []

    for date_val, group in df_daytime.groupby("date", sort=True):
        windy_arr = group["is_windy"].values
        max_chain = _max_consecutive_true(windy_arr)

        n_windy = int(windy_arr.sum())
        actual_hours = len(group)
        # Use actual hours present in data (handles gaps),
        # but cap at window_hours so density can't exceed 100%.
        denom = min(actual_hours, window_hours) if actual_hours > 0 else window_hours
        density = (n_windy / denom) * 100

        is_gliding = (max_chain >= min_duration) and (density >= min_pct)

        # Average wind speed on windy hours (for sail recommendations)
        windy_speeds = group.loc[group["is_windy"], "valid_speed"]
        avg_wind = float(windy_speeds.mean()) if len(windy_speeds) > 0 else 0.0

        row = group.iloc[0]
        records.append({
            "date": date_val,
            "year": int(row["year"]),
            "month": int(row["month"]),
            "iso_week": int(row["iso_week"]),
            "is_gliding": is_gliding,
            "max_chain": max_chain,
            "density_pct": round(density, 1),
            "avg_wind": round(avg_wind, 1),
        })

    return pd.DataFrame(records)


def compute_monthly_avg(daily: pd.DataFrame) -> pd.DataFrame:
    """Average gliding days per month across all years."""
    by_month_year = (
        daily
        .groupby(["month", "year"])["is_gliding"]
        .sum()
        .reset_index(name="gliding_days")
    )
    return (
        by_month_year
        .groupby("month")["gliding_days"]
        .mean()
        .reset_index(name="avg_days")
    )


def compute_weekly_heatmap(daily: pd.DataFrame) -> pd.DataFrame:
    """
    Pivot table: rows=year, columns=iso_week (1-52), values=gliding days count.
    Week 53 is merged into week 52 to avoid sparse columns.
    """
    df = daily.copy()
    df.loc[df["iso_week"] == 53, "iso_week"] = 52

    pivot = (
        df
        .groupby(["year", "iso_week"])["is_gliding"]
        .sum()
        .unstack(fill_value=0)
    )

    # Ensure all weeks 1-52 are present
    for w in range(1, 53):
        if w not in pivot.columns:
            pivot[w] = 0
    pivot = pivot[sorted(pivot.columns)]

    return pivot


def compute_hourly_heatmap(
    df_daytime: pd.DataFrame,
    allowed_dirs: Set[str],
) -> pd.DataFrame:
    """
    Pivot table: rows=month, columns=hour, values=avg wind speed (only
    from allowed directions).
    """
    df = df_daytime[df_daytime["direction"].isin(allowed_dirs)].copy()
    pivot = (
        df
        .groupby(["month", "hour"])["wind_speed"]
        .mean()
        .unstack(fill_value=0)
        .round(1)
    )
    return pivot


def compute_wind_rose(df_daytime: pd.DataFrame) -> pd.DataFrame:
    """
    Return a DataFrame for a wind rose: direction, speed_bin, count.
    Speed bins: 0-10, 10-14, 14-18, 18-22, 22-28, 28+ knots.
    """
    bins = [0, 10, 14, 18, 22, 28, 100]
    labels = ["0-10", "10-14", "14-18", "18-22", "22-28", "28+"]

    df = df_daytime.copy()
    df["speed_bin"] = pd.cut(df["wind_speed"], bins=bins, labels=labels, right=False)

    rose = (
        df
        .groupby(["direction", "speed_bin"], observed=False)
        .size()
        .reset_index(name="count")
    )

    # Enforce compass order
    dir_order = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    rose["direction"] = pd.Categorical(rose["direction"], categories=dir_order, ordered=True)
    rose = rose.sort_values(["direction", "speed_bin"])

    return rose
