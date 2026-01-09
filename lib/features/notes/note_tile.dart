import 'package:flutter/material.dart';
import '../../core/notes/note_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

/// Secure note tile widget
class NoteTile extends StatelessWidget {
  final SecureNote note;
  final VoidCallback onTap;
  
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final preview = note.content.length > 100
        ? '${note.content.substring(0, 100)}...'
        : note.content;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppConstants.tilePaddingInsets,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDate(note.updatedAt),
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: AppConstants.gapSm),
              Text(
                preview,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

