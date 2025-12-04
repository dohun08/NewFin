import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/term_model.dart';
import '../../models/quiz_model.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'newfin.db');

    return await openDatabase(
      path,
      version: 8, // 버전 업그레이드 (챗봇 시스템 추가)
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 뉴스 테이블 제거 (더 이상 저장 안 함)
    // await db.execute('''
    //   CREATE TABLE articles(...)
    // ''');

    await db.execute('''
      CREATE TABLE terms(
        id TEXT PRIMARY KEY,
        term TEXT,
        definition TEXT,
        example TEXT,
        relatedNewsId TEXT,
        source TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE quizzes(
        id TEXT PRIMARY KEY,
        newsId TEXT,
        question TEXT,
        options TEXT,
        correctIndex INTEGER,
        explanation TEXT,
        userAnswer INTEGER,
        isCorrect INTEGER,
        attemptedAt TEXT
      )
    ''');
    
    // 읽은 뉴스 기록 테이블 (사용자 학습 기록)
    await db.execute('''
      CREATE TABLE read_news(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        newsId TEXT UNIQUE,
        title TEXT,
        url TEXT,
        readAt TEXT
      )
    ''');
    
    // 학습한 용어 기록 테이블
    await db.execute('''
      CREATE TABLE learned_terms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        term TEXT UNIQUE,
        definition TEXT,
        example TEXT,
        learnedAt TEXT
      )
    ''');
    
    // 일일 미션 테이블
    await db.execute('''
      CREATE TABLE daily_missions(
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        news_read INTEGER DEFAULT 0,
        quiz_completed INTEGER DEFAULT 0,
        login_checked INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');
    
    await db.execute('CREATE INDEX idx_mission_date ON daily_missions(date)');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 기존 articles 테이블 삭제
      await db.execute('DROP TABLE IF EXISTS articles');
      
      // 읽은 뉴스 기록 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS read_news(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          newsId TEXT UNIQUE,
          readAt TEXT
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // 학습한 용어 기록 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS learned_terms(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          term TEXT UNIQUE,
          definition TEXT,
          example TEXT,
          learnedAt TEXT
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // read_news 테이블에 title, url 컴럼 추가
      await db.execute('ALTER TABLE read_news ADD COLUMN title TEXT');
      await db.execute('ALTER TABLE read_news ADD COLUMN url TEXT');
    }
    
    if (oldVersion < 5) {
      // 일일 미션 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_missions(
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL UNIQUE,
          news_read INTEGER DEFAULT 0,
          quiz_completed INTEGER DEFAULT 0,
          login_checked INTEGER DEFAULT 0,
          created_at TEXT
        )
      ''');
      
      await db.execute('CREATE INDEX IF NOT EXISTS idx_mission_date ON daily_missions(date)');
    }
    
    if (oldVersion < 6) {
      // 코인 거래 내역 테이블
      await db.execute('''
        CREATE TABLE IF NOT EXISTS coin_transactions(
          id TEXT PRIMARY KEY,
          amount INTEGER NOT NULL,
          type TEXT NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      
      // 투자 기록 테이블
      await db.execute('''
        CREATE TABLE IF NOT EXISTS investments(
          id TEXT PRIMARY KEY,
          investment_type TEXT NOT NULL,
          symbol TEXT NOT NULL,
          buy_price REAL NOT NULL,
          buy_amount REAL NOT NULL,
          buy_coin_amount INTEGER NOT NULL,
          buy_date TEXT NOT NULL,
          sell_price REAL,
          sell_coin_amount INTEGER,
          sell_date TEXT,
          status TEXT NOT NULL
        )
      ''');
      
      // 포트폴리오 테이블
      await db.execute('''
        CREATE TABLE IF NOT EXISTS portfolio(
          id INTEGER PRIMARY KEY,
          total_coins INTEGER DEFAULT 0,
          invested_amount INTEGER DEFAULT 0,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // 초기 코인 지급 (1000 NC)
      await db.insert('portfolio', {
        'id': 1,
        'total_coins': 1000,
        'invested_amount': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      await db.insert('coin_transactions', {
        'id': 'welcome-bonus',
        'amount': 1000,
        'type': 'earn',
        'description': '🎉 환영 보너스',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    
    if (oldVersion < 7) {
      // 주식 테이블
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stocks(
          symbol TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          current_price INTEGER NOT NULL,
          previous_close INTEGER NOT NULL,
          change_rate REAL NOT NULL,
          volume INTEGER NOT NULL,
          last_updated TEXT NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 8) {
      // 채팅 메시지 테이블
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chat_messages(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER,
          role TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          feedback INTEGER DEFAULT 0
        )
      ''');
      
      // 채팅 세션 테이블
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chat_sessions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time INTEGER NOT NULL,
          end_time INTEGER,
          message_count INTEGER DEFAULT 0
        )
      ''');
      
      // 인덱스 생성
      await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_session ON chat_messages(session_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_chat_timestamp ON chat_messages(timestamp DESC)');
      
      // 초기 세션 및 환영 메시지 생성
      final sessionId = await db.insert('chat_sessions', {
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'message_count': 1,
      });
      
      await db.insert('chat_messages', {
        'session_id': sessionId,
        'role': 'assistant',
        'content': '안녕! 나는 벤틀리야 🐻\n금융이 어렵다고? 걱정 마! 뭐든 물어봐! 😊',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Article Operations (제거됨 - 뉴스는 DB에 저장하지 않음)
  // 읽은 뉴스 기록만 관리
  
  Future<void> markNewsAsRead(String newsId, {String? title, String? url}) async {
    final db = await database;
    await db.insert(
      'read_news',
      {
        'newsId': newsId,
        'title': title,
        'url': url,
        'readAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<String>> getReadNewsIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('read_news');
    return maps.map((map) => map['newsId'] as String).toList();
  }
  
  Future<List<Map<String, dynamic>>> getReadNewsWithTime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'read_news',
      orderBy: 'readAt DESC',
    );
    return maps;
  }
  
  Future<int> getReadNewsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM read_news');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Learned Terms Operations
  Future<void> saveLearnedTerm(String term, String definition, String example) async {
    final db = await database;
    await db.insert(
      'learned_terms',
      {
        'term': term,
        'definition': definition,
        'example': example,
        'learnedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Map<String, dynamic>>> getLearnedTerms() async {
    final db = await database;
    return await db.query(
      'learned_terms',
      orderBy: 'learnedAt DESC',
    );
  }
  
  Future<int> getLearnedTermsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM learned_terms');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  // Daily Mission Operations
  Future<Map<String, dynamic>?> getTodayMission() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;
    
    final List<Map<String, dynamic>> result = await db.query(
      'daily_missions',
      where: 'date = ?',
      whereArgs: [today],
    );
    
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<void> createTodayMission(String id) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;
    
    await db.insert(
      'daily_missions',
      {
        'id': id,
        'date': today,
        'news_read': 0,
        'quiz_completed': 0,
        'login_checked': 1, // 앱 실행 시 자동 체크
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
  
  Future<void> updateMissionNewsRead(bool completed) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;
    
    await db.update(
      'daily_missions',
      {'news_read': completed ? 1 : 0},
      where: 'date = ?',
      whereArgs: [today],
    );
  }
  
  Future<void> updateMissionQuizCompleted(bool completed) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T').first;
    
    await db.update(
      'daily_missions',
      {'quiz_completed': completed ? 1 : 0},
      where: 'date = ?',
      whereArgs: [today],
    );
  }
  
  Future<List<Map<String, dynamic>>> getRecentMissions(int days) async {
    final db = await database;
    
    return await db.query(
      'daily_missions',
      orderBy: 'date DESC',
      limit: days,
    );
  }
  
  Future<List<Map<String, dynamic>>> getAllMissions() async {
    final db = await database;
    
    return await db.query(
      'daily_missions',
      orderBy: 'date ASC',
    );
  }

  // Term Operations
  Future<void> insertTerm(TermModel term) async {
    final db = await database;
    await db.insert('terms', term.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<TermModel?> getTerm(String term) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'terms',
      where: 'term = ?',
      whereArgs: [term],
    );
    if (maps.isNotEmpty) {
      return TermModel.fromJson(maps.first);
    }
    return null;
  }

  // Quiz Operations


  Future<void> insertQuizzes(List<QuizModel> quizzes) async {
    final db = await database;
    final batch = db.batch();
    for (var quiz in quizzes) {
      batch.insert(
        'quizzes',
        {
          ...quiz.toJson(),
          'options': jsonEncode(quiz.options),
          'isCorrect': quiz.isCorrect == null ? null : (quiz.isCorrect! ? 1 : 0),
          'attemptedAt': quiz.attemptedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<QuizModel>> getQuizzesByNewsId(String newsId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quizzes',
      where: 'newsId = ?',
      whereArgs: [newsId],
    );
    
    return maps.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);
      mutableMap['options'] = List<String>.from(jsonDecode(mutableMap['options']));
      mutableMap['isCorrect'] = mutableMap['isCorrect'] == null ? null : mutableMap['isCorrect'] == 1;
      return QuizModel.fromJson(mutableMap);
    }).toList();
  }

  // 시도한 퀴즈 기록 조회 (최신순)
  Future<List<Map<String, dynamic>>> getAttemptedQuizzes() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'quizzes',
      where: 'attemptedAt IS NOT NULL',
      orderBy: 'attemptedAt DESC',
    );
    
    return results.map((map) {
      final mutableMap = Map<String, dynamic>.from(map);
      mutableMap['options'] = List<String>.from(jsonDecode(mutableMap['options']));
      mutableMap['isCorrect'] = mutableMap['isCorrect'] == null ? null : mutableMap['isCorrect'] == 1;
      return mutableMap;
    }).toList();
  }

  // 퀴즈 통계 조회
  Future<Map<String, int>> getQuizStats() async {
    final db = await database;
    final attempted = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quizzes WHERE attemptedAt IS NOT NULL'
    );
    final correct = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quizzes WHERE isCorrect = 1'
    );
    
    return {
      'attempted': attempted.first['count'] as int,
      'correct': correct.first['count'] as int,
    };
  }
}

