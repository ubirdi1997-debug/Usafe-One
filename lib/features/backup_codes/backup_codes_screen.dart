import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/backup_codes/backup_code_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'backup_codes_provider.dart';
import 'add_backup_code_sheet.dart';
import 'backup_code_set_tile.dart';

/// Backup codes screen
class BackupCodesScreen extends ConsumerStatefulWidget {
  const BackupCodesScreen({super.key});
  
  @override
  ConsumerState<BackupCodesScreen> createState() => _BackupCodesScreenState();
}

class _BackupCodesScreenState extends ConsumerState<BackupCodesScreen> {
  final _searchController = TextEditingController();
  String _selectedEmail = '';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<BackupCodeSet> _getFilteredSets(WidgetRef ref) {
    final allSets = ref.watch(backupCodesProvider.notifier).getCodeSets();
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty && _selectedEmail.isEmpty) {
      return allSets;
    }
    
    return allSets.where((set) {
      if (_selectedEmail.isNotEmpty && set.email != _selectedEmail) {
        return false;
      }
      if (query.isNotEmpty) {
        return set.serviceName.toLowerCase().contains(query) ||
               set.email.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }
  
  List<String> _getUniqueEmails(WidgetRef ref) {
    final codes = ref.watch(backupCodesProvider);
    final emails = codes.map((c) => c.email).toSet().toList()..sort();
    return emails;
  }
  
  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(backupCodesProvider);
    final codeSets = _getFilteredSets(ref);
    final emails = _getUniqueEmails(ref);
    
    return Scaffold(
      backgroundColor: AppTheme.nearBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: AppConstants.screenPadding,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by service or email...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            // Email filter
            if (emails.isNotEmpty) ...[
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _EmailFilterChip(
                      label: 'All',
                      isSelected: _selectedEmail.isEmpty,
                      onTap: () => setState(() => _selectedEmail = ''),
                    ),
                    const SizedBox(width: 8),
                    ...emails.map((email) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _EmailFilterChip(
                        label: email,
                        isSelected: _selectedEmail == email,
                        onTap: () => setState(() => _selectedEmail = email),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Code sets list
            Expanded(
              child: codes.isEmpty
                  ? const _EmptyState()
                  : codeSets.isEmpty
                      ? Center(
                          child: Text(
                            'No backup codes found',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: AppConstants.screenPadding,
                          itemCount: codeSets.length,
                          itemBuilder: (context, index) {
                            final set = codeSets[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.spacingMedium,
                              ),
                              child: BackupCodeSetTile(codeSet: set),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Email filter chip
class _EmailFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _EmailFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : AppTheme.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.nearBlack : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.backup,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'No Backup Codes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Add your backup codes for 2-step verification',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            const Text(
              'Use the + button below to add your first backup codes',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

