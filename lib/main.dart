import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buttons/binance_fee_button.dart';
import 'buttons/fee_button.dart';
import 'buttons/prefix_icon_button.dart';
import 'buttons/suffix_icon_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profit Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Profit Calculator'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _buy = 0.0;
  double _sell = 0.0;
  double _buyFeePercentage = 0.0;
  double _sellFeePercentage = 0.0;
  double _profitPercentage = 0.0;
  double _profit = 0.0;

  final TextEditingController _buyController = TextEditingController();
  final TextEditingController _sellController = TextEditingController();
  final TextEditingController _buyFeeController = TextEditingController();
  final TextEditingController _sellFeeController = TextEditingController();
  final TextEditingController _profitPercentageController =
      TextEditingController();
  SharedPreferences? _sp;

  @override
  void initState() {
    super.initState();

    initSharedPreferences();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _buyFeeController.text = _buyFeePercentage.toStringAsFixed(0);
        _sellFeeController.text = _sellFeePercentage.toStringAsFixed(0);
      });
    });
  }

  @override
  void dispose() {
    _buyController.dispose();
    _sellController.dispose();
    _buyFeeController.dispose();
    _sellFeeController.dispose();

    super.dispose();
  }

  void initSharedPreferences() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    setState(() {
      _sp = sp;
      _buyFeePercentage = sp.getDouble('buyFee') ?? 0.0;
      _sellFeePercentage = sp.getDouble('sellFee') ?? 0.0;
      _buyFeeController.text = _buyFeePercentage.toString();
      _sellFeeController.text = _sellFeePercentage.toString();
      isUsingComma = _sp?.getBool('isUsingComma') == true;
    });
  }

  double _getSellFee() {
    double fee = (_sell * _sellFeePercentage / 100);
    return double.tryParse(fee.toStringAsFixed(5)) ?? 0;
  }

  double _getBuyFee() {
    double fee = (_buy * _buyFeePercentage / 100);
    return double.tryParse(fee.toStringAsFixed(5)) ?? 0;
  }

  double getFee() {
    return _getBuyFee() + _getSellFee();
  }

  void _calculateProfit() {
    if (isUsingComma) {
      _buyController.text = _buyController.text.replaceAll('.', ',');
      _sellController.text = _sellController.text.replaceAll('.', ',');
      _buyFeeController.text = _buyFeeController.text.replaceAll('.', ',');
      _sellFeeController.text = _sellFeeController.text.replaceAll('.', ',');
      _profitPercentageController.text =
          _profitPercentageController.text.replaceAll('.', ',');
    } else {
      _buyController.text = _buyController.text.replaceAll(',', '.');
      _sellController.text = _sellController.text.replaceAll(',', '.');
      _buyFeeController.text = _buyFeeController.text.replaceAll(',', '.');
      _sellFeeController.text = _sellFeeController.text.replaceAll(',', '.');
      _profitPercentageController.text =
          _profitPercentageController.text.replaceAll(',', '.');
    }

    _buy = (double.tryParse(_buyController.text.replaceAll(',', '.')) ?? 0);

    // divided by zero
    if (_buy == 0) return;

    _sell = (double.tryParse(_sellController.text.replaceAll(',', '.')) ?? 0);
    _buyFeePercentage =
        (double.tryParse(_buyFeeController.text.replaceAll(',', '.')) ?? 0);
    _sellFeePercentage =
        (double.tryParse(_sellFeeController.text.replaceAll(',', '.')) ?? 0);
    _profitPercentage = (double.tryParse(
            _profitPercentageController.text.replaceAll(',', '.')) ??
        0);

    if (_sell != 0) {
      _profitPercentageController.clear();
    } else if (_profitPercentage != 0) {
      double buyFee = _getBuyFee();
      _sell = (_profitPercentage * (_buy + buyFee) / 100) + (_buy + buyFee);
      _sell += _getSellFee();

      if (isUsingComma) {
        _sellController.text = _sell.toStringAsFixed(2).replaceAll('.', ',');
      } else {
        _sellController.text = _sell.toStringAsFixed(2).replaceAll(',', '.');
      }
    }

    double fee = getFee();
    setState(() {
      _profit = _sell - _buy - fee;
    });

    _profitPercentage = _profit / _buy * 100;

    if (isUsingComma) {
      _profitPercentageController.text =
          _profitPercentage.toStringAsFixed(2).replaceAll('.', ',');
    } else {
      _profitPercentageController.text =
          _profitPercentage.toStringAsFixed(2).replaceAll(',', '.');
    }

    FocusScope.of(context).unfocus();
  }

  bool isProfit = false;
  bool isUsingComma = false;
  final bool isIos = defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    isProfit = _profitPercentage >= 0;

    final TextInputType inputType = isIos
        ? const TextInputType.numberWithOptions(decimal: true, signed: true)
        : TextInputType.number;

    final List<FilteringTextInputFormatter> inputFormatters =
        <FilteringTextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
    ];

    final Wrap buttonFees = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FeeButton(
          buyFee: 0.19,
          sellFee: 0.29,
          buyFeeController: _buyFeeController,
          sellFeeController: _sellFeeController,
          sp: _sp,
          buttonColor: const Color(0xFF192049),
          onPressed: _calculateProfit,
          title: 'IPOT Fee',
        ),
        FeeButton(
          buyFee: 0.15,
          sellFee: 0.25,
          buyFeeController: _buyFeeController,
          sellFeeController: _sellFeeController,
          sp: _sp,
          buttonColor: const Color(0xFFF7831A),
          onPressed: _calculateProfit,
          title: 'Mirae Fee',
        ),
        FeeButton(
          buyFee: 0.18,
          sellFee: 0.28,
          buyFeeController: _buyFeeController,
          sellFeeController: _sellFeeController,
          sp: _sp,
          buttonColor: const Color(0xFF8E7636),
          onPressed: _calculateProfit,
          title: 'MNC Fee',
        ),
        FeeButton(
          buyFee: 0,
          sellFee: 0,
          buyFeeController: _buyFeeController,
          sellFeeController: _sellFeeController,
          sp: _sp,
          onPressed: _calculateProfit,
          title: '0 Fee',
        ),
        BinanceRegulerUser(
          buyFeeController: _buyFeeController,
          sellFeeController: _sellFeeController,
          sp: _sp,
          onPressed: _calculateProfit,
        ),
      ],
    );
    final RichText profitTexts = RichText(
      text: TextSpan(
        children: [
          if (isProfit) ...[
            TextSpan(
              text: 'P',
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  ?.copyWith(color: Colors.green),
            ),
            const TextSpan(
              text: 'rofit',
              style: TextStyle(color: Colors.green),
            ),
          ],
          if (!isProfit) ...[
            TextSpan(
              text: 'L',
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  ?.copyWith(color: Colors.red),
            ),
            const TextSpan(
              text: 'oss',
              style: TextStyle(color: Colors.red),
            ),
          ],
          TextSpan(
            text: ': ',
            style: Theme.of(context).textTheme.headline6,
          ),
          TextSpan(
            text: isProfit ? '+' : '-',
            style: Theme.of(context).textTheme.headline4?.copyWith(
                  color: isProfit ? Colors.green : Colors.red,
                ),
          ),
          TextSpan(
            text: isUsingComma
                ? _profit.abs().toStringAsFixed(2).replaceAll(',', '.')
                : _profit.abs().toStringAsFixed(2),
            style: Theme.of(context).textTheme.headline4?.copyWith(
                  color: isProfit ? Colors.green : Colors.red,
                ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextField(
              controller: _buyController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Buy at',
                prefixIcon: CopyButton(textToCopy: _buyController.text),
                suffixIcon: SuffixIconButton(controller: _buyController),
              ),
              onEditingComplete: _calculateProfit,
              keyboardType: inputType,
              inputFormatters: inputFormatters,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sellController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Sell at',
                prefixIcon: CopyButton(textToCopy: _sellController.text),
                suffixIcon: SuffixIconButton(controller: _sellController),
              ),
              onEditingComplete: _calculateProfit,
              onChanged: (value) {
                _profitPercentageController.clear();
              },
              keyboardType: inputType,
              inputFormatters: inputFormatters,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _buyFeeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '% Buy Fee',
                prefixIcon: CopyButton(textToCopy: _buyFeeController.text),
                suffixIcon: SuffixIconButton(controller: _buyFeeController),
              ),
              onEditingComplete: _calculateProfit,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _sp?.setDouble(
                    'buyFee',
                    (double.tryParse(value) ?? 0),
                  );
                }
              },
              keyboardType: inputType,
              inputFormatters: inputFormatters,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sellFeeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '% Sell Fee',
                prefixIcon: CopyButton(textToCopy: _sellFeeController.text),
                suffixIcon: SuffixIconButton(controller: _sellFeeController),
              ),
              onEditingComplete: _calculateProfit,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _sp?.setDouble(
                    'sellFee',
                    (double.tryParse(value) ?? 0),
                  );
                }
              },
              keyboardType: inputType,
              inputFormatters: inputFormatters,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateProfit,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _profitPercentageController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '% P/L',
                prefixIcon: IconButton(
                  tooltip: 'Change sign',
                  onPressed: () {
                    final String percentage = _profitPercentageController.text;
                    if (percentage.isEmpty) return;

                    if (percentage.startsWith('-')) {
                      _profitPercentageController.text =
                          percentage.replaceFirst('-', '');
                    } else {
                      _profitPercentageController.text = '-$percentage';
                    }
                    _sellController.clear();

                    _calculateProfit();
                  },
                  icon: const Icon(Icons.sync_rounded),
                ),
                suffixIcon: SuffixIconButton(
                  controller: _profitPercentageController,
                ),
              ),
              onEditingComplete: _calculateProfit,
              onChanged: (value) {
                _sellController.clear();
              },
              keyboardType: inputType,
              inputFormatters: inputFormatters,
            ),
            profitTexts,
            Row(
              children: <Widget>[
                const Text('Use comma (,) as decimal separator'),
                Switch(
                  value: isUsingComma,
                  onChanged: (value) {
                    _sp?.setBool('isUsingComma', value);
                    setState(() {
                      isUsingComma = _sp?.getBool('isUsingComma') == true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            buttonFees,
          ],
        ),
      ),
    );
  }
}
