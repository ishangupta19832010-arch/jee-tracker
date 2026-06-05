import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

void main() {
  runApp(const JEETrackerApp());
}

class JEETrackerApp extends StatelessWidget {
  const JEETrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JEE Prep Tracker',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF6B35),
        scaffoldBackgroundColor: const Color(0xFF0E1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF161B22),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFFC9D1D9), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFFC9D1D9), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFC9D1D9)),
          bodyMedium: TextStyle(color: Color(0xFFC9D1D9)),
        ),
      ),
      home: const JEETrackerHome(),
    );
  }
}

class JEETrackerHome extends StatefulWidget {
  const JEETrackerHome({Key? key}) : super(key: key);

  @override
  State<JEETrackerHome> createState() => _JEETrackerHomeState();
}

class _JEETrackerHomeState extends State<JEETrackerHome> {
  int _selectedIndex = 0;
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _dbHelper.initDatabase();
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DailyTrackerPage(dbHelper: _dbHelper),
      AnalyticsPage(dbHelper: _dbHelper),
      CustomTopicsPage(dbHelper: _dbHelper),
      HistoryPage(dbHelper: _dbHelper),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 JEE Prep Tracker'),
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: const Color(0xFF888888),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Topics'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// ===== DATABASE HELPER =====
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'jee_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_targets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        physics TEXT NOT NULL,
        chemistry TEXT NOT NULL,
        mathematics TEXT NOT NULL,
        habit TEXT NOT NULL,
        difficulty TEXT DEFAULT 'Intermediate'
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_completion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        physics_done INTEGER DEFAULT 0,
        chemistry_done INTEGER DEFAULT 0,
        mathematics_done INTEGER DEFAULT 0,
        habit_done INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        difficulty_level TEXT DEFAULT 'Intermediate',
        custom_topics TEXT DEFAULT '{}'
      )
    ''');
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<void> saveDailyTarget(String date, String physics, String chemistry, String mathematics, String habit, String difficulty) async {
    final db = await database;
    await db.insert(
      'daily_targets',
      {
        'date': date,
        'physics': physics,
        'chemistry': chemistry,
        'mathematics': mathematics,
        'habit': habit,
        'difficulty': difficulty,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>?> getDailyTarget(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_targets',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isNotEmpty) {
      return {
        'Physics': result[0]['physics'] as String,
        'Chemistry': result[0]['chemistry'] as String,
        'Mathematics': result[0]['mathematics'] as String,
        'Habit': result[0]['habit'] as String,
      };
    }
    return null;
  }

  Future<void> saveCompletion(String date, bool physics, bool chemistry, bool mathematics, bool habit) async {
    final db = await database;
    await db.insert(
      'daily_completion',
      {
        'date': date,
        'physics_done': physics ? 1 : 0,
        'chemistry_done': chemistry ? 1 : 0,
        'mathematics_done': mathematics ? 1 : 0,
        'habit_done': habit ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, bool>> getCompletion(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_completion',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isNotEmpty) {
      return {
        'physics': (result[0]['physics_done'] as int) == 1,
        'chemistry': (result[0]['chemistry_done'] as int) == 1,
        'mathematics': (result[0]['mathematics_done'] as int) == 1,
        'habit': (result[0]['habit_done'] as int) == 1,
      };
    }
    return {'physics': false, 'chemistry': false, 'mathematics': false, 'habit': false};
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final db = await database;
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 6));

    final result = await db.rawQuery('''
      SELECT 
        date,
        physics_done,
        chemistry_done,
        mathematics_done,
        habit_done
      FROM daily_completion
      WHERE date BETWEEN ? AND ?
      ORDER BY date ASC
    ''', [
      DateFormat('yyyy-MM-dd').format(startDate),
      DateFormat('yyyy-MM-dd').format(endDate),
    ]);

    return result;
  }

  Future<int> getStreak() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT date FROM daily_completion 
      WHERE physics_done = 1 AND chemistry_done = 1 AND mathematics_done = 1 AND habit_done = 1
      ORDER BY date DESC
    ''');

    if (result.isEmpty) return 0;

    int streak = 1;
    for (int i = 0; i < result.length - 1; i++) {
      DateTime date1 = DateTime.parse(result[i]['date'].toString());
      DateTime date2 = DateTime.parse(result[i + 1]['date'].toString());
      if (date1.difference(date2).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> updateDifficulty(String difficulty) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {'id': 1, 'difficulty_level': difficulty},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getDifficulty() async {
    final db = await database;
    final result = await db.query('user_settings', where: 'id = 1');
    return result.isNotEmpty ? result[0]['difficulty_level'] as String : 'Intermediate';
  }

  Future<List<Map<String, dynamic>>> getAllHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        t.date, t.physics, t.chemistry, t.mathematics, t.habit,
        c.physics_done, c.chemistry_done, c.mathematics_done, c.habit_done
      FROM daily_targets t
      LEFT JOIN daily_completion c ON t.date = c.date
      ORDER BY t.date DESC
    ''');
  }
}

// ===== TOPICS DATABASE =====
class TopicsDatabase {
  static final Map<String, Map<String, List<String>>> database = {
    'Beginner': {
      'Physics': [
        'Mechanics (Basic Motion & Forces)',
        'Simple Harmonic Motion',
        'Heat & Temperature',
        'Sound Waves Basics',
        'Electricity Fundamentals',
        'Magnetism Basics',
        'Geometrical Optics'
      ],
      'Chemistry': [
        'Atomic Structure Basics',
        'Chemical Reactions & Equations',
        'Stoichiometry',
        'States of Matter',
        'Thermochemistry Basics',
        'Redox Reactions',
        'Periodic Table & Periodic Properties'
      ],
      'Mathematics': [
        'Sets & Relations',
        'Polynomial & Quadratic Equations',
        'Sequences & Series',
        'Permutation & Combination',
        'Basic Trigonometry',
        'Straight Lines',
        'Circles'
      ],
    },
    'Intermediate': {
      'Physics': [
        'Mechanics (Rotational Motion & Kinematics)',
        'Electrodynamics (Gauss Law & Capacitor circuits)',
        'Modern Physics (Dual Nature & Nuclear Physics)',
        'Optics (Wave Optics & Interference)',
        'Thermodynamics & KTG',
        'Current Electricity & Kirchhoff\'s Laws',
        'Magnetic Effects of Current'
      ],
      'Chemistry': [
        'Organic: Reaction Mechanisms & Named Reactions',
        'Organic: Biomolecules & Polymers',
        'Inorganic: Coordination Compounds',
        'Inorganic: Chemical Bonding & MOT',
        'Physical: Chemical & Ionic Equilibrium',
        'Physical: Electrochemistry & Nernst Equation',
        'Physical: Liquid Solutions'
      ],
      'Mathematics': [
        'Calculus: Definite Integration & AUC',
        'Calculus: Limits, Continuity & Differentiability',
        'Algebra: Matrices & Determinants',
        'Algebra: Probability & PnC',
        'Coordinate Geometry: Conic Sections',
        'Vector & 3D Geometry',
        'Trigonometry: Inverse Trigonometric Functions'
      ],
    },
    'Advanced': {
      'Physics': [
        'Advanced Rotational Dynamics & Angular Momentum',
        'Gauss Law Applications & Complex Capacitor Networks',
        'Quantum Mechanics & Schrodinger Equation',
        'Diffraction & Polarization Advanced Topics',
        'Thermodynamic Cycles & Real Gas Behavior',
        'Electromagnetic Induction & AC Circuits',
        'Relativity & Photoelectric Effect'
      ],
      'Chemistry': [
        'Organic Synthesis Strategy & Multi-step Reactions',
        'Organic Stereochemistry & Mechanisms Deep Dive',
        'Transition Metals & Complex Ion Chemistry',
        'Molecular Orbital Theory & Chemical Bonding',
        'Electrochemistry: Galvanic & Electrolytic Cells',
        'Kinetics & Reaction Rate Theory',
        'Thermodynamics & Gibbs Free Energy'
      ],
      'Mathematics': [
        'Calculus: Differential Equations & Applications',
        'Calculus: Taylor Series & Convergence',
        'Algebra: Groups & Rings (Advanced)',
        'Probability: Bayes Theorem & Distributions',
        'Coordinate Geometry: 3D Conic Sections',
        'Vector: Cross Product & Applications',
        'Complex Analysis & De Moivre\'s Theorem'
      ],
    }
  };

  static final Map<String, List<String>> habits = {
    'Beginner': [
      'Solve 5 easy PYQs under a 30-minute timer.',
      'Review notes for one topic and make flashcards.',
      'Solve 3 basic multiple-choice questions from any subject.',
      'Watch a 20-minute concept video and summarize it.'
    ],
    'Intermediate': [
      'Solve 15 PYQs under a strict 45-minute timer.',
      'Review your \'Mistake Book\' and re-solve 5 previously failed questions.',
      'Take a 1-hour chapter mock test and analyze weak concepts.',
      'Formula Sprint: Write all formulas of 3 random chapters from memory.'
    ],
    'Advanced': [
      'Solve 20 advanced PYQs under 50-minute timer with full analysis.',
      'Deep-dive revision: Review 3 weak topics and solve their toughest problems.',
      'Take a full 3-hour mock test and create detailed error analysis.',
      'Create original problems from 2 chapters and solve them perfectly.'
    ]
  };
}

// ===== DAILY TRACKER PAGE =====
class DailyTrackerPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const DailyTrackerPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<DailyTrackerPage> createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  String _difficulty = 'Intermediate';
  Map<String, String>? _currentChart;
  Map<String, bool> _completion = {'physics': false, 'chemistry': false, 'mathematics': false, 'habit': false};
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _difficulty = await widget.dbHelper.getDifficulty();
    _streak = await widget.dbHelper.getStreak();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _currentChart = await widget.dbHelper.getDailyTarget(today);
    _completion = await widget.dbHelper.getCompletion(today);
    setState(() {});
  }

  Future<void> _generateNewChart() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> history = await widget.dbHelper.getAllHistory();
    
    Map<String, String> lastChart = {};
    if (history.isNotEmpty && history[0]['date'] != today) {
      lastChart = {
        'Physics': history[0]['physics'],
        'Chemistry': history[0]['chemistry'],
        'Mathematics': history[0]['mathematics'],
        'Habit': history[0]['habit'],
      };
    }

    final database = TopicsDatabase.database[_difficulty]!;
    final habitsMap = TopicsDatabase.habits[_difficulty]!;
    final random = Random();

    Map<String, String> newChart = {};
    for (String subject in ['Physics', 'Chemistry', 'Mathematics']) {
      List<String> topics = database[subject]!;
      List<String> allowed = topics.where((t) => t != lastChart[subject]).toList();
      newChart[subject] = allowed.isNotEmpty ? allowed[random.nextInt(allowed.length)] : topics[random.nextInt(topics.length)];
    }

    List<String> allowedHabits = habitsMap.where((h) => h != lastChart['Habit']).toList();
    newChart['Habit'] = allowedHabits.isNotEmpty ? allowedHabits[random.nextInt(allowedHabits.length)] : habitsMap[random.nextInt(habitsMap.length)];

    await widget.dbHelper.saveDailyTarget(today, newChart['Physics']!, newChart['Chemistry']!, newChart['Mathematics']!, newChart['Habit']!, _difficulty);

    setState(() {
      _currentChart = newChart;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ New chart generated!')));
  }

  Future<void> _updateCompletion() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await widget.dbHelper.saveCompletion(today, _completion['physics']!, _completion['chemistry']!, _completion['mathematics']!, _completion['habit']!);
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    int completed = (_completion['physics']! ? 1 : 0) + (_completion['chemistry']! ? 1 : 0) + (_completion['mathematics']! ? 1 : 0) + (_completion['habit']! ? 1 : 0);
    double progress = completed / 4;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📅 $today', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Difficulty: $_difficulty', style: const TextStyle(color: Color(0xFFFF6B35))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('🔥 Streak', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('$_streak days', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateNewChart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('🔄 Generate Today\'s Chart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            if (_currentChart != null) ...[
              _buildSubjectCard('🔬 Physics', _currentChart!['Physics']!, 'physics'),
              const SizedBox(height: 12),
              _buildSubjectCard('⚗️ Chemistry', _currentChart!['Chemistry']!, 'chemistry'),
              const SizedBox(height: 12),
              _buildSubjectCard('📐 Mathematics', _currentChart!['Mathematics']!, 'mathematics'),
              const SizedBox(height: 12),
              _buildSubjectCard('⭐ Habit', _currentChart!['Habit']!, 'habit'),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1f1f1f),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                ),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF333333),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Progress: $completed/4', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                      ],
                    ),
                  ],
                ),
              ),
              if (completed == 4)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1f3a1f),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FF00), width: 2),
                    ),
                    child: const Text(
                      '🔥 Outstanding! Day complete. You are outworking your competition!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ] else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1f1f1f),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('👆 Click the button above to generate your target chart for the day.', textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String title, String topic, String subject) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(topic, style: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB))),
                ],
              ),
            ),
            Checkbox(
              value: _completion[subject] ?? false,
              onChanged: (value) {
                setState(() {
                  _completion[subject] = value ?? false;
                });
                _updateCompletion();
              },
              activeColor: const Color(0xFFFF6B35),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== ANALYTICS PAGE =====
class AnalyticsPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const AnalyticsPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Future<List<Map<String, dynamic>>> _statsFuture;
  late Future<int> _streakFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = widget.dbHelper.getWeeklyStats();
    _streakFuture = widget.dbHelper.getStreak();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _statsFuture = widget.dbHelper.getWeeklyStats();
          _streakFuture = widget.dbHelper.getStreak();
        });
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<int>(
              future: _streakFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCard('Days This Week', '7', Colors.blue),
                    _buildMetricCard('Current Streak', '${snapshot.data} days', Colors.amber),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                
                List<Map<String, dynamic>> stats = snapshot.data!;
                int completedDays = stats.where((s) => (s['physics_done'] as int) == 1 && (s['chemistry_done'] as int) == 1 && (s['mathematics_done'] as int) == 1 && (s['habit_done'] as int) == 1).length;
                int totalTasks = stats.length * 4;
                int tasksDone = stats.fold(0, (sum, s) => sum + (s['physics_done'] as int) + (s['chemistry_done'] as int) + (s['mathematics_done'] as int) + (s['habit_done'] as int));

                return Column(
                  children: [
                    _buildMetricCard('Completed Days', '$completedDays/${stats.length}', Colors.green),
                    const SizedBox(height: 16),
                    _buildMetricCard('Tasks Done', '$tasksDone/$totalTasks', Colors.orange),
                    const SizedBox(height: 24),
                    Text('📊 Weekly Breakdown', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    ...stats.map((stat) {
                      int completed = (stat['physics_done'] as int) + (stat['chemistry_done'] as int) + (stat['mathematics_done'] as int) + (stat['habit_done'] as int);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(stat['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                LinearProgressIndicator(
                                  value: completed / 4,
                                  minWidth: 150,
                                  backgroundColor: const Color(0xFF333333),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                ),
                                Text('$completed/4', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== CUSTOM TOPICS PAGE =====
class CustomTopicsPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const CustomTopicsPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<CustomTopicsPage> createState() => _CustomTopicsPageState();
}

class _CustomTopicsPageState extends State<CustomTopicsPage> {
  String _selectedSubject = 'Physics';
  final TextEditingController _topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('⭐ Add Custom Topics', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            DropdownButton<String>(
              value: _selectedSubject,
              isExpanded: true,
              items: ['Physics', 'Chemistry', 'Mathematics'].map((subject) {
                return DropdownMenuItem(value: subject, child: Text(subject));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Enter topic name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_topicController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Added \'${_topicController.text}\' to $_selectedSubject!')),
                    );
                    _topicController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
                child: const Text('➕ Add Topic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
            Text('📋 Your Custom Topics', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: ['Physics', 'Chemistry', 'Mathematics'].map((subject) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text('$subject: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('No custom topics yet', style: TextStyle(color: Color(0xFFBBBBBB))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== HISTORY PAGE =====
class HistoryPage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const HistoryPage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = widget.dbHelper.getAllHistory();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _historyFuture = widget.dbHelper.getAllHistory();
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('📋 Complete History', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('📊 No history yet. Start generating targets!'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final entry = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry['date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Row(
                                    children: [
                                      Text((entry['physics_done'] as int) == 1 ? '✅' : '❌'),
                                      const SizedBox(width: 8),
                                      Text((entry['chemistry_done'] as int) == 1 ? '✅' : '❌'),
                                      const SizedBox(width: 8),
                                      Text((entry['mathematics_done'] as int) == 1 ? '✅' : '❌'),
                                      const SizedBox(width: 8),
                                      Text((entry['habit_done'] as int) == 1 ? '✅' : '❌'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('🔬 ${entry['physics']}', style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
                              Text('⚗️ ${entry['chemistry']}', style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
                              Text('📐 ${entry['mathematics']}', style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
                              Text('⭐ ${entry['habit']}', style: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
