@echo off
setlocal
pushd "%~dp0.." || exit /b 1
call poetry install --no-interaction
if errorlevel 1 goto :failed
call poetry run python scripts/run_demo.py
set "demo_exit=%errorlevel%"
popd
exit /b %demo_exit%
:failed
set "demo_exit=%errorlevel%"
popd
exit /b %demo_exit%
