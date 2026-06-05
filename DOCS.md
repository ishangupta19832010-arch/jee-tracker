# 📚 Documentation & Help

## **For Complete Beginners**
👉 Start here: **[FIRST_TIME_SETUP.md](FIRST_TIME_SETUP.md)**

---

## **Platform Guides**

### **🖥️ Desktop App**
- [Setup](desktop_app/README.md)
- Launch: `cd desktop_app && python main.py`

### **🌐 Web App**
- Launch: `streamlit run app.py`
- Deploy: https://share.streamlit.io/

### **📱 Mobile App**
- [Flutter Setup](flutter_app/README.md)
- Launch: `cd flutter_app && flutter run`

### **🐳 Docker**
- Launch: `docker-compose up`

---

## **Quick Links**

| What | File |
|------|------|
| First time? | [FIRST_TIME_SETUP.md](FIRST_TIME_SETUP.md) |
| Main guide | [README.md](README.md) |
| Desktop advanced | [DESKTOP_APP_GUIDE.md](DESKTOP_APP_GUIDE.md) |
| Compare platforms | [PLATFORMS.md](PLATFORMS.md) |
| Contribute | [CONTRIBUTING.md](CONTRIBUTING.md) |

---

## **Troubleshooting**

### **App won't start**
```bash
python --version
pip install -r requirements.txt
cd desktop_app && python main.py
```

### **Database error**
```bash
rm jee_tracker.db
python main.py
```

### **Python not found**
- Windows: Download from python.org
- Mac: `brew install python3`
- Linux: `sudo apt-get install python3`

---

**Happy tracking! 🎯**