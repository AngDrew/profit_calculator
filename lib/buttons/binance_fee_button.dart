import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BinanceRegulerUser extends StatefulWidget {
  const BinanceRegulerUser({
    Key? key,
    required TextEditingController buyFeeController,
    required TextEditingController sellFeeController,
    required SharedPreferences? sp,
    required this.onPressed,
  })  : _buyFeeController = buyFeeController,
        _sp = sp,
        _sellFeeController = sellFeeController,
        super(key: key);

  final TextEditingController _buyFeeController;
  final TextEditingController _sellFeeController;
  final SharedPreferences? _sp;
  final VoidCallback onPressed;

  @override
  State<BinanceRegulerUser> createState() => _BinanceRegulerUserState();
}

class _BinanceRegulerUserState extends State<BinanceRegulerUser> {
  bool _isUsingBnb = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Color(0xFFFCD535)),
      ),
      onPressed: updateFee,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 8.0),
          const Text(
            'Binance Fee',
            style: TextStyle(
              color: Color(0xFF1E2329),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Switch(
                value: _isUsingBnb,
                onChanged: (value) {
                  setState(() {
                    _isUsingBnb = value;
                  });

                  updateFee();
                },
              ),
              const Text(
                '(using BNB)',
                style: TextStyle(
                  color: Color(0xFF1E2329),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void updateFee() {
    double multiplier = 0.1;
    if (_isUsingBnb) {
      multiplier = 0.075;
    }

    widget._buyFeeController.text = multiplier.toString();
    widget._sellFeeController.text = multiplier.toString();
    widget._sp?.setDouble('buyFee', multiplier);
    widget._sp?.setDouble('sellFee', multiplier);

    widget.onPressed();
  }
}