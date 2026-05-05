import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum StepperSize { compact, normal }

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final int minOrder;
  final ValueChanged<int> onChanged;
  final StepperSize size;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.minOrder,
    required this.onChanged,
    this.size = StepperSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = size == StepperSize.compact;
    final btnSize = isCompact ? 28.0 : 36.0;
    final iconSize = isCompact ? 14.0 : 16.0;
    final fontSize = isCompact ? 13.0 : 15.0;
    final canDecrement = quantity > minOrder;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderMid, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: canDecrement ? 1.0 : 0.3,
            child: GestureDetector(
              onTap: canDecrement ? () => onChanged(quantity - 1) : null,
              child: SizedBox(
                width: btnSize, height: btnSize,
                child: Icon(Icons.remove, size: iconSize, color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(
            width: btnSize,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: SizedBox(
              width: btnSize, height: btnSize,
              child: Icon(Icons.add, size: iconSize, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
