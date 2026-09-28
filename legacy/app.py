"""
Windsurf Gliding Analytics Dashboard — main Streamlit application.
"""

import streamlit as st
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd

from config import (
    COMPASS_POINTS,
    LOCATIONS,
    MONTH_NAMES_RU,
    MONTH_NAMES_FULL_RU,
    recommend_sail,
)
from data import load_meteo
from analysis import (
    filter_and_tag,
    evaluate_days,
    compute_monthly_avg,
    compute_weekly_heatmap,
    compute_hourly_heatmap,
    compute_wind_rose,
)

# ---------------------------------------------------------------------------
# Page config
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="Windsurf Gliding Analytics",
    page_icon="🏄",
    layout="wide",
)

# ---------------------------------------------------------------------------
# Sidebar
# ---------------------------------------------------------------------------
st.sidebar.header("Параметры анализа")

city = st.sidebar.selectbox("Виндсерф-спот", list(LOCATIONS.keys()))
spot = LOCATIONS[city]
st.sidebar.caption(spot["description"])

years = st.sidebar.slider("Диапазон лет", 2010, 2026, (2024, 2026))

st.sidebar.subheader("Условия глиссирования")
start_hour, end_hour = st.sidebar.slider(
    "Время на воде (локальное)", 0, 23, (10, 19),
)
wind_metric = st.sidebar.radio(
    "Метрика ветра",
    ["Средний ветер", "Порывы (gusts)"],
    index=0,
    help="Порывы ближе к реальным ощущениям на воде, особенно для порывистых спотов (Тбилиси).",
)
use_gusts = wind_metric == "Порывы (gusts)"
min_wind = st.sidebar.slider("Мин. скорость ветра (узлы)", 10, 35, 14)
min_duration = st.sidebar.slider("Мин. непрерывность (часов подряд)", 1, 6, 2)
min_pct = st.sidebar.slider("Мин. плотность ветра за день (%)", 10, 100, 70)

selected_dirs = st.sidebar.multiselect(
    "Допустимые направления ветра",
    options=list(COMPASS_POINTS),
    default=spot["default_dirs"],
)

st.sidebar.divider()

# Comparison mode
compare_mode = st.sidebar.checkbox("Сравнение спотов")
compare_spots = []
if compare_mode:
    other_spots = [s for s in LOCATIONS if s != city]
    compare_spots = st.sidebar.multiselect(
        "Сравнить с", other_spots, max_selections=3,
    )

# ---------------------------------------------------------------------------
# Load & process data
# ---------------------------------------------------------------------------
if not selected_dirs:
    st.warning("Выберите хотя бы одно направление ветра.")
    st.stop()

window_hours = (end_hour - start_hour) + 1
allowed = set(selected_dirs)


def process_spot(spot_name: str) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Load data and compute daily stats for a spot."""
    s = LOCATIONS[spot_name]
    raw = load_meteo(s["lat"], s["lon"], years[0], years[1], s["tz"])
    if raw.empty:
        return pd.DataFrame(), pd.DataFrame()
    daytime = filter_and_tag(raw, start_hour, end_hour, allowed, min_wind, use_gusts)
    daily = evaluate_days(daytime, min_wind, min_duration, min_pct, window_hours)
    return daytime, daily


df_daytime, daily_stats = process_spot(city)

if daily_stats.empty:
    st.error(
        "Не удалось загрузить данные. Проверьте подключение к интернету "
        "или измените диапазон лет."
    )
    st.stop()

# ---------------------------------------------------------------------------
# KPI cards
# ---------------------------------------------------------------------------
st.title(f"Windsurf Gliding Analytics: {city}")

total_days = int(daily_stats["is_gliding"].sum())
num_years = (years[1] - years[0]) + 1
avg_per_year = round(total_days / num_years, 1)

# Best month
best_month_df = (
    daily_stats
    .groupby(["year", "month"])["is_gliding"]
    .sum()
    .reset_index(name="cnt")
)
if not best_month_df.empty and best_month_df["cnt"].max() > 0:
    best_row = best_month_df.loc[best_month_df["cnt"].idxmax()]
    best_str = (
        f"{MONTH_NAMES_RU[best_row['month']]} {int(best_row['year'])} г. "
        f"({int(best_row['cnt'])} дн.)"
    )
else:
    best_str = "Нет данных"

# Average wind on gliding days
gliding_days_data = daily_stats[daily_stats["is_gliding"]]
avg_gliding_wind = (
    round(gliding_days_data["avg_wind"].mean(), 1)
    if not gliding_days_data.empty else 0
)

c1, c2, c3, c4 = st.columns(4)
c1.metric("Всего глиссирующих дней", total_days)
c2.metric("В среднем дней / год", avg_per_year)
c3.metric("Лучший месяц", best_str)
c4.metric("Ср. ветер (глисс.)", f"{avg_gliding_wind} уз.")

# ---------------------------------------------------------------------------
# Tabs
# ---------------------------------------------------------------------------
tab_labels = [
    "По месяцам",
    "Тепловая карта (недели)",
    "Роза ветров",
    "Ветер по часам",
    "Рекомендации",
]
if compare_mode and compare_spots:
    tab_labels.append("Сравнение спотов")

tabs = st.tabs(tab_labels)

# --- Tab 1: Monthly bar chart ---
with tabs[0]:
    monthly_avg = compute_monthly_avg(daily_stats)
    monthly_avg["month_name"] = monthly_avg["month"].map(MONTH_NAMES_RU)

    fig_bar = px.bar(
        monthly_avg,
        x="month_name",
        y="avg_days",
        labels={"month_name": "Месяц", "avg_days": "Глиссирующих дней (ср.)"},
        text_auto=".1f",
        title=f"Среднее количество глиссирующих дней по месяцам ({years[0]}–{years[1]})",
    )
    fig_bar.update_traces(marker_color="#008080", textposition="outside")
    fig_bar.update_layout(
        xaxis={
            "categoryorder": "array",
            "categoryarray": list(MONTH_NAMES_RU.values()),
        },
        yaxis_title="Дней",
    )
    st.plotly_chart(fig_bar, use_container_width=True)

    # Per-year breakdown under the average chart
    with st.expander("Детализация по годам"):
        by_my = (
            daily_stats
            .groupby(["year", "month"])["is_gliding"]
            .sum()
            .reset_index(name="days")
        )
        by_my["month_name"] = by_my["month"].map(MONTH_NAMES_RU)
        fig_detail = px.bar(
            by_my,
            x="month_name",
            y="days",
            color="year",
            barmode="group",
            labels={"month_name": "Месяц", "days": "Дней", "year": "Год"},
            title="Глиссирующие дни: помесячно по годам",
        )
        fig_detail.update_layout(
            xaxis={
                "categoryorder": "array",
                "categoryarray": list(MONTH_NAMES_RU.values()),
            }
        )
        st.plotly_chart(fig_detail, use_container_width=True)

# --- Tab 2: Weekly heatmap ---
with tabs[1]:
    heatmap = compute_weekly_heatmap(daily_stats)

    fig_heat = go.Figure(data=go.Heatmap(
        z=heatmap.values,
        x=heatmap.columns.tolist(),
        y=[str(y) for y in heatmap.index.tolist()],
        colorscale="YlGnBu",
        hoverongaps=False,
        hovertemplate=(
            "Год: %{y}<br>"
            "Неделя: %{x}<br>"
            "Глиссирующих дней: %{z}"
            "<extra></extra>"
        ),
    ))
    fig_heat.update_layout(
        title="Распределение глиссирующих дней по неделям года",
        xaxis_title="Неделя года",
        yaxis_title="Год",
        yaxis=dict(type="category"),
        height=300 + 50 * len(heatmap),
    )
    st.plotly_chart(fig_heat, use_container_width=True)
    st.caption(
        "Тёмные области — недели с максимальной плотностью ветра. "
        "Используйте для планирования поездки."
    )

# --- Tab 3: Wind rose ---
with tabs[2]:
    rose_df = compute_wind_rose(df_daytime)

    fig_rose = px.bar_polar(
        rose_df,
        r="count",
        theta="direction",
        color="speed_bin",
        color_discrete_sequence=px.colors.sequential.Tealgrn,
        title=f"Роза ветров: {city} ({start_hour}:00–{end_hour}:00)",
        labels={"count": "Часов", "speed_bin": "Узлы", "direction": "Направление"},
    )
    fig_rose.update_layout(
        polar=dict(
            angularaxis=dict(
                categoryorder="array",
                categoryarray=["N", "NE", "E", "SE", "S", "SW", "W", "NW"],
            ),
        ),
        height=550,
    )
    st.plotly_chart(fig_rose, use_container_width=True)
    st.caption(
        "Показывает распределение направления и силы ветра "
        "в выбранном временном окне за все годы."
    )

# --- Tab 4: Hourly wind heatmap ---
with tabs[3]:
    hourly_hm = compute_hourly_heatmap(df_daytime, allowed)

    if not hourly_hm.empty:
        fig_hourly = go.Figure(data=go.Heatmap(
            z=hourly_hm.values,
            x=[f"{h}:00" for h in hourly_hm.columns.tolist()],
            y=[MONTH_NAMES_RU.get(m, str(m)) for m in hourly_hm.index.tolist()],
            colorscale="YlOrRd",
            hovertemplate=(
                "%{y}, %{x}<br>"
                "Ср. ветер: %{z:.1f} уз."
                "<extra></extra>"
            ),
        ))
        fig_hourly.update_layout(
            title="Средняя скорость ветра: месяц × час дня",
            xaxis_title="Час",
            yaxis_title="Месяц",
            yaxis=dict(type="category"),
            height=450,
        )
        st.plotly_chart(fig_hourly, use_container_width=True)
        st.caption(
            "Помогает определить пиковые часы ветра в каждом месяце. "
            "Термический ветер (Алачати) обычно усиливается к 14:00–17:00."
        )
    else:
        st.info("Нет данных по выбранным направлениям.")

# --- Tab 5: Sail recommendations ---
with tabs[4]:
    st.subheader("Рекомендации по размеру паруса")
    st.caption("Ориентировочно для райдера 75–80 кг на фрирайд-доске.")

    monthly_wind = (
        gliding_days_data
        .groupby("month")["avg_wind"]
        .mean()
        .reset_index()
    )

    if not monthly_wind.empty:
        recs = []
        for _, row in monthly_wind.iterrows():
            m = int(row["month"])
            wind = round(row["avg_wind"], 1)
            recs.append({
                "Месяц": MONTH_NAMES_FULL_RU.get(m, str(m)),
                "Ср. ветер (уз.)": wind,
                "Рекомендация": recommend_sail(wind),
            })
        st.table(pd.DataFrame(recs))
    else:
        st.info("Нет глиссирующих дней для анализа.")

# --- Tab 6: Spot comparison ---
if compare_mode and compare_spots and len(tabs) > 5:
    with tabs[5]:
        st.subheader("Сравнение спотов по месяцам")

        all_monthly = []
        for spot_name in [city] + compare_spots:
            _, d_stats = process_spot(spot_name)
            if d_stats.empty:
                continue
            mavg = compute_monthly_avg(d_stats)
            mavg["spot"] = spot_name
            all_monthly.append(mavg)

        if all_monthly:
            combined = pd.concat(all_monthly, ignore_index=True)
            combined["month_name"] = combined["month"].map(MONTH_NAMES_RU)

            fig_cmp = px.bar(
                combined,
                x="month_name",
                y="avg_days",
                color="spot",
                barmode="group",
                labels={
                    "month_name": "Месяц",
                    "avg_days": "Ср. глиссирующих дней",
                    "spot": "Спот",
                },
                title="Сравнение: среднее количество глиссирующих дней",
            )
            fig_cmp.update_layout(
                xaxis={
                    "categoryorder": "array",
                    "categoryarray": list(MONTH_NAMES_RU.values()),
                }
            )
            st.plotly_chart(fig_cmp, use_container_width=True)
        else:
            st.warning("Не удалось загрузить данные для сравнения.")

# ---------------------------------------------------------------------------
# Data export
# ---------------------------------------------------------------------------
st.divider()

with st.expander("Экспорт данных"):
    export_df = daily_stats[daily_stats["is_gliding"]].copy()
    export_df["date"] = pd.to_datetime(export_df["date"])
    export_df = export_df.sort_values("date")
    export_df["month_name"] = export_df["month"].map(MONTH_NAMES_FULL_RU)

    display_cols = ["date", "month_name", "avg_wind", "max_chain", "density_pct"]
    rename = {
        "date": "Дата",
        "month_name": "Месяц",
        "avg_wind": "Ср. ветер (уз.)",
        "max_chain": "Макс. цепочка (ч)",
        "density_pct": "Плотность (%)",
    }
    export_display = export_df[display_cols].rename(columns=rename)

    st.dataframe(export_display, use_container_width=True, hide_index=True)

    csv = export_display.to_csv(index=False).encode("utf-8")
    st.download_button(
        "Скачать CSV",
        data=csv,
        file_name=f"gliding_days_{city}_{years[0]}-{years[1]}.csv",
        mime="text/csv",
    )
