# Capacity Ledger – Workforce Capacity Planning Prototype

A working capacity planning suite for a simulated medical-records (release of information) operation with three teams, built on synthetic data.

## What it does
- **Capacity Ledger:** for every team and week, hours of work vs productive hours (after shrinkage and new-hire ramp), the gap in FTE, and backlog.
- **Capacity Plan:** a 26-week forward view with attrition, backfill hiring and ramp.
- **Scenarios:** base plan, 30% automation, new client (+15% volume), attrition spike, hiring freeze, with backlog and cost for each.
- **Automation realization:** checks how much promised automation savings become real capacity (64% in this run).
- **Weekly automation:** a scheduled job loads each new week, reruns everything and logs the run.

## Headline result
Absorbing a new client with 30% automation plus 8 targeted hires costs about $195K over 26 weeks, vs $487K for hiring 20 people (placeholder $30/hour rate).

## How it's built
Jupyter notebooks (data, forecast, plan) → SQL Server (raw, clean, ledger views, 6 data checks) → Power BI (5-page dashboard) → Windows Task Scheduler (weekly refresh).

## Key assumptions (all synthetic, all adjustable)
37.5 paid hours/week · 22% shrinkage · ramp 25/50/75/100% over 12 weeks · 2% monthly attrition · 4-week hiring lag.

## How to run
1. Run `sql/01_tables.sql` in SSMS.
2. Copy `db_example.py` to `db.py` and set your server name.
3. Run the notebooks in order: 01, 02, 03, 04.
4. Open `powerbi/CapacityLedger.pbix` and click Refresh.
5. Optional: schedule `run_pipeline.bat` with Windows Task Scheduler.

## Limitations
Overtime, transfers, skills-based routing and intraday scheduling are not modelled. Labor rate is a placeholder.

![Overview](screenshots/overview.png)