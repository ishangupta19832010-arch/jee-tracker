import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
import random
import json
from tkcalendar import Calendar
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
import pandas as pd

# Database Setup
DB_PATH = Path("jee_tracker.db")

class DatabaseHelper:
    def __init__(self):
        self.connection = None
        self.init_database()

    def get_connection(self):
        if self.connection is None:
            self.connection = sqlite3.connect(str(DB_PATH))
        return self.connection

    def init_database(self):
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS daily_targets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT UNIQUE NOT NULL,
                physics TEXT NOT NULL,
                chemistry TEXT NOT NULL,
                mathematics TEXT NOT NULL,
                habit TEXT NOT NULL,
                difficulty TEXT DEFAULT 'Intermediate'
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS daily_completion (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT UNIQUE NOT NULL,
                physics_done INTEGER DEFAULT 0,
                chemistry_done INTEGER DEFAULT 0,
                mathematics_done INTEGER DEFAULT 0,
                habit_done INTEGER DEFAULT 0
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                difficulty_level TEXT DEFAULT 'Intermediate',
                custom_topics TEXT DEFAULT '{}'
            )
        """)

        conn.commit()

    def save_daily_target(self, date, physics, chemistry, mathematics, habit, difficulty):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO daily_targets 
            (date, physics, chemistry, mathematics, habit, difficulty)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (date, physics, chemistry, mathematics, habit, difficulty))
        conn.commit()

    def get_daily_target(self, date):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT physics, chemistry, mathematics, habit FROM daily_targets WHERE date = ?
        """, (date,))
        result = cursor.fetchone()
        if result:
            return {
                "Physics": result[0],
                "Chemistry": result[1],
                "Mathematics": result[2],
                "Habit": result[3]
            }
        return None

    def save_completion(self, date, physics_done, chemistry_done, mathematics_done, habit_done):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO daily_completion 
            (date, physics_done, chemistry_done, mathematics_done, habit_done)
            VALUES (?, ?, ?, ?, ?)
        """, (date, int(physics_done), int(chemistry_done), int(mathematics_done), int(habit_done)))
        conn.commit()

    def get_completion(self, date):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT physics_done, chemistry_done, mathematics_done, habit_done 
            FROM daily_completion WHERE date = ?
        """, (date,))
        result = cursor.fetchone()
        if result:
            return {
                "physics": bool(result[0]),
                "chemistry": bool(result[1]),
                "mathematics": bool(result[2]),
                "habit": bool(result[3])
            }
        return {"physics": False, "chemistry": False, "mathematics": False, "habit": False}

    def get_weekly_stats(self):
        end_date = datetime.now()
        start_date = end_date - timedelta(days=6)
        
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT date, physics_done, chemistry_done, mathematics_done, habit_done
            FROM daily_completion 
            WHERE date BETWEEN ? AND ?
            ORDER BY date
        """, (start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")))

        stats = []
        for row in cursor.fetchall():
            date, p, c, m, h = row
            completed = sum([p, c, m, h])
            stats.append({
                "date": date,
                "completed": completed,
                "total": 4,
                "physics": bool(p),
                "chemistry": bool(c),
                "mathematics": bool(m),
                "habit": bool(h)
            })
        return stats

    def get_streak(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT date FROM daily_completion 
            WHERE physics_done = 1 AND chemistry_done = 1 AND mathematics_done = 1 AND habit_done = 1
            ORDER BY date DESC
        """)

        completed_dates = [datetime.strptime(row[0], "%Y-%m-%d").date() for row in cursor.fetchall()]

        if not completed_dates:
            return 0

        streak = 1
        for i in range(len(completed_dates) - 1):
            if (completed_dates[i] - completed_dates[i + 1]).days == 1:
                streak += 1
            else:
                break

        return streak

    def update_difficulty(self, difficulty_level):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO user_settings (id, difficulty_level)
            VALUES (1, ?)
        """, (difficulty_level,))
        conn.commit()

    def get_difficulty(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT difficulty_level FROM user_settings WHERE id = 1")
        result = cursor.fetchone()
        return result[0] if result else "Intermediate"

    def get_all_history(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT t.date, t.physics, t.chemistry, t.mathematics, t.habit,
                   c.physics_done, c.chemistry_done, c.mathematics_done, c.habit_done
            FROM daily_targets t
            LEFT JOIN daily_completion c ON t.date = c.date
            ORDER BY t.date DESC
        """)

        history = []
        for row in cursor.fetchall():
            history.append({
                "date": row[0],
                "physics": row[1],
                "chemistry": row[2],
                "mathematics": row[3],
                "habit": row[4],
                "physics_done": bool(row[5]) if row[5] is not None else False,
                "chemistry_done": bool(row[6]) if row[6] is not None else False,
                "mathematics_done": bool(row[7]) if row[7] is not None else False,
                "habit_done": bool(row[8]) if row[8] is not None else False
            })
        return history

# Topics Database
class TopicsDatabase:
    DATABASE_BEGINNER = {
        "Physics": [
            "Mechanics (Basic Motion & Forces)",
            "Simple Harmonic Motion",
            "Heat & Temperature",
            "Sound Waves Basics",
            "Electricity Fundamentals",
            "Magnetism Basics",
            "Geometrical Optics"
        ],
        "Chemistry": [
            "Atomic Structure Basics",
            "Chemical Reactions & Equations",
            "Stoichiometry",
            "States of Matter",
            "Thermochemistry Basics",
            "Redox Reactions",
            "Periodic Table & Periodic Properties"
        ],
        "Mathematics": [
            "Sets & Relations",
            "Polynomial & Quadratic Equations",
            "Sequences & Series",
            "Permutation & Combination",
            "Basic Trigonometry",
            "Straight Lines",
            "Circles"
        ]
    }

    DATABASE_INTERMEDIATE = {
        "Physics": [
            "Mechanics (Rotational Motion & Kinematics)",
            "Electrodynamics (Gauss Law & Capacitor circuits)",
            "Modern Physics (Dual Nature & Nuclear Physics)",
            "Optics (Wave Optics & Interference)",
            "Thermodynamics & KTG",
            "Current Electricity & Kirchhoff's Laws",
            "Magnetic Effects of Current"
        ],
        "Chemistry": [
            "Organic: Reaction Mechanisms & Named Reactions",
            "Organic: Biomolecules & Polymers",
            "Inorganic: Coordination Compounds",
            "Inorganic: Chemical Bonding & MOT",
            "Physical: Chemical & Ionic Equilibrium",
            "Physical: Electrochemistry & Nernst Equation",
            "Physical: Liquid Solutions"
        ],
        "Mathematics": [
            "Calculus: Definite Integration & AUC",
            "Calculus: Limits, Continuity & Differentiability",
            "Algebra: Matrices & Determinants",
            "Algebra: Probability & PnC",
            "Coordinate Geometry: Conic Sections",
            "Vector & 3D Geometry",
            "Trigonometry: Inverse Trigonometric Functions"
        ]
    }

    DATABASE_ADVANCED = {
        "Physics": [
            "Advanced Rotational Dynamics & Angular Momentum",
            "Gauss Law Applications & Complex Capacitor Networks",
            "Quantum Mechanics & Schrodinger Equation",
            "Diffraction & Polarization Advanced Topics",
            "Thermodynamic Cycles & Real Gas Behavior",
            "Electromagnetic Induction & AC Circuits",
            "Relativity & Photoelectric Effect"
        ],
        "Chemistry": [
            "Organic Synthesis Strategy & Multi-step Reactions",
            "Organic Stereochemistry & Mechanisms Deep Dive",
            "Transition Metals & Complex Ion Chemistry",
            "Molecular Orbital Theory & Chemical Bonding",
            "Electrochemistry: Galvanic & Electrolytic Cells",
            "Kinetics & Reaction Rate Theory",
            "Thermodynamics & Gibbs Free Energy"
        ],
        "Mathematics": [
            "Calculus: Differential Equations & Applications",
            "Calculus: Taylor Series & Convergence",
            "Algebra: Groups & Rings (Advanced)",
            "Probability: Bayes Theorem & Distributions",
            "Coordinate Geometry: 3D Conic Sections",
            "Vector: Cross Product & Applications",
            "Complex Analysis & De Moivre's Theorem"
        ]
    }

    HABITS_BEGINNER = [
        "Solve 5 easy PYQs under a 30-minute timer.",
        "Review notes for one topic and make flashcards.",
        "Solve 3 basic multiple-choice questions from any subject.",
        "Watch a 20-minute concept video and summarize it."
    ]

    HABITS_INTERMEDIATE = [
        "Solve 15 PYQs under a strict 45-minute timer.",
        "Review your 'Mistake Book' and re-solve 5 previously failed questions.",
        "Take a 1-hour chapter mock test and analyze weak concepts.",
        "Formula Sprint: Write all formulas of 3 random chapters from memory."
    ]

    HABITS_ADVANCED = [
        "Solve 20 advanced PYQs under 50-minute timer with full analysis.",
        "Deep-dive revision: Review 3 weak topics and solve their toughest problems.",
        "Take a full 3-hour mock test and create detailed error analysis.",
        "Create original problems from 2 chapters and solve them perfectly."
    ]

    @staticmethod
    def get_database(difficulty):
        if difficulty == "Beginner":
            return TopicsDatabase.DATABASE_BEGINNER
        elif difficulty == "Advanced":
            return TopicsDatabase.DATABASE_ADVANCED
        else:
            return TopicsDatabase.DATABASE_INTERMEDIATE

    @staticmethod
    def get_habits(difficulty):
        if difficulty == "Beginner":
            return TopicsDatabase.HABITS_BEGINNER
        elif difficulty == "Advanced":
            return TopicsDatabase.HABITS_ADVANCED
        else:
            return TopicsDatabase.HABITS_INTERMEDIATE

# Main Application
class JEETrackerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("🎯 JEE Prep Tracker - Desktop Edition")
        self.geometry("1200x700")
        self.configure(bg="#0E1117")
        
        # Configure style
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('TLabel', background="#0E1117", foreground="#C9D1D9")
        style.configure('TFrame', background="#0E1117")
        style.configure('TButton', background="#FF6B35", foreground="#FFFFFF")
        
        self.db = DatabaseHelper()
        self.current_page = None
        
        self.create_menu_bar()
        self.create_sidebar()
        self.create_main_frame()
        self.show_daily_tracker()

    def create_menu_bar(self):
        menubar = tk.Menu(self, bg="#161B22", fg="#C9D1D9")
        self.config(menu=menubar)
        
        file_menu = tk.Menu(menubar, tearoff=0, bg="#161B22", fg="#C9D1D9")
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="Export History as CSV", command=self.export_history)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.quit)
        
        help_menu = tk.Menu(menubar, tearoff=0, bg="#161B22", fg="#C9D1D9")
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)

    def create_sidebar(self):
        self.sidebar = tk.Frame(self, bg="#161B22", width=150)
        self.sidebar.pack(side=tk.LEFT, fill=tk.Y, padx=0)
        
        title = tk.Label(self.sidebar, text="📋 MENU", bg="#161B22", fg="#FF6B35", font=("Arial", 12, "bold"))
        title.pack(pady=10)
        
        buttons = [
            ("📊 Daily Tracker", self.show_daily_tracker),
            ("📈 Analytics", self.show_analytics),
            ("⭐ Topics", self.show_topics),
            ("📋 History", self.show_history),
        ]
        
        for text, command in buttons:
            btn = tk.Button(
                self.sidebar,
                text=text,
                command=command,
                bg="#1f1f1f",
                fg="#C9D1D9",
                font=("Arial", 10),
                relief=tk.FLAT,
                padx=10,
                pady=10,
                width=15,
                wraplength=120
            )
            btn.pack(pady=5, padx=5)

    def create_main_frame(self):
        self.main_frame = tk.Frame(self, bg="#0E1117")
        self.main_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=10, pady=10)

    def clear_main_frame(self):
        for widget in self.main_frame.winfo_children():
            widget.destroy()

    def show_daily_tracker(self):
        self.clear_main_frame()
        self.current_page = "daily_tracker"
        
        # Header
        header = tk.Frame(self.main_frame, bg="#0E1117")
        header.pack(fill=tk.X, pady=10)
        
        title = tk.Label(header, text="🎯 Daily JEE Prep Goal Assistant", 
                         bg="#0E1117", fg="#FF6B35", font=("Arial", 16, "bold"))
        title.pack(side=tk.LEFT)
        
        today = datetime.now().strftime("%B %d, %Y")
        date_label = tk.Label(header, text=f"📅 {today}", 
                             bg="#0E1117", fg="#C9D1D9", font=("Arial", 10))
        date_label.pack(side=tk.RIGHT)
        
        # Difficulty selector
        selector_frame = tk.Frame(self.main_frame, bg="#161B22")
        selector_frame.pack(fill=tk.X, pady=10)
        
        tk.Label(selector_frame, text="Difficulty Level:", 
                bg="#161B22", fg="#C9D1D9", font=("Arial", 10)).pack(side=tk.LEFT, padx=5)
        
        difficulty_var = tk.StringVar(value=self.db.get_difficulty())
        difficulty_combo = ttk.Combobox(selector_frame, textvariable=difficulty_var, 
                                       values=["Beginner", "Intermediate", "Advanced"], 
                                       state="readonly", width=15)
        difficulty_combo.pack(side=tk.LEFT, padx=5)
        
        def update_difficulty():
            self.db.update_difficulty(difficulty_var.get())
            messagebox.showinfo("Success", f"Difficulty updated to {difficulty_var.get()}!")
        
        update_btn = tk.Button(selector_frame, text="Update", command=update_difficulty,
                              bg="#FF6B35", fg="white", relief=tk.FLAT, padx=10)
        update_btn.pack(side=tk.LEFT, padx=5)
        
        streak = self.db.get_streak()
        streak_label = tk.Label(selector_frame, text=f"🔥 Streak: {streak} days", 
                               bg="#161B22", fg="#FFD700", font=("Arial", 10, "bold"))
        streak_label.pack(side=tk.RIGHT, padx=10)
        
        # Generate button
        generate_btn = tk.Button(self.main_frame, text="🔄 Generate Today's Unique Chart",
                                bg="#FF6B35", fg="white", font=("Arial", 12, "bold"),
                                relief=tk.FLAT, padx=20, pady=10,
                                command=lambda: self.generate_chart(difficulty_var.get()))
        generate_btn.pack(pady=10)
        
        # Targets frame
        self.targets_frame = tk.Frame(self.main_frame, bg="#0E1117")
        self.targets_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        self.load_daily_targets(difficulty_var.get())

    def generate_chart(self, difficulty):
        today = datetime.now().strftime("%Y-%m-%d")
        history = self.db.get_all_history()
        last_chart = {}
        
        if history and history[0]["date"] != today:
            last_chart = {
                "Physics": history[0]["physics"],
                "Chemistry": history[0]["chemistry"],
                "Mathematics": history[0]["mathematics"],
                "Habit": history[0]["habit"]
            }
        
        database = TopicsDatabase.get_database(difficulty)
        habits = TopicsDatabase.get_habits(difficulty)
        
        new_chart = {}
        for subject in ["Physics", "Chemistry", "Mathematics"]:
            topics = database[subject]
            allowed = [t for t in topics if t != last_chart.get(subject)]
            new_chart[subject] = random.choice(allowed) if allowed else random.choice(topics)
        
        allowed_habits = [h for h in habits if h != last_chart.get("Habit")]
        new_chart["Habit"] = random.choice(allowed_habits) if allowed_habits else random.choice(habits)
        
        self.db.save_daily_target(today, new_chart["Physics"], new_chart["Chemistry"],
                                 new_chart["Mathematics"], new_chart["Habit"], difficulty)
        
        self.load_daily_targets(difficulty)
        messagebox.showinfo("Success", "✨ New chart generated!")

    def load_daily_targets(self, difficulty):
        for widget in self.targets_frame.winfo_children():
            widget.destroy()
        
        today = datetime.now().strftime("%Y-%m-%d")
        chart = self.db.get_daily_target(today)
        completion = self.db.get_completion(today)
        
        if not chart:
            tk.Label(self.targets_frame, text="👆 Click the button above to generate your target chart.",
                    bg="#0E1117", fg="#C9D1D9", font=("Arial", 12)).pack(pady=20)
            return
        
        # Create task cards
        subjects = [
            ("🔬 Physics", "Physics", "#FF6B35"),
            ("⚗️ Chemistry", "Chemistry", "#00D9FF"),
            ("📐 Mathematics", "Mathematics", "#7B68EE"),
            ("⭐ Habit", "Habit", "#FFD700")
        ]
        
        self.checkboxes = {}
        
        for emoji_title, key, color in subjects:
            card = tk.Frame(self.targets_frame, bg="#161B22", relief=tk.RAISED, bd=1)
            card.pack(fill=tk.X, pady=5)
            
            row = tk.Frame(card, bg="#161B22")
            row.pack(fill=tk.X, padx=10, pady=10)
            
            tk.Label(row, text=emoji_title, bg="#161B22", fg=color,
                    font=("Arial", 11, "bold")).pack(side=tk.LEFT)
            
            var = tk.BooleanVar(value=completion.get(key.lower(), False))
            self.checkboxes[key] = var
            
            check = tk.Checkbutton(row, text=chart.get(key, "N/A"),
                                  variable=var, bg="#161B22", fg="#BBBBBB",
                                  font=("Arial", 10), selectcolor="#161B22",
                                  command=self.update_completion)
            check.pack(side=tk.LEFT, padx=20)
        
        # Progress bar
        completed = sum(1 for v in self.checkboxes.values() if v.get())
        progress = completed / 4
        
        progress_frame = tk.Frame(self.targets_frame, bg="#1f1f1f")
        progress_frame.pack(fill=tk.X, pady=20)
        
        progress_bar = tk.Canvas(progress_frame, bg="#333333", height=20, relief=tk.FLAT)
        progress_bar.pack(fill=tk.X, padx=10, pady=5)
        
        if progress > 0:
            progress_bar.create_rectangle(0, 0, progress_bar.winfo_width() * progress, 20,
                                         fill="#FF6B35", outline="#FF6B35")
        
        progress_text = tk.Label(progress_frame, text=f"Progress: {completed}/4 | {int(progress*100)}%",
                                bg="#1f1f1f", fg="#C9D1D9", font=("Arial", 10, "bold"))
        progress_text.pack()
        
        if completed == 4:
            celebration = tk.Frame(progress_frame, bg="#1f3a1f")
            celebration.pack(fill=tk.X, padx=10, pady=5)
            tk.Label(celebration, text="🔥 Outstanding! Day complete. You are outworking your competition!",
                    bg="#1f3a1f", fg="#00FF00", font=("Arial", 10, "bold")).pack(pady=5)

    def update_completion(self):
        today = datetime.now().strftime("%Y-%m-%d")
        self.db.save_completion(today,
                               self.checkboxes["Physics"].get(),
                               self.checkboxes["Chemistry"].get(),
                               self.checkboxes["Mathematics"].get(),
                               self.checkboxes["Habit"].get())
        self.load_daily_targets(self.db.get_difficulty())

    def show_analytics(self):
        self.clear_main_frame()
        self.current_page = "analytics"
        
        title = tk.Label(self.main_frame, text="📈 Analytics Dashboard",
                        bg="#0E1117", fg="#FF6B35", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        stats = self.db.get_weekly_stats()
        streak = self.db.get_streak()
        
        # Metrics
        metrics_frame = tk.Frame(self.main_frame, bg="#0E1117")
        metrics_frame.pack(fill=tk.X, pady=10)
        
        completed_days = sum(1 for s in stats if s["completed"] == 4)
        total_tasks = len(stats) * 4
        tasks_done = sum(s["completed"] for s in stats)
        completion_rate = (tasks_done / total_tasks * 100) if total_tasks > 0 else 0
        
        metrics = [
            (f"📅 Days Completed", f"{completed_days}/{len(stats)}", "#0066FF"),
            (f"🔥 Current Streak", f"{streak} days", "#FFD700"),
            (f"✅ Tasks Done", f"{tasks_done}/{total_tasks}", "#00FF00"),
            (f"📊 Completion %", f"{completion_rate:.1f}%", "#FF6B35"),
        ]
        
        for label, value, color in metrics:
            card = tk.Frame(metrics_frame, bg="#161B22", relief=tk.RAISED)
            card.pack(side=tk.LEFT, padx=10, fill=tk.BOTH, expand=True)
            
            tk.Label(card, text=label, bg="#161B22", fg="#C9D1D9",
                    font=("Arial", 10)).pack(pady=5)
            tk.Label(card, text=value, bg="#161B22", fg=color,
                    font=("Arial", 14, "bold")).pack(pady=5)
        
        # Chart
        if stats:
            chart_frame = tk.Frame(self.main_frame, bg="#0E1117")
            chart_frame.pack(fill=tk.BOTH, expand=True, pady=10)
            
            # Matplotlib figure
            fig = Figure(figsize=(10, 4), dpi=100, facecolor="#0E1117", edgecolor="none")
            ax = fig.add_subplot(111, facecolor="#161B22")
            
            dates = [s["date"] for s in stats]
            completed = [s["completed"] for s in stats]
            
            bars = ax.bar(dates, completed, color="#FF6B35", edgecolor="#FFFFFF", linewidth=0.5)
            ax.set_ylim(0, 4)
            ax.set_ylabel("Tasks Completed", color="#C9D1D9")
            ax.set_xlabel("Date", color="#C9D1D9")
            ax.tick_params(colors="#C9D1D9")
            ax.spines['bottom'].set_color("#C9D1D9")
            ax.spines['left'].set_color("#C9D1D9")
            ax.spines['top'].set_visible(False)
            ax.spines['right'].set_visible(False)
            
            canvas = FigureCanvasTkAgg(fig, master=chart_frame)
            canvas.draw()
            canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

    def show_topics(self):
        self.clear_main_frame()
        self.current_page = "topics"
        
        title = tk.Label(self.main_frame, text="⭐ Custom Topics",
                        bg="#0E1117", fg="#FF6B35", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        input_frame = tk.Frame(self.main_frame, bg="#161B22")
        input_frame.pack(fill=tk.X, padx=10, pady=10)
        
        tk.Label(input_frame, text="Subject:", bg="#161B22", fg="#C9D1D9").pack(side=tk.LEFT, padx=5)
        
        subject_var = tk.StringVar(value="Physics")
        subject_combo = ttk.Combobox(input_frame, textvariable=subject_var,
                                    values=["Physics", "Chemistry", "Mathematics"],
                                    state="readonly", width=15)
        subject_combo.pack(side=tk.LEFT, padx=5)
        
        tk.Label(input_frame, text="Topic:", bg="#161B22", fg="#C9D1D9").pack(side=tk.LEFT, padx=5)
        
        topic_entry = tk.Entry(input_frame, bg="#1f1f1f", fg="#C9D1D9", width=30)
        topic_entry.pack(side=tk.LEFT, padx=5)
        
        def add_topic():
            if topic_entry.get().strip():
                messagebox.showinfo("Success", f"✅ Added '{topic_entry.get()}' to {subject_var.get()}!")
                topic_entry.delete(0, tk.END)
            else:
                messagebox.showwarning("Warning", "⚠️ Please enter a topic name.")
        
        add_btn = tk.Button(input_frame, text="➕ Add Topic", command=add_topic,
                           bg="#FF6B35", fg="white", relief=tk.FLAT)
        add_btn.pack(side=tk.LEFT, padx=5)
        
        info_label = tk.Label(self.main_frame, text="No custom topics added yet. Add some above!",
                             bg="#0E1117", fg="#C9D1D9", font=("Arial", 11))
        info_label.pack(pady=20)

    def show_history(self):
        self.clear_main_frame()
        self.current_page = "history"
        
        title = tk.Label(self.main_frame, text="📋 Complete History",
                        bg="#0E1117", fg="#FF6B35", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        history = self.db.get_all_history()
        
        if not history:
            tk.Label(self.main_frame, text="📊 No history yet. Start generating daily targets!",
                    bg="#0E1117", fg="#C9D1D9", font=("Arial", 12)).pack(pady=20)
            return
        
        # Create table
        table_frame = tk.Frame(self.main_frame, bg="#0E1117")
        table_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        # Headers
        header_frame = tk.Frame(table_frame, bg="#161B22")
        header_frame.pack(fill=tk.X)
        
        headers = ["Date", "Physics", "Chemistry", "Mathematics", "Habit", "Status"]
        for header in headers:
            tk.Label(header_frame, text=header, bg="#161B22", fg="#FF6B35",
                    font=("Arial", 10, "bold"), width=15).pack(side=tk.LEFT, padx=2, pady=5)
        
        # Entries
        for entry in history[:20]:  # Show last 20
            entry_frame = tk.Frame(table_frame, bg="#1f1f1f")
            entry_frame.pack(fill=tk.X, pady=2)
            
            tk.Label(entry_frame, text=entry["date"], bg="#1f1f1f", fg="#C9D1D9",
                    width=15, font=("Arial", 9)).pack(side=tk.LEFT, padx=2)
            tk.Label(entry_frame, text="✅" if entry["physics_done"] else "❌", 
                    bg="#1f1f1f", width=15).pack(side=tk.LEFT, padx=2)
            tk.Label(entry_frame, text="✅" if entry["chemistry_done"] else "❌",
                    bg="#1f1f1f", width=15).pack(side=tk.LEFT, padx=2)
            tk.Label(entry_frame, text="✅" if entry["mathematics_done"] else "❌",
                    bg="#1f1f1f", width=15).pack(side=tk.LEFT, padx=2)
            tk.Label(entry_frame, text="✅" if entry["habit_done"] else "❌",
                    bg="#1f1f1f", width=15).pack(side=tk.LEFT, padx=2)
            
            completed = sum([entry["physics_done"], entry["chemistry_done"],
                           entry["mathematics_done"], entry["habit_done"]])
            status = f"{completed}/4"
            tk.Label(entry_frame, text=status, bg="#1f1f1f", fg="#FF6B35",
                    width=15, font=("Arial", 9, "bold")).pack(side=tk.LEFT, padx=2)

    def export_history(self):
        history = self.db.get_all_history()
        if not history:
            messagebox.showwarning("Warning", "No history to export!")
            return
        
        df = pd.DataFrame([
            {
                "Date": entry["date"],
                "Physics": entry["physics"],
                "Chemistry": entry["chemistry"],
                "Mathematics": entry["mathematics"],
                "Habit": entry["habit"],
                "Physics Done": "✅" if entry["physics_done"] else "❌",
                "Chemistry Done": "✅" if entry["chemistry_done"] else "❌",
                "Mathematics Done": "✅" if entry["mathematics_done"] else "❌",
                "Habit Done": "✅" if entry["habit_done"] else "❌",
            }
            for entry in history
        ])
        
        file_path = filedialog.asksaveasfilename(defaultextension=".csv",
                                               filetypes=[("CSV files", "*.csv")])
        if file_path:
            df.to_csv(file_path, index=False)
            messagebox.showinfo("Success", f"History exported to {file_path}")

    def show_about(self):
        messagebox.showinfo("About", "🎯 JEE Prep Tracker v2.0\n\n"
                           "A desktop application for JEE preparation tracking.\n\n"
                           "Features:\n"
                           "• Daily target generation\n"
                           "• Progress tracking\n"
                           "• Analytics dashboard\n"
                           "• Streak system\n"
                           "• History export\n\n"
                           "Built with ❤️ for JEE aspirants")

if __name__ == "__main__":
    app = JEETrackerApp()
    app.mainloop()
