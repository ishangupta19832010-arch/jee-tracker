#!/bin/bash
echo "🎯 Installing JEE Prep Tracker..."
echo ""
echo "✓ Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Please install Python 3.9+ from python.org"
    exit 1
fi
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "✓ Python $PYTHON_VERSION found"
echo ""
echo "📦 Installing dependencies..."
pip install -r requirements.txt --quiet
if [ $? -eq 0 ]; then
    echo "✓ Dependencies installed successfully"
    echo ""
    echo "🎉 Installation complete!"
    echo ""
    echo "To start the app, run:"
    echo "  cd desktop_app && python main.py"
else
    echo "❌ Installation failed. Please check your Python installation."
    exit 1
fi