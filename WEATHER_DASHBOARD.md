# 🌤️ Weather Dashboard

**Complete weather application with desktop and web versions**

---

## 🚀 Quick Start

### **Desktop Version**
```bash
pip install -r requirements.txt
python weather_dashboard.py
```

### **Web Version (Cloud)**
```bash
pip install -r requirements.txt
streamlit run weather_web.py
```

---

## 📦 Files

| File | Purpose |
|------|---------|
| `weather_api.py` | Weather API client with caching |
| `weather_dashboard.py` | Desktop app (Tkinter) |
| `weather_web.py` | Web app (Streamlit) |

---

## ✨ Features

### 🌡️ **Current Weather**
- Real-time temperature, humidity, wind speed
- Sunrise/sunset times
- Detailed weather information
- Visual weather cards

### 📊 **5-Day Forecast**
- Temperature trends
- Humidity patterns
- Wind speed forecast
- Hourly breakdown

### 🔍 **City Search**
- Search by city name
- Multi-result display
- Quick selection

### ⭐ **Favorites**
- Save favorite cities
- Quick access
- One-click weather view

### 📍 **Compare Cities**
- Compare multiple cities
- Side-by-side metrics
- Temperature comparison charts

### 📈 **Analytics**
- Temperature trends (charts)
- Humidity patterns
- Wind speed analysis
- Historical data

---

## 📊 Data Available

**Current Weather:**
- Temperature, Feels Like
- Min/Max temps
- Humidity, Pressure
- Wind speed & direction
- Visibility
- Cloud coverage
- Sunrise/Sunset

**Forecast:**
- Hourly data (8 entries per day)
- 5-day projection
- Temperature ranges
- Precipitation forecasts

---

## 🎨 UI Features

### Desktop (Tkinter)
- ✅ Dark theme (#0E1117)
- ✅ Professional cards
- ✅ Real-time updates
- ✅ Responsive layout
- ✅ Color-coded data

### Web (Streamlit)
- ✅ Interactive charts
- ✅ Multiple pages
- ✅ Data visualization
- ✅ Responsive design
- ✅ Easy deployment

---

## 🔧 Configuration

### API Key (Optional)
```python
# In weather_api.py
weather_api = WeatherAPI(api_key="your_openweathermap_key")
```

**Free tier:** Works without API key (limited requests)

---

## 📱 Platforms

| Platform | Command | Features |
|----------|---------|----------|
| **Desktop (Windows)** | `python weather_dashboard.py` | Full desktop app |
| **Desktop (Mac/Linux)** | `python3 weather_dashboard.py` | Full desktop app |
| **Web** | `streamlit run weather_web.py` | Cloud-ready |
| **Docker** | `docker-compose up` | Production |

---

## 🌍 Supported Data Sources

- **OpenWeatherMap API** (Free tier)
- Real-time weather data
- 5-day forecasts
- City search & coordinates
- No authentication required

---

## 📊 Sample Cities

Pre-configured examples:
- London, UK
- New York, USA
- Tokyo, Japan
- Paris, France
- Sydney, Australia
- Mumbai, India
- Berlin, Germany
- Toronto, Canada

---

## 💾 Data Caching

- **Cache Duration:** 10 minutes
- **Automatic Expiration:** Yes
- **Manual Clear:** Available in menu
- **Storage:** In-memory

---

## 🔐 Privacy

✅ No user tracking  
✅ No data storage  
✅ Local caching only  
✅ Public API data  

---

## 🆘 Troubleshooting

### **"Connection error"**
- Check internet connection
- API might be rate limited (free tier)
- Try again in 5 minutes

### **"City not found"**
- Try alternate spelling
- Use country code (e.g., "London, UK")
- Search for nearby major cities

### **"No data displayed"**
- Free tier limited requests
- Wait 5 minutes and retry
- Consider getting API key

---

## 📚 API Endpoints

```python
# Current weather
weather_api.get_current_weather(city, units="metric")

# Forecast
weather_api.get_forecast(city, units="metric", days=5)

# Search cities
weather_api.search_cities(query, limit=5)

# Multiple cities
weather_api.get_multiple_cities(cities, units="metric")

# Coordinates
weather_api.get_coordinates(city)
```

---

## 🎯 Next Steps

1. **Run Desktop:** `python weather_dashboard.py`
2. **Or Web:** `streamlit run weather_web.py`
3. **Search Cities:** Use search feature
4. **Add Favorites:** Save your cities
5. **View Forecasts:** Check 5-day trends
6. **Compare Cities:** Multi-city analysis

---

## 🚀 Deploy to Cloud

### **Streamlit Cloud**
```bash
# Push to GitHub
git push

# Deploy at share.streamlit.io
```

### **Docker**
```bash
docker-compose up
```

---

**Happy weather tracking! 🌤️**
