import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'features/authenticator/authenticator_screen.dart';
import 'features/authenticator/add_token_bottom_sheet.dart';
import 'features/backup_codes/backup_codes_screen.dart';
import 'features/backup_codes/add_backup_code_sheet.dart';
import 'features/calculator/calculator_screen.dart';
import 'features/barcode/barcode_scanner_screen.dart';
import 'utils/expandable_fab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: USafeOneApp(),
    ),
  );
}

/// Main app widget
class USafeOneApp extends StatelessWidget {
  const USafeOneApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uSafe One',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainScreen(),
    );
  }
}

/// Main screen with tab navigation and expandable FAB
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const AuthenticatorScreen(),
    const BackupCodesScreen(),
  ];
  
  final List<String> _titles = [
    'Authenticator',
    'Backup Codes',
  ];
  
  void _showAuthenticatorSheet() {
    // Check if we're already on authenticator screen
    if (_currentIndex == 0) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddTokenBottomSheet(),
      );
    } else {
      // Switch to authenticator tab and show sheet
      setState(() => _currentIndex = 0);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTokenBottomSheet(),
          );
        }
      });
    }
  }
  
  void _showBackupCodesSheet() {
    // Check if we're already on backup codes screen
    if (_currentIndex == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddBackupCodeSheet(),
      );
    } else {
      // Switch to backup codes tab and show sheet
      setState(() => _currentIndex = 1);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddBackupCodeSheet(),
          );
        }
      });
    }
  }
  
  void _showCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalculatorScreen(),
        fullscreenDialog: true,
      ),
    );
  }
  
  void _showBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearBlack,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          border: Border(
            top: BorderSide(color: AppTheme.dividerColor, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.accentColor.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.always,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.security, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.security, color: AppTheme.accentColor),
              label: 'Authenticator',
            ),
            NavigationDestination(
              icon: Icon(Icons.backup, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.backup, color: AppTheme.accentColor),
              label: 'Backup Codes',
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ExpandableFAB(
          options: const [
            FABOption(
              type: FABOptionType.authenticator,
              icon: Icons.security,
              label: 'Add Token',
            ),
            FABOption(
              type: FABOptionType.backupCodes,
              icon: Icons.backup,
              label: 'Add Backup Codes',
            ),
            FABOption(
              type: FABOptionType.calculator,
              icon: Icons.calculate,
              label: 'Calculator',
            ),
            FABOption(
              type: FABOptionType.barcodeScanner,
              icon: Icons.qr_code_scanner,
              label: 'Barcode Scanner',
            ),
          ],
          onAuthenticator: _showAuthenticatorSheet,
          onBackupCodes: _showBackupCodesSheet,
          onCalculator: _showCalculator,
          onBarcodeScanner: _showBarcodeScanner,
        ),
      ),
    );
  }
}

