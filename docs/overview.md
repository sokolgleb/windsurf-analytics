# Windsurf Gliding Analytics

## Что это?

Веб-приложение для виндсерферов, которое анализирует исторические данные о ветре и помогает ответить на вопросы:

- **Когда ехать?** — в каком месяце/неделе больше всего ветреных дней
- **Куда ехать?** — сравнение спотов между собой
- **Какой парус брать?** — рекомендации по размеру в зависимости от средней скорости
- **В какое время выходить на воду?** — пиковые часы ветра по месяцам

Приложение работает полностью в браузере, без установки. Данные доступны без логина.

---

## Как это работает

### Источник данных

[Open-Meteo Archive API](https://open-meteo.com/) — бесплатный API с историческими почасовыми данными о ветре с 2010 года по вчера. Для каждого часа доступны:
- скорость ветра (10 м) в узлах
- скорость порывов в узлах
- направление ветра в градусах (0–360)

### Архитектура

```
Open-Meteo Archive API
        |
        | HTTPS (Supabase Edge Function)
        v
PostgreSQL (weather_hours)        <-- кэш, ~131K строк на спот за 15 лет
        |
        | SELECT (Supabase REST API)
        v
Flutter Web (браузер)
        |
        | analysis_engine.dart (client-side)
        v
Графики + KPI + рекомендации
```

**Почему анализ на клиенте?** Каждое движение слайдера (мин. ветер, направление, часы) должно мгновенно пересчитать результат. При серверном подходе — round-trip на каждый клик. Данные за 2 года — ~17K строк (~700 КБ) — загружаются один раз и кэшируются в Riverpod provider.

### Стек технологий

| Компонент | Технология | Зачем |
|-----------|-----------|-------|
| Frontend | Flutter Web (CanvasKit) | Кроссплатформенный UI, CustomPainter для графиков |
| Backend/DB | Supabase (PostgreSQL + Auth) | Бесплатный tier, RLS, Edge Functions |
| Хостинг | Cloudflare Pages | Бесплатный, глобальный CDN |
| State management | Riverpod | Реактивные провайдеры, автопересчёт |
| Роутинг | GoRouter | Декларативная навигация |
| Графики | fl_chart + CustomPainter | Bar charts, роза ветров |
| i18n | Flutter intl (ARB) | EN + RU |
| CI/CD | GitHub Actions | Авто-деплой на Cloudflare Pages |
| Данные о ветре | Open-Meteo Archive API | Бесплатно, без API-ключа |

---

## Структура проекта

```
windsurf-analytics/
├── .github/workflows/
│   └── flutter-web.yml          # CI/CD: test → build → deploy
├── supabase/
│   ├── migrations/
│   │   └── 00001_initial_schema.sql   # Таблицы + RLS
│   ├── functions/
│   │   └── fetch-weather/
│   │       └── index.ts         # Edge Function: Open-Meteo → PostgreSQL
│   └── seed.sql                 # 5 пресетных спотов
├── app/                         # Flutter Web приложение
│   ├── lib/
│   │   ├── core/                # constants, theme, l10n helpers
│   │   ├── l10n/                # app_en.arb, app_ru.arb + generated
│   │   ├── models/              # Spot, WeatherHour, GlidingDay, AnalysisParams
│   │   ├── repositories/       # Supabase queries
│   │   ├── providers/           # Riverpod state management
│   │   ├── services/
│   │   │   └── analysis_engine.dart   # Ядро: порт analysis.py
│   │   ├── routing/router.dart
│   │   ├── screens/             # Dashboard, Auth, My Spots, Raw Data
│   │   └── widgets/charts/      # 6 виджетов графиков
│   └── test/
│       └── services/
│           └── analysis_engine_test.dart  # 45 тестов
└── legacy/                      # Оригинальный MVP на Python (для справки)
```

---

## База данных

### Таблица `spots` — споты

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | uuid PK | |
| `user_id` | uuid FK → auth.users | NULL для пресетных |
| `name` | text | Название спота |
| `latitude`, `longitude` | real | Координаты |
| `timezone` | text | IANA timezone (например `Europe/Istanbul`) |
| `description` | text | Описание спота |
| `default_directions` | text[] | Рабочие направления ветра (например `{N,NE,E}`) |
| `is_preset` | boolean | true = встроенный, false = пользовательский |

### Таблица `weather_hours` — кэш почасовых данных

| Поле | Тип | Описание |
|------|-----|----------|
| `spot_id` | uuid | FK → spots |
| `time` | timestamptz | Час наблюдения (в timezone спота) |
| `wind_speed_kn` | real | Средняя скорость, узлы |
| `wind_gust_kn` | real? | Порывы, узлы |
| `wind_direction` | smallint | Направление, градусы 0–360 |

**Primary key**: `(spot_id, time)` — композитный, оптимизирует range-запросы по дате.

### Таблица `weather_sync_status` — состояние синхронизации

Отслеживает для каждого спота: какой диапазон дат загружен, когда последний раз синхронизировали, статус (`pending`, `syncing`, `done`, `error`).

### RLS-политики

- **spots**: все читают пресетные; авторизованные пользователи CRUD своих
- **weather_hours**: SELECT для всех; INSERT/UPDATE — только service_role (Edge Function)
- **weather_sync_status**: SELECT для всех; запись — только service_role

### Пресетные споты (5 шт.)

| Спот | Координаты | Timezone | Направления | Характер ветра |
|------|-----------|----------|-------------|----------------|
| Istanbul (Mimarsinan) | 41.00, 28.53 | Europe/Istanbul | N, NE, E | Пойраз (северный) |
| Cesme (Alacati) | 38.32, 26.30 | Europe/Istanbul | N, NW, W | Мельтеми (термический) |
| Dahab | 28.50, 34.51 | Africa/Cairo | N, NW, NE | Стабильный вдоль гор |
| St. Petersburg | 59.94, 30.31 | Europe/Moscow | W, SW, S | Финский залив, западные |
| Tbilisi | 41.69, 44.83 | Asia/Tbilisi | Все 8 | Порывистый локальный |

### Объём данных

~8 760 строк на спот в год (24 часа x 365 дней). За 15 лет — ~131K строк (~10 МБ) на спот. 5 пресетных = ~50 МБ. Укладывается в free tier Supabase (500 МБ).

---

## Data Pipeline (Edge Function)

Supabase Edge Function `fetch-weather` — единственный writer в `weather_hours`. TypeScript, работает на Deno.

### Два режима

**1. Backfill (по запросу)** — при создании спота или запросе нового диапазона лет:
```
POST /fetch-weather
{ "spot_id": "...", "start_date": "2020-01-01", "end_date": "2024-12-31" }
```
Лимит: 5 лет за запрос. `end_date` автоматически ограничивается вчерашним днём.

**2. Daily sync (cron)** — ежедневно в 03:00 UTC для всех спотов:
```
POST /fetch-weather
{ "mode": "daily" }
```
Обновляет последние 5 дней (покрывает возможные пробелы).

### Алгоритм

1. Запрос к Open-Meteo: координаты + timezone + диапазон дат → почасовые `wind_speed_10m`, `wind_gusts_10m`, `wind_direction_10m` (в узлах)
2. Фильтрация: пропуск строк с NULL в скорости или направлении
3. UPSERT в `weather_hours` батчами по 5000 строк (конфликт по `(spot_id, time)` → обновление)
4. Обновление `weather_sync_status` с датами и статусом

---

## Алгоритм анализа

Файл: `app/lib/services/analysis_engine.dart` — порт Python `analysis.py` на Dart.

### Входные параметры (настраиваются пользователем)

| Параметр | По умолчанию | Описание |
|----------|-------------|----------|
| Диапазон лет | 2 последних года | За какой период анализировать |
| Время на воде | 10:00–19:00 | Окно наблюдения (локальное время) |
| Метрика ветра | Средний | Средний ветер или порывы |
| Мин. скорость | 14 узлов | Порог глиссирования |
| Мин. непрерывность | 2 часа | Минимум часов подряд выше порога |
| Мин. плотность | 70% | Доля ветреных часов в окне |
| Направления | Зависит от спота | Какие направления ветра допустимы |

### Конвейер обработки

#### 1. Filter & Tag → `filterAndTag()`

Из сырых почасовых данных получает дневные записи с тегами:

```
Для каждого часа:
  1. Фильтр по времени: startHour ≤ hour ≤ endHour
  2. Конвертация градусов → румб (8 направлений)
  3. Выбор метрики: порывы (если включены и есть данные) или средний ветер
  4. Если направление в списке допустимых → validSpeed = скорость
     Если нет → validSpeed = 0
  5. isWindy = (validSpeed ≥ minWind)
```

**Конвертация градусов в румбы** (`degreesToCompass`):
```
idx = floor((degrees + 22.5) / 45) % 8
→ compassPoints[idx]
```
Каждый сектор — 45 градусов. N = 337.5°–22.5°, NE = 22.5°–67.5° и т.д.

#### 2. Evaluate Days → `evaluateDays()`

Для каждого календарного дня определяет, является ли он глиссирующим:

```
Для каждого дня:
  1. maxChain = самая длинная непрерывная серия isWindy=true
  2. nWindy = количество ветреных часов
  3. density = (nWindy / min(actualHours, windowHours)) * 100%
  4. isGliding = (maxChain ≥ minDuration) AND (density ≥ minPct)
  5. avgWind = среднее validSpeed только по ветреным часам
```

**Пример**: окно 10:00–19:00 (10 часов). День с 7 часами ветра ≥14 узлов, из них 3 подряд максимум. При minDuration=2, minPct=70: density=70%, maxChain=3≥2 → глиссирующий день.

#### 3. Monthly Average → `computeMonthlyAvg()`

Среднее количество глиссирующих дней по месяцам за все годы:

```
Группировка (месяц, год) → подсчёт дней → среднее по годам
```

#### 4. Weekly Heatmap → `computeWeeklyHeatmap()`

Матрица год × неделя (1–52), значения = количество глиссирующих дней. ISO-неделя 53 сливается с 52, чтобы не было разреженных столбцов.

#### 5. Hourly Heatmap → `computeHourlyHeatmap()`

Матрица месяц × час, значения = средняя скорость ветра (только по допустимым направлениям). Помогает найти пиковые часы — например, термический ветер в Алачати усиливается к 14:00–17:00.

#### 6. Wind Rose → `computeWindRose()`

Распределение направления и силы ветра. 8 направлений × 6 бинов скорости:
`0–10, 10–14, 14–18, 18–22, 22–28, 28+` узлов.

### Производительность

| Операция | Сложность |
|----------|-----------|
| filterAndTag | O(n) |
| evaluateDays | O(n) |
| monthlyAvg | O(d), d = дней |
| weeklyHeatmap | O(d) |
| hourlyHeatmap | O(n) |
| windRose | O(n) |

Типичные 3 года — ~26K записей. Полный конвейер < 200 мс.

---

## Интерфейс

### Экраны

| Экран | Путь | Описание |
|-------|------|----------|
| Dashboard | `/` | Основной: выбор спота, параметры, KPI, 5 табов с графиками |
| Auth | `/auth` | Google/GitHub OAuth (для кастомных спотов) |
| My Spots | `/my-spots` | CRUD пользовательских спотов |
| Raw Data | `/raw-data` | Таблица глиссирующих дней + CSV экспорт |

### Dashboard — основной экран

**Desktop (>1024px)**: sidebar слева (320px) с контролами + основной контент справа с TabBar.

**Mobile**: hamburger-меню (Drawer) с контролами + контент с табами.

#### Контролы (sidebar)

1. Выбор спота (dropdown, локализованные имена)
2. Диапазон лет (RangeSlider, 2010–текущий год)
3. Время на воде (RangeSlider, 0:00–23:00)
4. Метрика ветра (SegmentedButton: средний / порывы)
5. Мин. скорость (Slider, 10–35 узлов)
6. Мин. непрерывность (Slider, 1–6 часов)
7. Мин. плотность (Slider, 10–100%)
8. Направления ветра (8 FilterChip: N, NE, E, SE, S, SW, W, NW)
9. Язык (EN / RU)
10. Auth секция (войти / мои споты / выйти)

#### KPI-карточки (4 шт.)

| Метрика | Что показывает |
|---------|---------------|
| Всего глиссирующих дней | Сумма за выбранный период |
| Дней / год (ср.) | Среднее в год |
| Лучший месяц | Месяц + год с максимумом дней |
| Ср. ветер (глисс.) | Средний ветер на глиссирующих днях |

#### Табы с графиками (5 шт.)

| Таб | Виджет | Реализация |
|-----|--------|-----------|
| По месяцам | Bar chart (12 столбцов) | fl_chart `BarChart` |
| Тепловая карта | Год × неделя (цвет = кол-во дней) | Custom widget (Table + Container) |
| Роза ветров | Полярная диаграмма (8 лепестков × 6 бинов) | `CustomPainter` (Canvas.drawArc) |
| Ветер по часам | Месяц × час (цвет = ср. скорость) | Custom widget (Table + Container) |
| Рекомендации | Таблица: месяц → ср. ветер → размер паруса | `DataTable` |

### Рекомендации по парусу

Для райдера 75–80 кг на фрирайд-доске:

| Ветер (узлы) | Парус | Категория |
|-------------|-------|-----------|
| < 14 | — | Нет глиссирования |
| 14–18 | 7.0–7.8 м² | Лёгкий глиссинг |
| 18–22 | 5.5–6.5 м² | Комфортный ветер |
| 22–28 | 4.5–5.3 м² | Сильный ветер |
| 28+ | 3.7–4.5 м² | Шторм / экстрим |

---

## State Management (Riverpod)

Все состояние — в Riverpod-провайдерах. Изменение любого параметра автоматически запускает пересчёт результатов.

```
supabaseProvider (SupabaseClient)
  ├─ spotsRepositoryProvider
  │   └─ spotsProvider ─────────────── List<Spot>
  ├─ weatherRepositoryProvider
  │   └─ weatherDataProvider ───────── List<WeatherHour>  (зависит от спота + годов)
  └─ currentUserProvider ──────────── User?

selectedSpotProvider ──────────────── Spot?
analysisParamsProvider ────────────── AnalysisParams  (StateNotifier, copyWith)

analysisResultProvider ────────────── AnalysisResult
  └─ зависит от weatherDataProvider + analysisParamsProvider
     → вызывает analyze() при любом изменении

localeProvider ────────────────────── Locale (SharedPreferences)
```

**Ключевой момент**: `analysisResultProvider` — синхронный Provider (не FutureProvider). Вычисление происходит мгновенно при получении данных. Async только на уровне загрузки weather data из Supabase.

---

## Авторизация

- **Без логина**: полный доступ ко всем пресетным спотам и данным (read-only через anon key)
- **Google / GitHub OAuth** (Supabase Auth): только для создания/управления кастомными спотами
- Лимит: максимум 5 пользовательских спотов (ограничение на free tier Supabase — ~50 МБ на пресеты + кастомные)

---

## Мультиязычность (i18n)

- Два языка: English (шаблон) и Русский
- ~90 ключей локализации в ARB-файлах
- Генерация кода через `flutter gen-l10n`
- Имена пресетных спотов: в БД — английские, в UI — маппинг по ID на i18n-ключ
- Выбор языка сохраняется в SharedPreferences

---

## CI/CD

**GitHub Actions** (`.github/workflows/flutter-web.yml`):

```
Push в main (изменения в app/) → flutter pub get → flutter test → flutter build web → deploy на Cloudflare Pages
```

Supabase URL и anon key передаются через `--dart-define` из GitHub Secrets.

### Необходимые секреты

| Секрет | Описание |
|--------|----------|
| `SUPABASE_URL` | URL Supabase-проекта |
| `SUPABASE_ANON_KEY` | Публичный ключ Supabase |
| `CLOUDFLARE_API_TOKEN` | API-токен Cloudflare |
| `CLOUDFLARE_ACCOUNT_ID` | ID аккаунта Cloudflare |

---

## Тесты

45 unit-тестов покрывают ядро анализа (`analysis_engine.dart`):

| Группа | Тестов | Что проверяют |
|--------|--------|--------------|
| degreesToCompass | 27 | Все 8 направлений + граничные значения (22.4° vs 22.5°) |
| maxConsecutiveTrue | 7 | Пустой массив, все false/true, один элемент, несколько серий |
| filterAndTag | 3 | Фильтрация по часам, зануление при неправильном направлении, иммутабельность |
| evaluateDays | 6 | Идеальный день, недостаточная длительность/плотность, граничная скорость, расчёт avg |
| weeklyHeatmap | 1 | Слияние недели 53 в 52 |
| windRose | 1 | Все 8 направлений присутствуют |

Тесты портированы из Python (`legacy/tests/test_analysis.py`) и дают идентичные результаты.

---

## Ключевые решения

1. **Анализ на клиенте** — мгновенный отклик на каждое изменение параметра, без round-trip
2. **Композитный PK `(spot_id, time)`** — кластерный индекс для быстрых range-запросов по дате
3. **Edge Function как единственный writer** — вся логика записи в одном месте, RLS блокирует запись с клиента
4. **Неделя 53 → 52** — избегает разреженных столбцов в тепловой карте
5. **ISO 8601 недели** — консистентность с международным стандартом
6. **Иммутабельные модели + copyWith** — предсказуемые обновления состояния
7. **Timezone из спота** — API возвращает данные в локальном времени, фильтры по часам корректны

---

## Legacy (Python MVP)

Оригинальный прототип на Streamlit (`legacy/`) — для справки. Тот же алгоритм анализа, но с Pandas/NumPy вместо чистого Dart. Plotly-графики вместо fl_chart/CustomPainter. Данные загружались напрямую из Open-Meteo без кэширования в БД.
