import 'package:flutter/material.dart';
import '../../domain/entities/order_status.dart';

enum ChipSize { sm, md }

class StatusChip extends StatelessWidget {
  final OrderStatus status;
  final ChipSize size;

  const StatusChip({super.key, required this.status, this.size = ChipSize.md});

  @override
  Widget build(BuildContext context) {
    final isSmall = size == ChipSize.sm;
    final pH = isSmall ? 8.0 : 10.0;
    final pV = isSmall ? 3.0 : 5.0;
    final fs = isSmall ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: pH, vertical: pV),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: status.dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: fs,
              fontWeight: FontWeight.w600,
              color: status.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
