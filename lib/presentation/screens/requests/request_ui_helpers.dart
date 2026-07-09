import 'package:flutter/material.dart';

import '../../../app/locale_controller.dart';
import '../../../utility/style/theme.dart';

Color requestStatusColor(String status) {
  switch (status) {
    case 'approved':
      return ColorObj.successColor;
    case 'refused':
      return Colors.red;
    case 'cancel':
      return Colors.grey;
    case 'pending':
      return Colors.orange;
    default:
      return ColorObj.mainColor;
  }
}

String requestStatusLabel(BuildContext context, String status) {
  switch (status) {
    case 'new':
      return context.l10n.statusNew;
    case 'pending':
      return context.l10n.pending;
    case 'approved':
      return context.l10n.approved;
    case 'refused':
      return context.l10n.refused;
    case 'cancel':
      return context.l10n.cancelled;
    default:
      return status;
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = requestStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        requestStatusLabel(context, status),
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

IconData sectionIcon(String icon) {
  switch (icon) {
    case 'person':
      return Icons.person_outline;
    case 'finance':
    case 'money':
      return Icons.account_balance_wallet_outlined;
    case 'car':
    case 'vehicle':
      return Icons.directions_car_outlined;
    case 'purchase':
    case 'cart':
      return Icons.shopping_cart_outlined;
    case 'hr':
      return Icons.badge_outlined;
    case 'document':
      return Icons.description_outlined;
    default:
      return Icons.folder_open_outlined;
  }
}
