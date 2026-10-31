-- REPORTING VIEWS for Power BI

-- History and plan in one place, so one chart can run from actuals straight into each scenario
CREATE OR ALTER VIEW cap.timeline AS
SELECT week_start, team, 'Actual' AS series,
       workload_hours, supply_hours, fte_gap, backlog_hours
FROM cap.ledger
UNION ALL
SELECT week_start, team, scenario AS series,
       workload_hours, supply_hours, fte_gap, backlog_hours
FROM cap.plan_weekly;
GO

-- Performance to plan: each actual week compared with the most recent forecast made BEFORE it arrived
CREATE OR ALTER VIEW cap.performance_to_plan AS
WITH actual AS (
    SELECT week_start, request_type, SUM(volume) AS actual_volume
    FROM clean.requests
    GROUP BY week_start, request_type
),
latest_forecast AS (
    SELECT fh.week_start, fh.request_type, fh.volume, fh.forecast_made_on,
           ROW_NUMBER() OVER (PARTITION BY fh.week_start, fh.request_type
                              ORDER BY fh.forecast_made_on DESC) AS rn
    FROM cap.forecast_history fh
)
SELECT a.week_start, a.request_type, a.actual_volume,
       f.volume AS forecast_volume, f.forecast_made_on,
       a.actual_volume - f.volume AS variance,
       CAST((a.actual_volume - f.volume) * 100.0 / NULLIF(f.volume, 0) AS DECIMAL(6,1)) AS variance_pct
FROM actual a
JOIN latest_forecast f
  ON f.week_start = a.week_start
 AND f.request_type = a.request_type
 AND f.rn = 1;
GO