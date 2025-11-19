@echo off
REM Start Audio2Face Frontend Server

cd /d "%~dp0\..\frontend"

echo ==========================================
echo Audio2Face Frontend Server
echo ==========================================

set PORT=3000

echo.
echo Starting HTTP server on port %PORT%...
echo Frontend will be available at: http://localhost:%PORT%
echo.
echo Press Ctrl+C to stop the server
echo.

python -m http.server %PORT%

pause
