import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/stock_item.dart';

class StockItemCard extends StatelessWidget {
  final StockItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onNewBatch;

  const StockItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onNewBatch,
  });

  Color get _statusColor {
    switch (item.status) {
      case StockStatus.high:
      case StockStatus.adequate:
        return AppColors.success;
      case StockStatus.attention:
        return AppColors.gold;
      case StockStatus.low:
      case StockStatus.critical:
        return AppColors.danger;
      case StockStatus.outOfStock:
        return AppColors.textMuted;
    }
  }

  bool get _isCritical =>
      item.status == StockStatus.low || item.status == StockStatus.critical;

  @override
  Widget build(BuildContext context) {
    if (item.isOutOfStock) return _buildOutOfStock();
    return _buildInStock();
  }

  Widget _buildInStock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCritical
              ? AppColors.danger.withOpacity(0.3)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      item.packageLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status: item.status,
                color: _statusColor,
                isCritical: _isCritical,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ocupação',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                '${item.quantity} / ${item.capacity} un',
                style: TextStyle(
                  fontSize: 11,
                  color: _isCritical ? AppColors.danger : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.occupancyRatio.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isCritical ? AppColors.danger : AppColors.textDark,
                    fontFamily: 'monospace',
                  ),
                  children: [
                    TextSpan(text: '${item.quantity}'),
                    TextSpan(
                      text: ' un',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.remove,
                    background: AppColors.background,
                    foreground: AppColors.textDark,
                    onTap: onDecrement,
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: Icons.add,
                    background: AppColors.headerStart,
                    foreground: Colors.white,
                    onTap: onIncrement,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Opacity(
        opacity: 0.6,
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
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      item.packageLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Em Falta',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ocupação',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  '0 / ${item.capacity} un',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation(AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 un',
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
                OutlinedButton(
                  onPressed: onNewBatch,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.headerStart,
                    side: BorderSide(
                      color: AppColors.headerStart.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Novo Lote'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StockStatus status;
  final Color color;
  final bool isCritical;

  const _StatusBadge({
    required this.status,
    required this.color,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    final background = isCritical
        ? AppColors.danger.withOpacity(0.12)
        : color.withOpacity(0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCritical) ...[
            Icon(Icons.warning_amber_rounded, size: 12, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: foreground),
        ),
      ),
    );
  }
}
