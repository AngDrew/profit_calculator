import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeeButton extends StatelessWidget {
  const FeeButton({
    super.key,
    required this.buyFee,
    this.buttonColor,
    required this.title,
    required this.sellFee,
    required this.buyFeeController,
    required this.sellFeeController,
    required this.sp,
    required this.onPressed,
  });

  final Color? buttonColor;
  final double buyFee;
  final double sellFee;
  final TextEditingController buyFeeController;
  final TextEditingController sellFeeController;
  final SharedPreferences? sp;
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isUsingComma = sp?.getBool('isUsingComma') == true;

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(buttonColor),
      ),
      onPressed: () {
        buyFeeController.text = buyFee.toString();
        sp?.setDouble('buyFee', buyFee);
        sellFeeController.text = sellFee.toString();
        sp?.setDouble('sellFee', sellFee);

        if (isUsingComma) {
          buyFeeController.text = buyFeeController.text.replaceAll('.', ',');
          sellFeeController.text = sellFeeController.text.replaceAll('.', ',');
        }

        onPressed.call();
      },
      child: Text(title),
    );
  }
}
