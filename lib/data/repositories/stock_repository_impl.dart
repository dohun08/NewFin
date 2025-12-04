import 'dart:math';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/stock_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/stock_model.dart';
import '../models/investment_model.dart';

class StockRepositoryImpl implements StockRepository {
  final DatabaseHelper _dbHelper;
  final Random _random = Random();

  // 기본 주식 목록 (한국 대표 기업)
  final List<Map<String, dynamic>> _initialStocks = [
    {'symbol': 'SAMSUNG', 'name': '삼성전자', 'basePrice': 1000},
    {'symbol': 'LG', 'name': 'LG전자', 'basePrice': 800},
    {'symbol': 'SK', 'name': 'SK하이닉스', 'basePrice': 1200},
    {'symbol': 'HYUNDAI', 'name': '현대차', 'basePrice': 900},
    {'symbol': 'NAVER', 'name': '네이버', 'basePrice': 1500},
    {'symbol': 'KAKAO', 'name': '카카오', 'basePrice': 700},
    {'symbol': 'KB', 'name': 'KB금융', 'basePrice': 600},
    {'symbol': 'SAMSUNG_BIO', 'name': '삼성바이오로직스', 'basePrice': 2000},
  ];

  StockRepositoryImpl(this._dbHelper);

  @override
  Future<List<StockModel>> getStocks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query('stocks');

    if (results.isEmpty) {
      // 초기 주식 데이터 생성
      await _initializeStocks();
      return await getStocks();
    }

    return results.map((json) => StockModel.fromJson(json)).toList();
  }

  Future<void> _initializeStocks() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    for (var stock in _initialStocks) {
      final basePrice = stock['basePrice'] as int;
      final randomVariation = _random.nextInt(200) - 100; // -100 ~ +100
      final currentPrice = basePrice + randomVariation;

      await db.insert('stocks', {
        'symbol': stock['symbol'],
        'name': stock['name'],
        'current_price': currentPrice,
        'previous_close': currentPrice,
        'change_rate': 0.0,
        'volume': _random.nextInt(100000) + 10000,
        'last_updated': now.toIso8601String(),
      });
    }
  }

  @override
  Future<StockModel> getStock(String symbol) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'stocks',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );

    if (results.isEmpty) {
      throw Exception('주식을 찾을 수 없습니다: $symbol');
    }

    return StockModel.fromJson(results.first);
  }

  @override
  Future<void> updateDailyPrices() async {
    final db = await _dbHelper.database;
    final stocks = await getStocks();
    final now = DateTime.now();

    for (var stock in stocks) {
      // 뉴스 기반 변동: -5% ~ +5% 사이 랜덤
      final changePercent = (_random.nextDouble() * 10) - 5;
      final priceChange = (stock.currentPrice * changePercent / 100).round();
      final newPrice = stock.currentPrice + priceChange;

      await db.update(
        'stocks',
        {
          'previous_close': stock.currentPrice,
          'current_price': newPrice,
          'change_rate': changePercent,
          'volume': _random.nextInt(100000) + 10000,
          'last_updated': now.toIso8601String(),
        },
        where: 'symbol = ?',
        whereArgs: [stock.symbol],
      );
    }
  }

  @override
  Future<InvestmentModel> buyStock({
    required String symbol,
    required int quantity,
    required int totalCoinAmount,
  }) async {
    final db = await _dbHelper.database;
    const uuid = Uuid();

    final stock = await getStock(symbol);
    final buyPrice = stock.currentPrice.toDouble();

    final investmentId = uuid.v4();

    await db.insert('investments', {
      'id': investmentId,
      'investment_type': 'stock',
      'symbol': symbol,
      'buy_price': buyPrice,
      'buy_amount': quantity.toDouble(),
      'buy_coin_amount': totalCoinAmount,
      'buy_date': DateTime.now().toIso8601String(),
      'status': 'holding',
    });

    return InvestmentModel(
      id: investmentId,
      investmentType: InvestmentType.stock,
      symbol: symbol,
      buyPrice: buyPrice,
      buyAmount: quantity.toDouble(),
      buyCoinAmount: totalCoinAmount,
      buyDate: DateTime.now(),
      status: InvestmentStatus.holding,
    );
  }

  @override
  Future<void> sellStock(String investmentId) async {
    final db = await _dbHelper.database;
    final investment = await getInvestment(investmentId);

    if (investment == null) {
      throw Exception('투자 정보를 찾을 수 없습니다');
    }

    final stock = await getStock(investment.symbol);
    final sellPrice = stock.currentPrice.toDouble();
    final sellCoinAmount = (investment.buyAmount * sellPrice).round();

    await db.update(
      'investments',
      {
        'sell_price': sellPrice,
        'sell_coin_amount': sellCoinAmount,
        'sell_date': DateTime.now().toIso8601String(),
        'status': 'sold',
      },
      where: 'id = ?',
      whereArgs: [investmentId],
    );
  }

  @override
  Future<List<InvestmentModel>> getMyInvestments() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'investments',
      where: 'investment_type = ? AND status = ?',
      whereArgs: ['stock', 'holding'],
      orderBy: 'buy_date DESC',
    );

    return results.map((json) {
      return InvestmentModel(
        id: json['id'] as String,
        investmentType: InvestmentType.stock,
        symbol: json['symbol'] as String,
        buyPrice: (json['buy_price'] as num).toDouble(),
        buyAmount: (json['buy_amount'] as num).toDouble(),
        buyCoinAmount: (json['buy_coin_amount'] as num).toInt(),
        buyDate: DateTime.parse(json['buy_date'] as String),
        sellPrice: json['sell_price'] != null ? (json['sell_price'] as num).toDouble() : null,
        sellCoinAmount: json['sell_coin_amount'] != null ? (json['sell_coin_amount'] as num).toInt() : null,
        sellDate: json['sell_date'] != null
            ? DateTime.parse(json['sell_date'] as String)
            : null,
        status: json['status'] == 'holding'
            ? InvestmentStatus.holding
            : InvestmentStatus.sold,
      );
    }).toList();
  }

  @override
  Future<InvestmentModel?> getInvestment(String id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'investments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

    final json = results.first;
    return InvestmentModel(
      id: json['id'] as String,
      investmentType: InvestmentType.stock,
      symbol: json['symbol'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      buyAmount: (json['buy_amount'] as num).toDouble(),
      buyCoinAmount: (json['buy_coin_amount'] as num).toInt(),
      buyDate: DateTime.parse(json['buy_date'] as String),
      sellPrice: json['sell_price'] != null ? (json['sell_price'] as num).toDouble() : null,
      sellCoinAmount: json['sell_coin_amount'] != null ? (json['sell_coin_amount'] as num).toInt() : null,
      sellDate: json['sell_date'] != null
          ? DateTime.parse(json['sell_date'] as String)
          : null,
      status: json['status'] == 'holding'
          ? InvestmentStatus.holding
          : InvestmentStatus.sold,
    );
  }
}
