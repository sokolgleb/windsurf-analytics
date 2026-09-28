"""
Unit tests for the gliding day analysis engine.
"""

import datetime

import numpy as np
import pandas as pd
import pytest

from analysis import (
    _max_consecutive_true,
    evaluate_days,
    filter_and_tag,
    compute_weekly_heatmap,
    compute_wind_rose,
)
from config import degrees_to_compass


# ---------------------------------------------------------------------------
# degrees_to_compass
# ---------------------------------------------------------------------------

class TestDegreesToCompass:
    @pytest.mark.parametrize("deg, expected", [
        (0, "N"), (10, "N"), (22.4, "N"), (337.6, "N"), (360, "N"),
        (22.5, "NE"), (45, "NE"), (67.4, "NE"),
        (67.5, "E"), (90, "E"), (112.4, "E"),
        (112.5, "SE"), (135, "SE"), (157.4, "SE"),
        (157.5, "S"), (180, "S"), (202.4, "S"),
        (202.5, "SW"), (225, "SW"), (247.4, "SW"),
        (247.5, "W"), (270, "W"), (292.4, "W"),
        (292.5, "NW"), (315, "NW"), (337.4, "NW"),
    ])
    def test_standard_directions(self, deg, expected):
        assert degrees_to_compass(deg) == expected

    def test_exact_360(self):
        assert degrees_to_compass(360) == "N"


# ---------------------------------------------------------------------------
# _max_consecutive_true
# ---------------------------------------------------------------------------

class TestMaxConsecutiveTrue:
    def test_empty(self):
        assert _max_consecutive_true(np.array([], dtype=bool)) == 0

    def test_all_false(self):
        assert _max_consecutive_true(np.array([False, False, False])) == 0

    def test_all_true(self):
        assert _max_consecutive_true(np.array([True, True, True])) == 3

    def test_single_true(self):
        assert _max_consecutive_true(np.array([False, True, False])) == 1

    def test_multiple_runs(self):
        arr = np.array([True, True, False, True, True, True, False, True])
        assert _max_consecutive_true(arr) == 3

    def test_leading_run(self):
        arr = np.array([True, True, True, False, True])
        assert _max_consecutive_true(arr) == 3

    def test_trailing_run(self):
        arr = np.array([True, False, True, True, True])
        assert _max_consecutive_true(arr) == 3


# ---------------------------------------------------------------------------
# filter_and_tag
# ---------------------------------------------------------------------------

def _make_hourly_df(hours, speeds, directions_deg):
    """Helper: build a minimal DataFrame similar to what data.py returns."""
    base_date = datetime.date(2024, 7, 15)
    times = [
        datetime.datetime.combine(base_date, datetime.time(h, 0))
        for h in hours
    ]
    df = pd.DataFrame({
        "time": pd.to_datetime(times),
        "wind_speed": speeds,
        "wind_dir_deg": directions_deg,
    })
    df["date"] = df["time"].dt.date
    df["hour"] = df["time"].dt.hour
    df["month"] = df["time"].dt.month
    df["year"] = df["time"].dt.year
    df["iso_week"] = df["time"].dt.isocalendar().week.astype(int)
    df["direction"] = df["wind_dir_deg"].apply(degrees_to_compass)
    return df


class TestFilterAndTag:
    def test_hour_window_filters(self):
        df = _make_hourly_df(
            hours=list(range(0, 24)),
            speeds=[15] * 24,
            directions_deg=[0] * 24,  # N
        )
        result = filter_and_tag(df, 10, 18, {"N"}, 14)
        assert len(result) == 9  # hours 10..18 inclusive

    def test_direction_filter_zeroes_speed(self):
        df = _make_hourly_df(
            hours=[10, 11, 12],
            speeds=[20, 20, 20],
            directions_deg=[0, 180, 0],  # N, S, N
        )
        result = filter_and_tag(df, 10, 12, {"N"}, 14)
        # Hour 11 is S -> zeroed out
        assert result.iloc[1]["valid_speed"] == 0.0
        assert result.iloc[0]["valid_speed"] == 20.0

    def test_does_not_mutate_input(self):
        df = _make_hourly_df([10, 11], [20, 20], [0, 0])
        original_cols = set(df.columns)
        filter_and_tag(df, 10, 11, {"N"}, 14)
        assert "valid_speed" not in df.columns
        assert set(df.columns) == original_cols


# ---------------------------------------------------------------------------
# evaluate_days
# ---------------------------------------------------------------------------

class TestEvaluateDays:
    def test_perfect_gliding_day(self):
        """All hours windy, strong, correct direction -> gliding."""
        df = _make_hourly_df(
            hours=list(range(10, 20)),
            speeds=[18] * 10,
            directions_deg=[0] * 10,  # N
        )
        tagged = filter_and_tag(df, 10, 19, {"N"}, 14)
        daily = evaluate_days(tagged, 14, 2, 70, 10)
        assert len(daily) == 1
        assert daily.iloc[0]["is_gliding"] == True

    def test_insufficient_duration(self):
        """Only 1 windy hour, but min_duration=2 -> not gliding."""
        df = _make_hourly_df(
            hours=list(range(10, 20)),
            speeds=[18] + [5] * 9,
            directions_deg=[0] * 10,
        )
        tagged = filter_and_tag(df, 10, 19, {"N"}, 14)
        daily = evaluate_days(tagged, 14, 2, 10, 10)
        assert daily.iloc[0]["is_gliding"] == False

    def test_insufficient_density(self):
        """3 consecutive windy hours out of 10 -> 30% < 70% -> not gliding."""
        speeds = [18, 18, 18] + [5] * 7
        df = _make_hourly_df(
            hours=list(range(10, 20)),
            speeds=speeds,
            directions_deg=[0] * 10,
        )
        tagged = filter_and_tag(df, 10, 19, {"N"}, 14)
        daily = evaluate_days(tagged, 14, 2, 70, 10)
        assert daily.iloc[0]["is_gliding"] == False

    def test_boundary_wind_speed(self):
        """Wind exactly at threshold should count."""
        df = _make_hourly_df(
            hours=list(range(10, 20)),
            speeds=[14.0] * 10,
            directions_deg=[0] * 10,
        )
        tagged = filter_and_tag(df, 10, 19, {"N"}, 14)
        daily = evaluate_days(tagged, 14, 2, 70, 10)
        assert daily.iloc[0]["is_gliding"] == True

    def test_just_below_threshold(self):
        """Wind 13.9 — just below 14 threshold."""
        df = _make_hourly_df(
            hours=list(range(10, 20)),
            speeds=[13.9] * 10,
            directions_deg=[0] * 10,
        )
        tagged = filter_and_tag(df, 10, 19, {"N"}, 14)
        daily = evaluate_days(tagged, 14, 2, 70, 10)
        assert daily.iloc[0]["is_gliding"] == False

    def test_avg_wind_calculated_correctly(self):
        """Average wind should only consider windy hours."""
        speeds = [20, 22, 5, 5, 5, 24, 20, 18, 5, 5]
        df = _make_hourly_df(
            hours=list(range(10, 20)),
            speeds=speeds,
            directions_deg=[0] * 10,
        )
        tagged = filter_and_tag(df, 10, 19, {"N"}, 14)
        daily = evaluate_days(tagged, 14, 1, 10, 10)
        # Windy hours: 20, 22, 24, 20, 18 -> avg = 20.8
        assert daily.iloc[0]["avg_wind"] == 20.8


# ---------------------------------------------------------------------------
# compute_weekly_heatmap
# ---------------------------------------------------------------------------

class TestWeeklyHeatmap:
    def test_week_53_merged(self):
        """Week 53 should be merged into week 52."""
        data = pd.DataFrame({
            "date": [datetime.date(2024, 12, 30), datetime.date(2024, 7, 1)],
            "year": [2024, 2024],
            "month": [12, 7],
            "iso_week": [1, 27],  # Dec 30 2024 is ISO week 1 of 2025
            "is_gliding": [True, True],
        })
        # Simulate the week 53 scenario
        data_w53 = pd.DataFrame({
            "date": [datetime.date(2023, 1, 1)],
            "year": [2023],
            "month": [1],
            "iso_week": [53],  # edge case
            "is_gliding": [True],
        })
        combined = pd.concat([data, data_w53], ignore_index=True)
        heatmap = compute_weekly_heatmap(combined)
        assert 53 not in heatmap.columns
        assert set(range(1, 53)).issubset(set(heatmap.columns))


# ---------------------------------------------------------------------------
# compute_wind_rose
# ---------------------------------------------------------------------------

class TestWindRose:
    def test_returns_all_directions(self):
        df = _make_hourly_df(
            hours=list(range(10, 18)),
            speeds=[15, 20, 10, 25, 8, 18, 30, 12],
            directions_deg=[0, 45, 90, 135, 180, 225, 270, 315],
        )
        tagged = filter_and_tag(df, 10, 17, set(degrees_to_compass(d) for d in range(0, 360, 45)), 0)
        rose = compute_wind_rose(tagged)
        assert set(rose["direction"].unique()) == {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
