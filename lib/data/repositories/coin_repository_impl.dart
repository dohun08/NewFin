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

    final portfolio = await getPortfolio();
    if (portfolio.availableCoins < amount) {
      throw Exception('사용 가능한 코인이 부족합니다.');
    }

    final db = await _dbHelper.database;

    // total_coins 감소 및 invested_amount 증가
    await db.update('portfolio', {
      'total_coins': portfolio.totalCoins - amount,
      'invested_amount': portfolio.investedAmount + amount,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');

    // 거래 내역 추가 (투자)
    await _addTransaction(amount, 'spend', '💼 투자: $investmentId');
  }

  @override
  Future<void> retrieveInvestment({
    required int amount,
    required String investmentId,
  }) async {
    if (amount <= 0) return;

    final portfolio = await getPortfolio();
    final db = await _dbHelper.database;

    // total_coins 증가, invested_amount 감소
    await db.update('portfolio', {
      'total_coins': portfolio.totalCoins + amount,
      'invested_amount': portfolio.investedAmount - amount,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: '1=1');

    // 거래 내역 추가 (투자 회수)
    await _addTransaction(amount, 'earn', '💰 투자 회수: $investmentId');
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
