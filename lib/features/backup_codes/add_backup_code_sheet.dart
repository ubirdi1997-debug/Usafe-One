import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/backup_codes/backup_code_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'backup_codes_provider.dart';

/// Add backup code bottom sheet
class AddBackupCodeSheet extends StatefulWidget {
  const AddBackupCodeSheet({super.key});
  
  @override
  State<AddBackupCodeSheet> createState() => _AddBackupCodeSheetState();
}

class _AddBackupCodeSheetState extends State<AddBackupCodeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _addMultiple = false;
  
  @override
  void dispose() {
    _serviceController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }
  
  Future<void> _saveCode(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_addMultiple) {
      // Parse multiple codes (one per line)
      final codes = _codeController.text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      
      if (codes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one code')),
        );
        return;
      }
      
      final backupCodes = codes.map((code) {
        return BackupCode(
          id: generateId() + codes.indexOf(code).toString(),
          serviceName: _serviceController.text.trim(),
          email: _emailController.text.trim(),
          code: code,
          isUsed: false,
          createdAt: DateTime.now(),
        );
      }).toList();
      
      await ref.read(backupCodesProvider.notifier).addCodes(backupCodes);
    } else {
      final backupCode = BackupCode(
        id: generateId(),
        serviceName: _serviceController.text.trim(),
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        isUsed: false,
        createdAt: DateTime.now(),
      );
      
      await ref.read(backupCodesProvider.notifier).addCode(backupCode);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Backup Codes',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              // Service name
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g., Google, GitHub',
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              // Email/Username
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email / Username',
                  hintText: 'user@example.com',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email/Username is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              // Add multiple toggle
              Row(
                children: [
                  Checkbox(
                    value: _addMultiple,
                    onChanged: (value) {
                      setState(() => _addMultiple = value ?? false);
                      if (!_addMultiple) {
                        _codeController.text = _codeController.text.split('\n').first;
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Add multiple codes (one per line)',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              // Code(s)
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: _addMultiple ? 'Backup Codes (one per line)' : 'Backup Code',
                  hintText: _addMultiple
                      ? 'Enter codes, one per line'
                      : 'Enter backup code',
                ),
                maxLines: _addMultiple ? 10 : 1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Backup code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () => _saveCode(ref),
                          child: const Text('Add'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

