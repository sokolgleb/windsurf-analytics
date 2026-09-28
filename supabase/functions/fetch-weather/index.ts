// Supabase Edge Function: fetch-weather
// Fetches hourly wind data from Open-Meteo Archive API and upserts into weather_hours.
//
// Invoke modes:
//   POST /fetch-weather { spot_id, start_date, end_date }  — backfill specific range
//   POST /fetch-weather { mode: "daily" }                  — daily sync for all spots (pg_cron)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPEN_METEO_URL = "https://archive-api.open-meteo.com/v1/archive";
const MS_TO_KN = 1.94384; // m/s to knots (Open-Meteo returns m/s by default, but we request kn)

interface SpotRow {
  id: string;
  latitude: number;
  longitude: number;
  timezone: string;
}

interface FetchRequest {
  spot_id?: string;
  start_date?: string; // YYYY-MM-DD
  end_date?: string;   // YYYY-MM-DD
  mode?: "daily";
}

interface OpenMeteoHourly {
  time: string[];
  wind_speed_10m: (number | null)[];
  wind_gusts_10m: (number | null)[];
  wind_direction_10m: (number | null)[];
}

Deno.serve(async (req: Request) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const body: FetchRequest = await req.json();

    if (body.mode === "daily") {
      return await handleDailySync(supabase);
    }

    if (body.spot_id && body.start_date && body.end_date) {
      return await handleBackfill(supabase, body.spot_id, body.start_date, body.end_date);
    }

    return new Response(
      JSON.stringify({ error: "Invalid request. Provide {spot_id, start_date, end_date} or {mode: 'daily'}." }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("fetch-weather error:", err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});

async function handleDailySync(supabase: any): Promise<Response> {
  // Fetch all spots and update yesterday's data
  const { data: spots, error } = await supabase
    .from("spots")
    .select("id, latitude, longitude, timezone");

  if (error) throw new Error(`Failed to fetch spots: ${error.message}`);

  const yesterday = new Date();
  yesterday.setUTCDate(yesterday.getUTCDate() - 1);
  const dateStr = yesterday.toISOString().split("T")[0];

  // Also fetch today (partial) — up to 5 days back to handle gaps
  const fiveDaysAgo = new Date();
  fiveDaysAgo.setUTCDate(fiveDaysAgo.getUTCDate() - 5);
  const startStr = fiveDaysAgo.toISOString().split("T")[0];

  const results: { spot_id: string; rows: number; error?: string }[] = [];

  for (const spot of spots as SpotRow[]) {
    try {
      const rows = await fetchAndUpsert(supabase, spot, startStr, dateStr);
      results.push({ spot_id: spot.id, rows });
    } catch (err) {
      results.push({ spot_id: spot.id, rows: 0, error: String(err) });
    }
  }

  return new Response(
    JSON.stringify({ mode: "daily", results }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
}

async function handleBackfill(
  supabase: any,
  spotId: string,
  startDate: string,
  endDate: string,
): Promise<Response> {
  // Validate date range (max 5 years per request to stay within API limits)
  const start = new Date(startDate);
  const end = new Date(endDate);
  const maxEnd = new Date(start);
  maxEnd.setFullYear(maxEnd.getFullYear() + 5);

  if (end > maxEnd) {
    return new Response(
      JSON.stringify({ error: "Maximum 5 years per backfill request." }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    );
  }

  // Cap end_date to yesterday
  const yesterday = new Date();
  yesterday.setUTCDate(yesterday.getUTCDate() - 1);
  const cappedEnd = end > yesterday ? yesterday.toISOString().split("T")[0] : endDate;

  // Fetch spot details
  const { data: spot, error: spotErr } = await supabase
    .from("spots")
    .select("id, latitude, longitude, timezone")
    .eq("id", spotId)
    .single();

  if (spotErr || !spot) {
    return new Response(
      JSON.stringify({ error: `Spot not found: ${spotId}` }),
      { status: 404, headers: { "Content-Type": "application/json" } },
    );
  }

  // Update sync status to "syncing"
  await supabase
    .from("weather_sync_status")
    .upsert({ spot_id: spotId, sync_status: "syncing" });

  try {
    const rows = await fetchAndUpsert(supabase, spot as SpotRow, startDate, cappedEnd);

    // Update sync status
    await supabase
      .from("weather_sync_status")
      .upsert({
        spot_id: spotId,
        earliest_date: startDate,
        latest_date: cappedEnd,
        last_synced_at: new Date().toISOString(),
        sync_status: "done",
      });

    return new Response(
      JSON.stringify({ spot_id: spotId, rows_upserted: rows }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    await supabase
      .from("weather_sync_status")
      .upsert({ spot_id: spotId, sync_status: "error" });

    throw err;
  }
}

async function fetchAndUpsert(
  supabase: any,
  spot: SpotRow,
  startDate: string,
  endDate: string,
): Promise<number> {
  // Fetch from Open-Meteo
  const params = new URLSearchParams({
    latitude: String(spot.latitude),
    longitude: String(spot.longitude),
    start_date: startDate,
    end_date: endDate,
    hourly: "wind_speed_10m,wind_gusts_10m,wind_direction_10m",
    wind_speed_unit: "kn",
    timezone: spot.timezone,
  });

  const resp = await fetch(`${OPEN_METEO_URL}?${params}`);
  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Open-Meteo API error ${resp.status}: ${text}`);
  }

  const data = await resp.json();
  const hourly: OpenMeteoHourly = data.hourly;

  if (!hourly || !hourly.time) {
    throw new Error("Unexpected API response: missing hourly data");
  }

  // Build rows for upsert
  const rows: {
    spot_id: string;
    time: string;
    wind_speed_kn: number;
    wind_gust_kn: number | null;
    wind_direction: number;
  }[] = [];

  for (let i = 0; i < hourly.time.length; i++) {
    const speed = hourly.wind_speed_10m[i];
    const dir = hourly.wind_direction_10m[i];

    // Skip rows with null essential data
    if (speed === null || dir === null) continue;

    rows.push({
      spot_id: spot.id,
      time: hourly.time[i],
      wind_speed_kn: Math.round(speed * 10) / 10,
      wind_gust_kn: hourly.wind_gusts_10m[i] !== null
        ? Math.round(hourly.wind_gusts_10m[i]! * 10) / 10
        : null,
      wind_direction: Math.round(dir),
    });
  }

  // Upsert in batches of 5000 (Supabase limit)
  const batchSize = 5000;
  let totalUpserted = 0;

  for (let offset = 0; offset < rows.length; offset += batchSize) {
    const batch = rows.slice(offset, offset + batchSize);
    const { error } = await supabase
      .from("weather_hours")
      .upsert(batch, { onConflict: "spot_id,time" });

    if (error) {
      throw new Error(`Upsert failed at offset ${offset}: ${error.message}`);
    }
    totalUpserted += batch.length;
  }

  console.log(`Upserted ${totalUpserted} rows for spot ${spot.id} (${startDate} to ${endDate})`);
  return totalUpserted;
}
