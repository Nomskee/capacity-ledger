@echo off
REM ============================================================
REM Capacity Ledger weekly pipeline
REM 1) load next week  2) backlog + forecast  3) plan, scenarios, checks, run log
REM ============================================================

cd /d C:\Projects\capacity-ledger-bi
if not exist logs mkdir logs
call .venv\Scripts\activate.bat

echo ============================================== >> logs\pipeline.log
echo Run started %date% %time% >> logs\pipeline.log

echo Step 1 of 3: load the next week of data >> logs\pipeline.log
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.kernel_name=python3 --ExecutePreprocessor.timeout=600 notebooks\02_load.ipynb >> logs\pipeline.log 2>&1
if errorlevel 1 goto failed

echo Step 2 of 3: backlog, forecast and backtest >> logs\pipeline.log
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.kernel_name=python3 --ExecutePreprocessor.timeout=600 notebooks\03_forecast.ipynb >> logs\pipeline.log 2>&1
if errorlevel 1 goto failed

echo Step 3 of 3: plan, scenarios, checks and run log >> logs\pipeline.log
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.kernel_name=python3 --ExecutePreprocessor.timeout=600 notebooks\04_plan_scenarios.ipynb >> logs\pipeline.log 2>&1
if errorlevel 1 goto failed

echo Run finished OK %date% %time% >> logs\pipeline.log
exit /b 0

:failed
echo RUN FAILED at %date% %time% - see the error above >> logs\pipeline.log
exit /b 1