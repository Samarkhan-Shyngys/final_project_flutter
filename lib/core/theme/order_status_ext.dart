import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../../domain/entities/order_status.dart';

extension OrderStatusColors on OrderStatus {
  Color get bgColor {
    switch (this) {
      case OrderStatus.draft:      return AppColors.draftBg;
      case OrderStatus.inProgress: return AppColors.inProgressBg;
      case OrderStatus.inDelivery: return AppColors.inDeliveryBg;
      case OrderStatus.delivered:  return AppColors.deliveredBg;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.draft:      return AppColors.draftText;
      case OrderStatus.inProgress: return AppColors.inProgressText;
      case OrderStatus.inDelivery: return AppColors.inDeliveryText;
      case OrderStatus.delivered:  return AppColors.deliveredText;
    }
  }

  Color get dotColor {
    switch (this) {
      case OrderStatus.draft:      return AppColors.draftDot;
      case OrderStatus.inProgress: return AppColors.inProgressText;
      case OrderStatus.inDelivery: return AppColors.inDeliveryText;
      case OrderStatus.delivered:  return AppColors.deliveredText;
    }
  }
}
