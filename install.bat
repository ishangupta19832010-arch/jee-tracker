@echo off
echo 🎯 Installing JEE Prep Tracker...
echo.
echo ✓ Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.9+ from python.org
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo ✓ %PYTHON_VERSION% found
echo.
echo 📦 Installing dependencies...
pip install -r requirements.txt --quiet
if %errorlevel% equ 0 (
    echo ✓ Dependencies installed successfully
    echo.
    echo 🎉 Installation complete!
    echo.
    echo To start the app, run:
    echo   cd desktop_app
    echo   python main.py
    echo.
    pause
) else (
    echo ❌ Installation failed. Please check your Python installation.
    pause
    exit /b 1
)