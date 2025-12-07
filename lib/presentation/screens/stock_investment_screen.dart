import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/repositories/stock_repository.dart';
import '../providers/coin_provider.dart';
import '../../data/models/stock_model.dart';

// Providers
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepositoryImpl(DatabaseHelper());
});

final stocksProvider = FutureProvider.autoDispose<List<StockModel>>((
  ref,
) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getStocks();
});

final myInvestmentsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.read(stockRepositoryProvider);
  return await repository.getMyInvestments();
});

class StockInvestmentScreen extends ConsumerStatefulWidget {
  const StockInvestmentScreen({super.key});

  @override
  ConsumerState<StockInvestmentScreen> createState() =>
      _StockInvestmentScreenState();
}

class _StockInvestmentScreenState extends ConsumerState<StockInvestmentScreen> {
  Timer? _priceUpdateTimer;

  @override
  void initState() {
    super.initState();
    _checkAndUpdatePrices();
    _startPriceUpdateTimer();
  }

  @override
  void dispose() {
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  void _startPriceUpdateTimer() {
    // 1분마다 시세 업데이트
    _priceUpdateTimer = Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) async {
      final repository = ref.read(stockRepositoryProvider);
      await repository.updateDailyPrices();
      ref.invalidate(stocksProvider);
      ref.invalidate(myInvestmentsProvider);
    });
  }

  Future<void> _checkAndUpdatePrices() async {
    // 하루에 한 번 가격 업데이트
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_stock_update');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastUpdate != today) {
      final repository = ref.read(stockRepositoryProvider);
      await repository.updateDailyPrices();
      await prefs.setString('last_stock_update', today);
      ref.invalidate(stocksProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(stocksProvider);
    final myInvestmentsAsync = ref.watch(myInvestmentsProvider);
    final totalCoinsAsync = ref.watch(totalCoinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 투자'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stocksProvider);
          ref.invalidate(myInvestmentsProvider);
        },
        child: stocksAsync.when(
          data: (stocks) => CustomScrollView(
            slivers: [
              // 포트폴리오 요약
              SliverToBoxAdapter(
                child: totalCoinsAsync.when(
                  data: (totalCoins) => Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade900],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '보유 코인',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          NumberFormat('#,###').format(totalCoins) + ' NC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => SizedBox(height: 120),
                  error: (_, __) => SizedBox(height: 120),
                ),
              ),

              // 내 투자 현황
              SliverToBoxAdapter(
                child: myInvestmentsAsync.when(
                  data: (investments) => investments.isEmpty
                      ? SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                12,
                              ),
                              child: Text(
                                '내 투자 현황',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...investments.map(
                              (investment) =>
                                  _buildInvestmentCard(investment, stocks),
                            ),
                          ],
                        ),
                  loading: () => SizedBox.shrink(),
                  error: (_, __) => SizedBox.shrink(),
                ),
              ),

              // 주식 목록 헤더
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '주식 목록',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final repository = ref.read(stockRepositoryProvider);
                          await repository.updateDailyPrices();
                          ref.invalidate(stocksProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('📊 시세가 업데이트되었습니다')),
                          );
                        },
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('시세 갱신'),
                      ),
                    ],
                  ),
                ),
              ),

              // 주식 리스트
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final stock = stocks[index];
                  return _buildStockCard(stock);
                }, childCount: stocks.length),
              ),
            ],
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('주식 목록을 불러올 수 없습니다\n$err')),
        ),
      ),
    );
  }

  Widget _buildInvestmentCard(investment, List<StockModel> stocks) {
    final stock = stocks.firstWhere(
      (s) => s.symbol == investment.symbol,
      orElse: () => StockModel(
        symbol: investment.symbol,
        name: investment.symbol,
        currentPrice: 0,
        previousClose: 0,
        changeRate: 0.0,
        volume: 0,
        lastUpdated: DateTime.now(),
      ),
    );

    final currentPrice = stock.currentPrice;
    final quantity = investment.buyAmount.toInt(); // buyAmount를 quantity로 변환
    final currentValue = currentPrice * quantity;
    final profit = currentValue - investment.buyCoinAmount;
    final profitRate = investment.buyCoinAmount > 0
        ? (profit / investment.buyCoinAmount * 100)
        : 0.0;
    final isProfit = profit >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isProfit ? Colors.red.shade100 : Colors.blue.shade100,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${quantity}주 보유',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showSellDialog(investment, stock),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('매도'),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  '매수가',
                  '${NumberFormat('#,###').format(investment.buyPrice)} NC',
                ),
                _buildInfoColumn(
                  '현재가',
                  '${NumberFormat('#,###').format(currentPrice)} NC',
                ),
                _buildInfoColumn(
                  '평가액',
                  '${NumberFormat('#,###').format(currentValue)} NC',
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isProfit ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '수익률',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isProfit
                          ? Colors.red.shade900
                          : Colors.blue.shade900,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${isProfit ? '+' : ''}${NumberFormat('#,###').format(profit)} NC',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.red : Colors.blue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${isProfit ? '+' : ''}${profitRate.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.red : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStockCard(StockModel stock) {
    final isUp = stock.isUp;
    final color = isUp
        ? Colors.red
        : (stock.isDown ? Colors.blue : Colors.grey);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _showBuyDialog(stock),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    stock.symbol,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat('#,###').format(stock.currentPrice) + ' NC',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: color,
                      size: 20,
                    ),
                    Text(
                      '${isUp ? '+' : ''}${stock.changeRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSellDialog(investment, StockModel stock) {
    final quantity = investment.buyAmount.toInt();
    final quantityController = TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${stock.name} 매도'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보유 수량'),
                Text(
                  '${investment.buyAmount.toInt()}주',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('현재가'),
                Text(
                  '${NumberFormat('#,###').format(stock.currentPrice)} NC',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stock.isUp ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '매도 수량',
                border: OutlineInputBorder(),
                suffixText: '주',
                helperText: '최대 ${investment.buyAmount.toInt()}주',
              ),
            ),
            SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final total = stock.currentPrice * quantity;
                final buyTotal = investment.buyPrice * quantity;
                final profit = total - buyTotal;
                final isProfit = profit >= 0;

                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isProfit ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('받을 금액'),
                          Text(
                            '${NumberFormat('#,###').format(total)} NC',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('예상 손익'),
                          Text(
                            '${isProfit ? '+' : ''}${NumberFormat('#,###').format(profit)} NC',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isProfit ? Colors.red : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity <= 0 || quantity > investment.buyAmount.toInt()) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('올바른 수량을 입력해주세요')));
                return;
              }

              try {
                final stockRepo = ref.read(stockRepositoryProvider);
                final coinRepo = ref.read(coinRepositoryProvider);

                final sellAmount = stock.currentPrice * quantity;

                // 주식 매도
                await stockRepo.sellStock(investment.id);

                // 코인 회수 (invested_amount 감소 + total_coins 증가)
                await coinRepo.retrieveInvestment(
                  amount: sellAmount,
                  investmentId: investment.id,
                );

                ref.read(totalCoinsProvider.notifier).refresh();
                ref.invalidate(myInvestmentsProvider);

                Navigator.pop(context);

                final profit = sellAmount - (investment.buyPrice * quantity);
                final isProfit = profit >= 0;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ ${stock.name} ${quantity}주 매도 완료! '
                      '${isProfit ? '수익' : '손실'}: ${NumberFormat('#,###').format(profit.abs())} NC',
                    ),
                    backgroundColor: isProfit ? Colors.green : Colors.orange,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('매도 실패: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('매도'),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(StockModel stock) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${stock.name} 매수'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현재가: ${NumberFormat('#,###').format(stock.currentPrice)} NC',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '수량',
                border: OutlineInputBorder(),
                suffixText: '주',
              ),
            ),
            SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final total = stock.currentPrice * quantity;
                return Text(
                  '총 금액: ${NumberFormat('#,###').format(total)} NC',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('수량을 입력해주세요')));
                return;
              }

              final totalCost = stock.currentPrice * quantity;
              final totalCoinsAsync = ref.read(totalCoinsProvider);
              
              final totalCoins = totalCoinsAsync.when(
                data: (coins) => coins,
                loading: () => 0,
                error: (_, __) => 0,
              );

              if (totalCoins < totalCost) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('코인이 부족합니다 (보유: ${NumberFormat('#,###').format(totalCoins)} NC, 필요: ${NumberFormat('#,###').format(totalCost)} NC)')));
                return;
              }

              try {
                final stockRepo = ref.read(stockRepositoryProvider);
                final coinRepo = ref.read(coinRepositoryProvider);

                // 주식 매수
                final investment = await stockRepo.buyStock(
                  symbol: stock.symbol,
                  quantity: quantity,
                  totalCoinAmount: totalCost,
                );

                // 코인 차감 및 투자 기록
                await coinRepo.investCoins(
                  amount: totalCost,
                  investmentId: investment.id,
                );

                ref.read(totalCoinsProvider.notifier).refresh();
                ref.invalidate(myInvestmentsProvider);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${stock.name} ${quantity}주 매수 완료!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('매수 실패: $e')));
              }
            },
            child: Text('매수'),
          ),
        ],
      ),
    );
  }
}
