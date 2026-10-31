USE CapacityPlanning;
GO

-- 1) Every week that has request data
CREATE OR ALTER VIEW cap.weeks AS
SELECT DISTINCT week_start
FROM clean.requests;
GO

-- 2) DEMAND: workload hours per team per week
CREATE OR ALTER VIEW cap.team_workload AS
SELECT
    r.week_start,
    h.team,
    SUM(r.volume)                    AS requests,
    SUM(r.volume * h.minutes) / 60.0 AS workload_hours
FROM clean.requests r
JOIN clean.handle_time h
  ON h.request_type = r.request_type
 AND h.channel      = r.channel
GROUP BY r.week_start, h.team;
GO

-- 3) SUPPLY: who was working each week, and how productive they were
CREATE OR ALTER VIEW cap.team_supply AS
WITH active AS (
    SELECT
        w.week_start,
        r.team,
        r.fte,
        DATEDIFF(day, r.start_date, w.week_start) / 7 AS tenure_weeks
    FROM cap.weeks w
    JOIN clean.roster r
      ON r.start_date <= w.week_start
     AND (r.end_date IS NULL OR r.end_date > w.week_start)
)
SELECT
    a.week_start,
    a.team,
    COUNT(*)   AS headcount,
    SUM(a.fte) AS paid_fte,
    SUM(a.fte * CASE
            WHEN a.tenure_weeks < 4  THEN s.ramp_1_4
            WHEN a.tenure_weeks < 8  THEN s.ramp_5_8
            WHEN a.tenure_weeks < 12 THEN s.ramp_9_12
            ELSE 1.0
        END)   AS effective_fte
FROM active a
CROSS JOIN cap.settings s
GROUP BY a.week_start, a.team;
GO

-- 4) THE LEDGER: demand vs supply, side by side
CREATE OR ALTER VIEW cap.ledger_weekly AS
SELECT
    w.week_start,
    w.team,
    w.requests,
    CAST(w.workload_hours AS DECIMAL(10,1)) AS workload_hours,
    s.headcount,
    CAST(s.paid_fte      AS DECIMAL(10,2)) AS paid_fte,
    CAST(s.effective_fte AS DECIMAL(10,2)) AS effective_fte,
    CAST(s.effective_fte * st.paid_hours * (1 - st.shrinkage) AS DECIMAL(10,1)) AS supply_hours,
    CAST(s.effective_fte * st.paid_hours * (1 - st.shrinkage) - w.workload_hours AS DECIMAL(10,1)) AS gap_hours,
    CAST((s.effective_fte * st.paid_hours * (1 - st.shrinkage) - w.workload_hours)
         / (st.paid_hours * (1 - st.shrinkage)) AS DECIMAL(10,2)) AS fte_gap
FROM cap.team_workload w
JOIN cap.team_supply s
  ON s.week_start = w.week_start
 AND s.team       = w.team
CROSS JOIN cap.settings st;
GO