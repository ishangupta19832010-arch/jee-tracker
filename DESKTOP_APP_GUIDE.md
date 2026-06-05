# 🖥️ Desktop App - Complete Guide

## Quick Start

```bash
git clone https://github.com/ishangupta19832010-arch/jee-tracker.git
cd jee-tracker
pip install -r requirements.txt
cd desktop_app
python main.py
```

**That's it!** App launches in 2 seconds. ✨

---

## Features

✅ **Daily Tracker** - Generate & track 4 daily tasks  
✅ **Analytics** - Weekly charts & streak tracking  
✅ **Custom Topics** - Add your weak areas  
✅ **History** - View & export all data  
✅ **Difficulty Levels** - Beginner/Intermediate/Advanced  
✅ **Dark Theme** - Eye-friendly interface  
✅ **Offline** - Works without internet  

---

## System Requirements

- Python 3.9+
- Windows 7+ / macOS 10.12+ / Linux
- 512 MB RAM
- 100 MB disk space

---

## Troubleshooting

### App won't start
```bash
python --version
pip install -r requirements.txt
cd desktop_app && python main.py
```

### Database error
```bash
rm jee_tracker.db
python main.py
```

### Python not found
- Windows: Download from python.org (add to PATH)
- Mac: `brew install python3`
- Linux: `sudo apt-get install python3`

---

## Build Standalone Executable

```bash
pip install pyinstaller
cd desktop_app
pyinstaller --onefile --windowed main.py
```

Find executable in `dist/` folder!

---

**Happy tracking! 🎯**