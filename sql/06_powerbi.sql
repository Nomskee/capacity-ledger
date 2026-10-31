USE CapacityPlanning;
GO

-- One row per team: lets a single slicer filter every table that has a team column
CREATE OR ALTER VIEW cap.dim_team AS
SELECT DISTINCT team
FROM clean.handle_time;
GO