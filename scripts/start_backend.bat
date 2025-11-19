@echo off
REM Start Audio2Face Backend Server

cd /d "%~dp0\..\backend"

echo ==========================================
echo Audio2Face Backend Server
echo ==========================================

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies if needed
if not exist "venv\.installed" (
    echo Installing dependencies...
    pip install --upgrade pip
    pip install -r requirements.txt
    type nul > venv\.installed
)

REM Check if temp directory exists
if not exist "temp" (
    mkdir temp
)

echo.
echo Starting FastAPI server...
echo API will be available at: http://localhost:8000
echo API docs available at: http://localhost:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo.

python main.py

pause
