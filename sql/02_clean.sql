-- CLEAN LAYER: views that tidy the raw tables. Raw data is never changed.

CREATE OR ALTER VIEW clean.requests AS
SELECT DISTINCT
    week_start,
    LOWER(LTRIM(RTRIM(request_type))) AS request_type,
    LOWER(LTRIM(RTRIM(channel)))      AS channel,
    volume
FROM raw.requests
WHERE volume >= 0;
GO

CREATE OR ALTER VIEW clean.handle_time AS
SELECT DISTINCT
    LOWER(LTRIM(RTRIM(request_type))) AS request_type,
    LOWER(LTRIM(RTRIM(channel)))      AS channel,
    team,
    minutes
FROM raw.handle_time
WHERE minutes > 0;
GO

CREATE OR ALTER VIEW clean.roster AS
SELECT DISTINCT
    agent_id,
    team,
    start_date,
    end_date,
    fte
FROM raw.roster
WHERE fte > 0;
GO

-- One row holding the assumptions as named columns, so other queries can use them
CREATE OR ALTER VIEW cap.settings AS
SELECT
    MAX(CASE WHEN name = 'paid_hours_per_week' THEN value END) AS paid_hours,
    MAX(CASE WHEN name = 'shrinkage'           THEN value END) AS shrinkage,
    MAX(CASE WHEN name = 'ramp_weeks_1_4'      THEN value END) AS ramp_1_4,
    MAX(CASE WHEN name = 'ramp_weeks_5_8'      THEN value END) AS ramp_5_8,
    MAX(CASE WHEN name = 'ramp_weeks_9_12'     THEN value END) AS ramp_9_12,
    MAX(CASE WHEN name = 'hourly_cost'         THEN value END) AS hourly_cost
FROM raw.assumptions;
GO