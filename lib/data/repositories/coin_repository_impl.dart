import 'package:uuid/uuid.dart';

import '../../domain/repositories/coin_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/coin_transaction_model.dart';
import '../models/portfolio_model.dart';

class CoinRepositoryImpl implements CoinRepository {
  final DatabaseHelper _dbHelper;

  CoinRepositoryImpl(this._dbHelper);

  @override
  Future<int> getTotalCoins() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'portfolio',
      columns: ['total_coins'],
      limit: 1,
    );

    if (result.isEmpty) {
      // 포트폴리오가 없으면 초기화 (1000 NC 지급)
      await db.insert('portfolio', {
        'total_coins': 1000,
        'invested_amount': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await _addTransaction(1000, 'earn', '🎉 환영 보너스');
      return 1000;
    }

    return result.first['total_coins'] as int;
  }

  @override
  Future<PortfolioModel> getPortfolio() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'portfolio',
      limit: 1,
    );

    if (result.isEmpty) {
      // 포트폴리오가 없으면 초기화
      await db.insert('portfolio', {
        'total_coins': 1000,
        'invested_amount': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await _addTransaction(1000, 'earn', '🎉 환영 보너스');

      return PortfolioModel(
        totalCoins: 1000,
        investedAmount: 0,
        updatedAt: DateTime.now(),
      );
    }

    final data = result.first;
    return PortfolioModel(
      totalCoins: (data['total_coins'] as int?) ?? 0,
      investedAmount: (data['invested_amount'] as int?) ?? 0,
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  @override
  Future<void> addCoins({
    required int amount,
    required String description,
  }) async {
    if (amount <= 0) return;

    final db = await _dbHelper.database;
    final currentCoins = await getTotalCoins();
    final newTotal = currentCoins + amount;

    await db.update('portfolio', {
      'total_coins': newTotal,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');

    await _addTransaction(amount, 'earn', description);
  }

  @override
  Future<bool> spendCoins({
    required int amount,
    required String description,
  }) async {
    if (amount <= 0) return false;

    final portfolio = await getPortfolio();
    if (portfolio.availableCoins < amount) {
      return false; // 잔액 부족
    }

    final db = await _dbHelper.database;
    final newTotal = portfolio.totalCoins - amount;

    await db.update('portfolio', {
      'total_coins': newTotal,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');

    await _addTransaction(amount, 'spend', description);
    return true;
  }

  @override
  Future<List<CoinTransactionModel>> getCoinHistory({int? limit}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'coin_transactions',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map((json) {
      return CoinTransactionModel(
        id: json['id'] as String,
        amount: json['amount'] as int,
        type: json['type'] as String,
        description: json['description'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> investCoins({
    required int amount,
    required String investmentId,
  }) async {
    if (amount <= 0) return;

    print('💼 투자 시작: ${amount}NC');

    final portfolio = await getPortfolio();
    print('📊 현재 포트폴리오: total=${portfolio.totalCoins}, invested=${portfolio.investedAmount}');
    
    if (portfolio.availableCoins < amount) {
      print('❌ 잔액 부족: 사용가능=${portfolio.availableCoins}, 필요=${amount}');
      throw Exception('사용 가능한 코인이 부족합니다.');
    }

    final db = await _dbHelper.database;

    // total_coins 감소 및 invested_amount 증가
    final newTotal = portfolio.totalCoins - amount;
    final newInvested = portfolio.investedAmount + amount;
    
    print('🔄 업데이트 예정: total=$newTotal, invested=$newInvested');
    
    await db.update('portfolio', {
      'total_coins': newTotal,
      'invested_amount': newInvested,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');

    // 거래 내역 추가 (투자)
    await _addTransaction(amount, 'spend', '💼 투자: $investmentId');
    
    // 업데이트 후 확인
    final afterPortfolio = await getPortfolio();
    print('✅ 투자 완료: total=${afterPortfolio.totalCoins}, invested=${afterPortfolio.investedAmount}');
  }

  @override
  Future<void> retrieveInvestment({
    required int amount,
    required String investmentId,
  }) async {
    if (amount <= 0) return;

    print('💰 투자 회수 시작: ${amount}NC');

    final portfolio = await getPortfolio();
    print('📊 현재 포트폴리오: total=${portfolio.totalCoins}, invested=${portfolio.investedAmount}');
    
    final db = await _dbHelper.database;

    // total_coins 증가, invested_amount 감소
    final newTotal = portfolio.totalCoins + amount;
    final newInvested = portfolio.investedAmount - amount;
    
    print('🔄 업데이트 예정: total=$newTotal, invested=$newInvested');
    
    await db.update('portfolio', {
      'total_coins': newTotal,
      'invested_amount': newInvested,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');

    // 거래 내역 추가 (투자 회수)
    await _addTransaction(amount, 'earn', '💰 투자 회수: $investmentId');
    
    // 업데이트 후 확인
    final afterPortfolio = await getPortfolio();
    print('✅ 회수 완료: total=${afterPortfolio.totalCoins}, invested=${afterPortfolio.investedAmount}');
  }

  /// 코인 초기화 (디버깅용)
  Future<void> resetCoins({int amount = 1000}) async {
    final db = await _dbHelper.database;
    
    print('🔄 코인 초기화 시작: ${amount}NC');
    
    // 기존 데이터 확인
    final before = await db.query('portfolio', limit: 1);
    print('📊 초기화 전: ${before.isNotEmpty ? before.first : "데이터 없음"}');
    
    // 모든 투자 취소
    await db.delete('investments');
    
    // 포트폴리오 초기화
    final count = await db.update('portfolio', {
      'total_coins': amount,
      'invested_amount': 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');
    
    print('📝 업데이트된 행 수: $count');
    
    // 업데이트 후 데이터 확인
    final after = await db.query('portfolio', limit: 1);
    print('📊 초기화 후: ${after.isNotEmpty ? after.first : "데이터 없음"}');
    
    print('✅ 코인 초기화 완료: ${amount}NC');
  }

  /// 거래 내역 추가 (내부 메서드)
  Future<void> _addTransaction(
    int amount,
    String type,
    String description,
  ) async {
    final db = await _dbHelper.database;
    const uuid = Uuid();

    await db.insert('coin_transactions', {
      'id': uuid.v4(),
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
