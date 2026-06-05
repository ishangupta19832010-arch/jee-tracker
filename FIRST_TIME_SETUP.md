# JEE Prep Tracker - Complete Beginner Setup Guide

## 🎉 Welcome!

This is your **step-by-step guide** to get the JEE Prep Tracker running. No coding experience needed!

**⏱️ Total Time: 5 minutes**

---

## **Step 1: Get the Code** (1 minute)

### **Option A: Using Git (Recommended)**
Open Terminal/Command Prompt and paste:
```bash
git clone https://github.com/ishangupta19832010-arch/jee-tracker.git
cd jee-tracker
```

### **Option B: Download as ZIP**
1. Go to: https://github.com/ishangupta19832010-arch/jee-tracker
2. Click green **Code** button → **Download ZIP**
3. Extract anywhere
4. Open Terminal/Command Prompt in that folder

---

## **Step 2: Install Python** (2 minutes)

### **Check if you have Python**
```bash
python --version
```

Should show `Python 3.9.0` or higher.

### **Don't have Python?**

**Windows:**
1. Go to: https://www.python.org/downloads/
2. Download **Python 3.11**
3. **IMPORTANT**: Check "Add Python to PATH"
4. Click Install

**Mac:**
```bash
brew install python3
```

**Linux:**
```bash
sudo apt-get install python3 python3-pip
```

---

## **Step 3: Install Dependencies** (1 minute)

### **Windows:**
Double-click: **install.bat**

### **Mac/Linux:**
```bash
bash install.sh
```

**Wait for it to finish...** ⏳

---

## **Step 4: Launch the App** (1 minute)

### **Windows:**
Double-click: **start.bat**

### **Mac/Linux:**
```bash
bash start.sh
```

**The app launches in 2 seconds!** 🚀

---

## **First Time Using?**

1. Click **"🔄 Generate Today's Unique Chart"**
2. Check off tasks as you complete them
3. Go to **📈 Analytics** to see charts
4. Watch your streak grow!

---

## ❌ **Troubleshooting**

### **"Python not found"**
- Windows: Make sure you checked "Add Python to PATH"
- Restart computer
- Try again

### **"ModuleNotFoundError"**
Run: `pip install -r requirements.txt`

### **App crashes**
```bash
rm jee_tracker.db
python main.py
```

---

## 🎉 **Congratulations!**

You're ready to track your JEE prep! Start now! 🎯