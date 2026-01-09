import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/backup_codes/backup_code_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'backup_codes_provider.dart';
import 'backup_code_details_sheet.dart';

/// Backup code set tile widget
class BackupCodeSetTile extends ConsumerWidget {
  final BackupCodeSet codeSet;
  
  const BackupCodeSetTile({super.key, required this.codeSet});
  
  void _showDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackupCodeDetailsSheet(
        codeSet: codeSet,
        codes: ref.watch(backupCodesProvider.notifier)
            .getCodesByService(codeSet.serviceName, codeSet.email),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showDetails(context, ref),
      child: Container(
        padding: AppConstants.tilePadding,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundSecondary, // --tile-background: #1a1a1a
          borderRadius: BorderRadius.zero, // --tile-border-radius: 0px
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        codeSet.serviceName.isNotEmpty
                            ? codeSet.serviceName
                            : 'Backup Codes',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15, // --font-size-md
                          fontWeight: FontWeight.w500, // --font-weight-medium
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        codeSet.email,
                        style: const TextStyle(
                          color: AppTheme.textTertiary, // --text-tertiary: #52525b (Email: 13px #52525b)
                          fontSize: 13, // --font-size-sm
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Row(
              children: [
                _StatBadge(
                  label: '${codeSet.unusedCount} unused',
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _StatBadge(
                  label: '${codeSet.usedCount} used',
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat badge widget
class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  
  const _StatBadge({required this.label, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.zero, // Sharp corners
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12, // --font-size-xs
          fontWeight: FontWeight.w500, // --font-weight-medium
        ),
      ),
    );
  }
}

