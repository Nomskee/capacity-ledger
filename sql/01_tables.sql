USE CapacityPlanning;
GO

-- RAW TABLES: exact copies of the CSV files. Nothing is changed on the way in.

DROP TABLE IF EXISTS raw.requests;
CREATE TABLE raw.requests (
    week_start   DATE,
    request_type VARCHAR(20),
    channel      VARCHAR(10),
    volume       INT
);

DROP TABLE IF EXISTS raw.handle_time;
CREATE TABLE raw.handle_time (
    request_type VARCHAR(20),
    channel      VARCHAR(10),
    team         VARCHAR(50),
    minutes      DECIMAL(6,2)
);

DROP TABLE IF EXISTS raw.roster;
CREATE TABLE raw.roster (
    agent_id   VARCHAR(10),
    team       VARCHAR(50),
    start_date DATE,
    end_date   DATE NULL,      -- empty = still employed
    fte        DECIMAL(3,2)
);

DROP TABLE IF EXISTS raw.events;
CREATE TABLE raw.events (
    event_date DATE,
    agent_id   VARCHAR(10) NULL,
    team       VARCHAR(50),
    event      VARCHAR(30)
);

DROP TABLE IF EXISTS raw.assumptions;
CREATE TABLE raw.assumptions (
    name        VARCHAR(50),
    value       DECIMAL(10,4),
    low         DECIMAL(10,4),
    high        DECIMAL(10,4),
    owner       VARCHAR(50),
    source      VARCHAR(100),
    review_date DATE
);

-- LOG TABLE: one row every time the pipeline runs (used later by the automation)
DROP TABLE IF EXISTS cap.pipeline_runs;
CREATE TABLE cap.pipeline_runs (
    run_id        INT IDENTITY(1,1) PRIMARY KEY,
    run_time      DATETIME2,
    week_loaded   DATE,
    rows_loaded   INT,
    checks_passed INT,
    checks_total  INT,
    mape          DECIMAL(5,2),
    status        VARCHAR(20)
);
GO