import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/backup_codes/backup_code_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'backup_codes_provider.dart';

/// Backup code details bottom sheet
class BackupCodeDetailsSheet extends ConsumerWidget {
  final BackupCodeSet codeSet;
  final List<BackupCode> codes;
  
  const BackupCodeDetailsSheet({
    super.key,
    required this.codeSet,
    required this.codes,
  });
  
  void _showCodeActions(
    BuildContext context,
    WidgetRef ref,
    BackupCode code,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CodeActionsSheet(
        code: code,
        onDelete: () async {
          Navigator.pop(context);
          await ref.read(backupCodesProvider.notifier).deleteCode(code.id);
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        onToggleUsed: () async {
          await ref.read(backupCodesProvider.notifier).toggleUsed(code.id);
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: AppConstants.screenPadding,
            child: Row(
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
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        codeSet.email,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(),
          // Codes list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: AppConstants.screenPadding,
              itemCount: codes.length,
              itemBuilder: (context, index) {
                final code = codes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
                  child: _BackupCodeItem(
                    code: code,
                    onTap: () {
                      copyToClipboard(code.code, context);
                    },
                    onLongPress: () => _showCodeActions(context, ref, code),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Backup code item widget
class _BackupCodeItem extends StatelessWidget {
  final BackupCode code;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  const _BackupCodeItem({
    required this.code,
    required this.onTap,
    required this.onLongPress,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: code.isUsed
                ? AppTheme.textTertiary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                code.code,
                style: TextStyle(
                  color: code.isUsed
                      ? AppTheme.textTertiary
                      : AppTheme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  decoration: code.isUsed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (code.isUsed)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Used',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Code actions bottom sheet
class _CodeActionsSheet extends StatelessWidget {
  final BackupCode code;
  final VoidCallback onDelete;
  final VoidCallback onToggleUsed;
  
  const _CodeActionsSheet({
    required this.code,
    required this.onDelete,
    required this.onToggleUsed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              code.isUsed ? Icons.refresh : Icons.check,
              color: AppTheme.textPrimary,
            ),
            title: Text(
              code.isUsed ? 'Mark as Unused' : 'Mark as Used',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            onTap: () {
              onToggleUsed();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: AppTheme.textPrimary),
            title: const Text(
              'Copy Code',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              // Copy handled by parent
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppTheme.errorColor),
            title: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Backup Code'),
                  content: const Text(
                    'Are you sure you want to delete this backup code?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onDelete();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

