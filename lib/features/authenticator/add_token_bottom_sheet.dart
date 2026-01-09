import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/otp/authenticator_model.dart';
import '../../core/crypto/base32_decoder.dart';
import '../../core/otp/otpauth_parser.dart';
import '../../core/otp/totp_generator.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'authenticator_provider.dart';
import 'qr_scanner_screen.dart';

/// Bottom sheet for adding new token
class AddTokenBottomSheet extends StatefulWidget {
  const AddTokenBottomSheet({super.key});
  
  @override
  State<AddTokenBottomSheet> createState() => _AddTokenBottomSheetState();
}

class _AddTokenBottomSheetState extends State<AddTokenBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _secretController = TextEditingController();
  final _issuerController = TextEditingController();
  final _accountController = TextEditingController();
  Algorithm _algorithm = Algorithm.sha1;
  int _digits = 6;
  int _period = 30;
  bool _isManualEntry = false;
  
  @override
  void dispose() {
    _secretController.dispose();
    _issuerController.dispose();
    _accountController.dispose();
    super.dispose();
  }
  
  void _showQrScanner(WidgetRef ref) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
        fullscreenDialog: true,
      ),
    );
    
    if (result != null && mounted) {
      final parsed = OtpauthParser.parse(result);
      if (parsed != null) {
        // Auto-save if QR code has all required fields
        final token = AuthenticatorToken(
          id: generateId(),
          secret: parsed.secret,
          issuer: parsed.issuer,
          accountName: parsed.accountName,
          algorithm: parsed.algorithm,
          digits: parsed.digits,
          period: parsed.period,
          createdAt: DateTime.now(),
        );
        
        await ref.read(authenticatorProvider.notifier).addToken(token);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added: ${token.label}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code format')),
        );
      }
    }
  }
  
  Future<void> _saveToken(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    
    final secret = _secretController.text.trim().replaceAll(' ', '');
    
    // Validate Base32 secret
    if (!Base32Decoder.isValid(secret.toUpperCase())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid secret. Must be Base32 encoded.')),
        );
      }
      return;
    }
    
    final token = AuthenticatorToken(
      id: generateId(),
      secret: secret.toUpperCase(),
      issuer: _issuerController.text.trim(),
      accountName: _accountController.text.trim(),
      algorithm: _algorithm,
      digits: _digits,
      period: _period,
      createdAt: DateTime.now(),
    );
    
    await ref.read(authenticatorProvider.notifier).addToken(token);
    
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
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
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
                'Add Authenticator',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),
              // QR Scanner button
              if (!_isManualEntry) ...[
                Consumer(
                  builder: (context, ref, _) {
                    return ElevatedButton.icon(
                      onPressed: () => _showQrScanner(ref),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code'),
                    );
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.textTertiary)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppTheme.textTertiary),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.textTertiary)),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextButton(
                  onPressed: () => setState(() => _isManualEntry = true),
                  child: const Text('Enter Manually'),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
              ],
              // Manual entry form
              if (_isManualEntry) ...[
                TextFormField(
                  controller: _secretController,
                  decoration: const InputDecoration(
                    labelText: 'Secret (Base32)',
                    hintText: 'Enter your secret key',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Secret is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextFormField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., user@example.com',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Account name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                TextFormField(
                  controller: _issuerController,
                  decoration: const InputDecoration(
                    labelText: 'Issuer (Optional)',
                    hintText: 'e.g., Google, GitHub',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                // Algorithm dropdown
                DropdownButtonFormField<Algorithm>(
                  value: _algorithm,
                  decoration: const InputDecoration(labelText: 'Algorithm'),
                  dropdownColor: AppTheme.darkSurface,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  items: Algorithm.values.map((alg) {
                    return DropdownMenuItem(
                      value: alg,
                      child: Text(alg.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _algorithm = value);
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                // Digits dropdown
                DropdownButtonFormField<int>(
                  value: _digits,
                  decoration: const InputDecoration(labelText: 'Digits'),
                  dropdownColor: AppTheme.darkSurface,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 6, child: Text('6')),
                    DropdownMenuItem(value: 8, child: Text('8')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _digits = value);
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                // Period input
                TextFormField(
                  initialValue: _period.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Period (seconds)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final period = int.tryParse(value);
                    if (period != null && period > 0) {
                      setState(() => _period = period);
                    }
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
                            onPressed: () => _saveToken(ref),
                            child: const Text('Add'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

