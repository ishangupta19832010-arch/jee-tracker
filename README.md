# 🎯 JEE Prep Tracker

**Your Personal JEE Preparation Tracking System**

Complete AI-powered daily goal assistant with analytics, streak tracking, and offline-first database. Available on **Desktop, Web, and Mobile**.

![Status](https://img.shields.io/badge/Status-Production%20Ready-green)
![Python](https://img.shields.io/badge/Python-3.9%2B-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 🚀 **Quick Start (Choose Your Platform)**

### **🖥️ Desktop App (Recommended for Laptop)**
```bash
# Clone
git clone https://github.com/ishangupta19832010-arch/jee-tracker.git
cd jee-tracker

# Install
pip install -r requirements.txt

# Run (Windows/Mac/Linux)
cd desktop_app
python main.py
```
**Launches in 2 seconds! Offline-first, dark theme, beautiful UI.** ✨

### **🌐 Web App (Cloud-Based)**
```bash
# Install
pip install -r requirements.txt

# Run
streamlit run app.py

# Or deploy to Streamlit Cloud (one-click)
# https://share.streamlit.io/ → Select repo → Deploy!
```
**Cloud-based, shareable links, accessible anywhere.**

### **📱 Mobile App (iOS/Android)**
```bash
cd flutter_app
flutter pub get
flutter run
```

### **🐳 Docker (Production)**
```bash
docker-compose up
# Access at http://localhost:8501
```

---

## ✨ **Features**

### 📊 **Daily Tracker**
- Generate unique, non-repeating daily targets
- Track 4 tasks: Physics, Chemistry, Math, Habit
- Real-time progress visualization
- Celebrate when all tasks complete
- Difficulty levels: Beginner → Intermediate → Advanced

### 📈 **Analytics Dashboard**
- Weekly completion charts
- Subject-wise performance breakdown
- Completion rate statistics
- **🔥 Streak system** - Track consecutive days
- Visual metrics cards

### ⭐ **Custom Topics**
- Add your weak areas
- Organize by subject
- Dynamically integrate into daily targets
- Personalize your prep

### 📋 **Complete History**
- View all past targets
- Export to CSV for records
- Track long-term progress
- Analyze patterns

### 🎓 **Difficulty Levels**

| Level | Focus | Daily Load | When |
|-------|-------|-----------|------|
| **Beginner** | Foundation | 5 easy PYQs | Weeks 1-4 |
| **Intermediate** | Mastery | 15 tough PYQs | Weeks 5-12 |
| **Advanced** | Perfection | 20 hard PYQs | Weeks 13+ |

---

## 📱 **Platform Comparison**

| Feature | Desktop | Web | Mobile | Docker |
|---------|---------|-----|--------|--------|
| **Setup** | 30 sec | 1-click | App Store | Docker |
| **Offline** | ✅ | ❌ | ✅ | ✅ |
| **Performance** | ⚡⚡⚡ | ⚡⚡ | ⚡⚡⚡ | ⚡⚡⚡ |
| **Best For** | Laptop | Sharing | Daily | Production |

---

## 📦 **What's Inside**

```
jee-tracker/
├── 🖥️  desktop_app/main.py       # Desktop app (800 lines)
├── 🌐 app.py                    # Web app (Streamlit)
├── 💾 database.py               # Shared database
├── 📚 topics.py                 # 63 JEE topics
├── 📱 flutter_app/lib/main.dart # Mobile app (1000 lines)
├── 🐳 docker-compose.yml        # Docker config
└── 📋 docs/                     # Full documentation
```

**Total:** 2500+ lines of production-ready code

---

## 🎯 **Daily Workflow**

```
Morning (1 min)          Midday (Ongoing)      Evening (2 min)
─────────────────────────────────────────────────────────
Open app           →     Study & Check off    →    Review Progress
Generate chart           completed tasks           Update streak
See 4 targets           Track real-time           Celebrate wins
                        progress bar
```

---

## 💾 **Data Management**

### **Local Storage (Offline-First)**
- **Desktop**: SQLite on your computer
- **Mobile**: SQLite on device
- **Web**: Browser cache + SQLite option

### **What Gets Saved**
✅ Daily targets (Physics, Chemistry, Math, Habit)  
✅ Completion status  
✅ User preferences  
✅ Difficulty level  
✅ Custom topics  
✅ Streak count  
✅ Complete history  

**100% private. No tracking. No ads.**

---

## 🔧 **System Requirements**

### **Desktop/Web**
- Python 3.9+
- 512 MB RAM
- 100 MB disk space

### **Mobile**
- iOS 11+ or Android 5+
- 50 MB space

### **Supported OS**
- ✅ Windows 7+
- ✅ macOS 10.12+
- ✅ Linux (Ubuntu 16+)
- ✅ Raspberry Pi

---

## 🎯 **How It Works**

### **Step 1: Generate Daily Chart** (30 seconds)
- System picks 1 topic from each subject
- Different from yesterday (non-repetition)
- Matched to your difficulty level

### **Step 2: Study & Track** (All day)
- Check off tasks as you complete them
- Watch progress bar fill up
- Real-time motivation

### **Step 3: Review Progress** (Evening)
- See daily completion status
- Track your streak
- View analytics

### **Step 4: Analyze Weekly** (Sunday)
- Review 7-day analytics
- Check subject performance
- Export records

---

## 📊 **Topics Database**

### **Physics (21 topics)**
- Beginner: Basic motion, heat, electricity
- Intermediate: Rotational motion, electrodynamics, optics
- Advanced: Quantum mechanics, relativity

### **Chemistry (21 topics)**
- Beginner: Atomic structure, stoichiometry
- Intermediate: Organic reactions, coordination compounds
- Advanced: Synthesis, kinetics, thermodynamics

### **Mathematics (21 topics)**
- Beginner: Polynomials, sequences, trigonometry
- Intermediate: Calculus, matrices, geometry
- Advanced: Differential equations, probability

**Total: 63 unique topics across 3 difficulty levels**

---

## 🏗️ **Architecture**

```
┌─────────────────────────────────────────────────────┐
│                   User Interface                     │
│  (Desktop/Web/Mobile/Docker)                        │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│              Business Logic                          │
│  • Random topic generation                          │
│  • Non-repetition algorithm                         │
│  • Streak calculation                               │
│  • Analytics processing                             │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│              Data Layer                              │
│  • SQLite Database (offline-first)                  │
│  • Local persistence                                │
│  • CSV export                                       │
└─────────────────────────────────────────────────────┘
```

---

## 📈 **Expected Progress**

| Week | Difficulty | Daily Tasks | Streak |
|------|-----------|-------------|--------|
| 1-2 | Beginner | 5 easy PYQs | 0-7 |
| 3-4 | Beginner | 5 easy PYQs | 5-14 |
| 5-8 | Intermediate | 15 tough PYQs | 10-28 |
| 9-12 | Intermediate | 15 tough PYQs | 20-42 |
| 13-16 | Advanced | 20 hard PYQs | 30-56 |
| 17-20 | Advanced | 20 hard PYQs | 40-70 |

---

## 🚀 **Deployment Options**

### **Desktop (Recommended for personal use)**
- Standalone executable (no Python needed)
- Build with PyInstaller
- Share `.exe`, `.app`, or binary with friends

### **Web (Recommended for sharing)**
1. Push to GitHub ✅
2. Go to https://share.streamlit.io/
3. Select repo → Deploy (1 click)
4. Share link with friends!

### **Mobile (App Store)**
1. Build APK: `flutter build apk --release`
2. Create Google Play Console account
3. Upload & submit for review

### **Docker (Production)**
```bash
docker build -t jee-tracker .
docker run -p 8501:8501 jee-tracker
```

Deploy to AWS, DigitalOcean, Railway, Render, etc.

---

## 🔐 **Privacy & Security**

✅ **100% Offline** - All data stays on your device  
✅ **No Tracking** - No analytics, no user tracking  
✅ **No Ads** - Clean, distraction-free interface  
✅ **Open Source** - Audit the code yourself  
✅ **MIT License** - Use freely, commercially or personally  

---

## 📚 **Full Documentation**

- **[Desktop Setup Guide](desktop_app/README.md)** - Detailed desktop instructions
- **[Multi-Platform Guide](PLATFORMS.md)** - Compare all platforms
- **[Desktop App Guide](DESKTOP_APP_GUIDE.md)** - Advanced desktop tips
- **[Flutter Setup](flutter_app/README.md)** - Mobile app guide

---

## 🎓 **Success Tips**

1. **Consistency Over Intensity**
   - Use app every single day
   - Build the habit, not the hustle

2. **Progressive Difficulty**
   - Start with Beginner (1-4 weeks)
   - Move to Intermediate (4-12 weeks)
   - Advance to Advanced (12+ weeks)

3. **Review Weekly**
   - Check analytics every Sunday
   - Export data monthly
   - Adjust difficulty if needed

4. **Customize Topics**
   - Add your weak areas
   - Add topics from your coaching
   - Make it personal to YOUR prep

5. **Track Everything**
   - Don't skip days
   - Mark completion honestly
   - Let data guide you

---

## 🐛 **Troubleshooting**

### Desktop App Issues
```bash
# Delete database if corrupted
rm jee_tracker.db

# Reinstall dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Run with debug
python main.py --debug
```

### Python Not Found
```bash
# Windows: Download from python.org
# macOS: brew install python3
# Linux: sudo apt-get install python3
```

### Tkinter Import Error
```bash
# Linux only
sudo apt-get install python3-tk
```

### Database Locked
```bash
# Close app and try again
# Or delete jee_tracker.db
```

---

## 📞 **Support**

- **Issues**: GitHub Issues for bugs
- **Features**: GitHub Discussions for ideas
- **Questions**: Check documentation first
- **Feedback**: All feedback welcome!

---

## 🤝 **Contributing**

Contributions welcome! Areas:
- UI improvements
- New features
- Bug fixes
- Documentation
- Translations

---

## 📄 **License**

MIT License - Use freely for any purpose

---

## 🙏 **Credits**

Built with ❤️ for JEE aspirants preparing for:
- **Joint Entrance Examination (JEE Main)**
- **JEE Advanced**
- **NEET** (adapt topics)
- **Any competitive exam**

---

## 🚀 **Start Your Journey**

### **First Time?**
```bash
# Just 3 steps:
1. git clone https://github.com/ishangupta19832010-arch/jee-tracker.git
2. pip install -r requirements.txt
3. cd desktop_app && python main.py
```

### **Already Have Python?**
```bash
# Just 2 steps:
1. pip install -r requirements.txt
2. cd desktop_app && python main.py
```

### **Want Web Version?**
```bash
# Just 1 step:
streamlit run app.py
```

---

## 📊 **Repository Stats**

- **Total Code**: 2500+ lines
- **Languages**: Python, Dart, YAML
- **Database**: SQLite
- **UI Frameworks**: Tkinter, Streamlit, Flutter, Material Design
- **Platforms**: Windows, macOS, Linux, iOS, Android, Web
- **Features**: 20+
- **Topics**: 63
- **Status**: ✅ Production Ready

---

## 🎯 **Remember**

> *"The secret of getting ahead is getting started."* - Mark Twain

This app won't prepare you for JEE. **You will.** But this app will:
- 🎯 Keep you focused
- 📊 Track your progress
- 🔥 Maintain your motivation
- 💪 Help you outwork competition

**Let's go! Your JEE success starts now!** 🚀

---

**Version**: 2.0.0  
**Last Updated**: June 2026  
**Maintained By**: Aaryan & Community  
**Status**: ✅ Production Ready

⭐ **If this helped you, please star the repository!**
