import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BannerType { info, warning, error, success }

class InfoBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback? onDismiss;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = BannerType.info,
    this.onAction,
    this.actionLabel,
    this.onDismiss,
  });

  Color get _backgroundColor {
    switch (type) {
      case BannerType.info:
        return Colors.blue.shade50;
      case BannerType.warning:
        return Colors.orange.shade50;
      case BannerType.error:
        return Colors.red.shade50;
      case BannerType.success:
        return Colors.green.shade50;
    }
  }

  Color get _borderColor {
    switch (type) {
      case BannerType.info:
        return Colors.blue;
      case BannerType.warning:
        return Colors.orange;
      case BannerType.error:
        return Colors.red;
      case BannerType.success:
        return Colors.green;
    }
  }

  Color get _iconColor {
    switch (type) {
      case BannerType.info:
        return Colors.blue.shade700;
      case BannerType.warning:
        return Colors.orange.shade700;
      case BannerType.error:
        return Colors.red.shade700;
      case BannerType.success:
        return Colors.green.shade700;
    }
  }

  IconData get _icon {
    switch (type) {
      case BannerType.info:
        return Icons.info_outline;
      case BannerType.warning:
        return Icons.warning_amber_outlined;
      case BannerType.error:
        return Icons.error_outline;
      case BannerType.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor, size: 24),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _iconColor,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _iconColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingSmall,
                ),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: _iconColor,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
