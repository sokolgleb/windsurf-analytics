const compassPoints = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

const presetSpotIds = {
  'istanbul': '00000000-0000-4000-a000-000000000001',
  'cesme': '00000000-0000-4000-a000-000000000002',
  'dahab': '00000000-0000-4000-a000-000000000003',
  'stPetersburg': '00000000-0000-4000-a000-000000000004',
  'tbilisi': '00000000-0000-4000-a000-000000000005',
};

/// Sail size recommendations by average wind speed range (knots).
/// (low, high, sailSize, labelKey)
const sailRecommendations = [
  (14.0, 18.0, '7.0 – 7.8 m²', 'sailLight'),
  (18.0, 22.0, '5.5 – 6.5 m²', 'sailComfort'),
  (22.0, 28.0, '4.5 – 5.3 m²', 'sailStrong'),
  (28.0, 50.0, '3.7 – 4.5 m²', 'sailStorm'),
];

/// Wind rose speed bins.
const windSpeedBins = [0.0, 10.0, 14.0, 18.0, 22.0, 28.0, 100.0];
const windSpeedBinLabels = ['0-10', '10-14', '14-18', '18-22', '22-28', '28+'];

const maxCustomSpots = 5;
const maxBackfillYears = 5;
