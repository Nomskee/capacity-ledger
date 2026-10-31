USE CapacityPlanning;
GO

-- Results table (created once, kept forever as a history of every check run)
IF OBJECT_ID('cap.data_checks', 'U') IS NULL
    CREATE TABLE cap.data_checks (
        run_time   DATETIME2,
        check_name VARCHAR(100),
        bad_rows   INT
    );
GO

-- The checks. Each one counts BAD rows: 0 = PASS.
CREATE OR ALTER PROCEDURE cap.run_data_checks AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @now   DATETIME2 = SYSDATETIME();
    DECLARE @teams INT = (SELECT COUNT(DISTINCT team) FROM clean.handle_time);

    -- 1. Every request type/channel has a handle time (otherwise its work would be missed)
    INSERT INTO cap.data_checks
    SELECT @now, 'Every request type/channel has a handle time', COUNT(*)
    FROM clean.requests r
    LEFT JOIN clean.handle_time h
      ON h.request_type = r.request_type AND h.channel = r.channel
    WHERE h.minutes IS NULL;

    -- 2. No negative volumes arrived from the source
    INSERT INTO cap.data_checks
    SELECT @now, 'No negative request volumes', COUNT(*)
    FROM raw.requests
    WHERE volume < 0;

    -- 3. Nobody leaves before they start
    INSERT INTO cap.data_checks
    SELECT @now, 'No agent leaves before they start', COUNT(*)
    FROM raw.roster
    WHERE end_date IS NOT NULL AND end_date < start_date;

    -- 4. No agent appears twice
    INSERT INTO cap.data_checks
    SELECT @now, 'No duplicate agent IDs', COUNT(*) - COUNT(DISTINCT agent_id)
    FROM raw.roster;

    -- 5. Every week in the ledger has every team
    INSERT INTO cap.data_checks
    SELECT @now, 'Every week has every team in the ledger', COUNT(*)
    FROM (
        SELECT week_start
        FROM cap.ledger_weekly
        GROUP BY week_start
        HAVING COUNT(DISTINCT team) <> @teams
    ) x;

    -- 6. Ledger headcount matches a direct count from the raw roster
    INSERT INTO cap.data_checks
    SELECT @now, 'Ledger headcount reconciles to the roster', COUNT(*)
    FROM cap.ledger_weekly l
    JOIN (
        SELECT w.week_start, r.team, COUNT(*) AS n
        FROM cap.weeks w
        JOIN raw.roster r
          ON r.start_date <= w.week_start
         AND (r.end_date IS NULL OR r.end_date > w.week_start)
        GROUP BY w.week_start, r.team
    ) x
      ON x.week_start = l.week_start AND x.team = l.team
    WHERE l.headcount <> x.n;
END;
GO

-- Shows only the most recent run, as PASS / FAIL
CREATE OR ALTER VIEW cap.latest_checks AS
SELECT
    check_name,
    bad_rows,
    CASE WHEN bad_rows = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
    run_time
FROM cap.data_checks
WHERE run_time = (SELECT MAX(run_time) FROM cap.data_checks);
GO