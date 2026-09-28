-- Seed: 5 preset windsurf spots

insert into spots (id, name, latitude, longitude, timezone, description, default_directions, is_preset)
values
  (
    '00000000-0000-4000-a000-000000000001',
    'Istanbul (Mimarsinan)',
    41.0025, 28.5305,
    'Europe/Istanbul',
    'Sea of Marmara. Northern wind "Poyraz".',
    '{N,NE,E}',
    true
  ),
  (
    '00000000-0000-4000-a000-000000000002',
    'Cesme (Alacati)',
    38.3243, 26.3031,
    'Europe/Istanbul',
    'Iconic spot. Strong thermal wind "Meltemi".',
    '{N,NW,W}',
    true
  ),
  (
    '00000000-0000-4000-a000-000000000003',
    'Dahab',
    28.5010, 34.5126,
    'Africa/Cairo',
    'Red Sea. Stable steady wind along the mountains.',
    '{N,NW,NE}',
    true
  ),
  (
    '00000000-0000-4000-a000-000000000004',
    'St. Petersburg',
    59.9386, 30.3141,
    'Europe/Moscow',
    'Gulf of Finland, Sestroretsk / Dyuny.',
    '{W,SW,S}',
    true
  ),
  (
    '00000000-0000-4000-a000-000000000005',
    'Tbilisi',
    41.6941, 44.8337,
    'Asia/Tbilisi',
    'Tbilisi reservoir. Gusty local wind.',
    '{N,NE,E,SE,S,SW,W,NW}',
    true
  );

-- Initialize sync status for preset spots
insert into weather_sync_status (spot_id, sync_status)
select id, 'pending' from spots where is_preset = true;
