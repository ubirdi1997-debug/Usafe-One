import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/otp/authenticator_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'authenticator_provider.dart';
import 'authenticator_tile.dart';
import 'add_token_bottom_sheet.dart';

/// Main authenticator screen
class AuthenticatorScreen extends ConsumerStatefulWidget {
  const AuthenticatorScreen({super.key});
  
  @override
  ConsumerState<AuthenticatorScreen> createState() => _AuthenticatorScreenState();
}

class _AuthenticatorScreenState extends ConsumerState<AuthenticatorScreen> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  void _showTokenActions(BuildContext context, AuthenticatorToken token) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TokenActionsBottomSheet(token: token),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tokens = ref.watch(authenticatorProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: tokens.isEmpty
            ? _EmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  // Refresh is automatic via timer
                },
                child: ListView.builder(
                  padding: AppConstants.screenPadding,
                  itemCount: tokens.length,
                  itemBuilder: (context, index) {
                    final token = tokens[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
                      child: AuthenticatorTile(
                        token: token,
                        onTap: () {
                          final code = token.generateCode();
                          copyToClipboard(code, context, successMessage: 'Code copied');
                        },
                        onLongPress: () => _showTokenActions(context, token),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

/// Empty state when no tokens
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
              Icons.security,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              'No Authenticators',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Add your first authenticator token',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            const Text(
              'Use the + button below to add your first authenticator',
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

/// Token actions bottom sheet
class _TokenActionsBottomSheet extends ConsumerWidget {
  final AuthenticatorToken token;
  
  const _TokenActionsBottomSheet({required this.token});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.zero, // Sharp corners
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppTheme.textPrimary),
            title: const Text('Edit', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show edit dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppTheme.errorColor),
            title: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Token'),
                  content: Text('Are you sure you want to delete ${token.label}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authenticatorProvider.notifier).deleteToken(token.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

