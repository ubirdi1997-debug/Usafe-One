import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'features/authenticator/authenticator_screen.dart';
import 'features/authenticator/add_token_bottom_sheet.dart';
import 'features/backup_codes/backup_codes_screen.dart';
import 'features/backup_codes/add_backup_code_sheet.dart';
import 'features/notes/notes_screen.dart' show NotesScreen, AddNoteSheet;
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
    const CalculatorScreen(),
    const NotesScreen(),
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
  
  void _showAddNoteSheet() {
    // Check if we're already on notes screen
    if (_currentIndex == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddNoteSheet(),
      );
    } else {
      // Switch to notes tab and show sheet
      setState(() => _currentIndex = 2);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddNoteSheet(),
          );
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo placeholder - you can replace with actual logo asset
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield,
                color: AppTheme.backgroundPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'uSafe One',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.borderColor,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary,
          border: Border(
            top: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Handle calculator navigation
            if (index == 2) {
              // Calculator is already in the stack, just switch
            }
          },
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.shield, color: AppTheme.accentPrimary),
              label: 'Auth',
            ),
            NavigationDestination(
              icon: Icon(Icons.vpn_key, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.vpn_key, color: AppTheme.accentPrimary),
              label: 'Backup',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.calculate, color: AppTheme.accentPrimary),
              label: 'Calculator',
            ),
            NavigationDestination(
              icon: Icon(Icons.description, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.description, color: AppTheme.accentPrimary),
              label: 'Notes',
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
              icon: Icons.qr_code_scanner,
              label: 'Add Authenticator',
            ),
            FABOption(
              type: FABOptionType.backupCodes,
              icon: Icons.vpn_key,
              label: 'Add Backup Code',
            ),
            FABOption(
              type: FABOptionType.secureNotes,
              icon: Icons.description,
              label: 'New Secure Note',
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
          onSecureNotes: _showAddNoteSheet,
          onCalculator: _showCalculator,
          onBarcodeScanner: _showBarcodeScanner,
        ),
      ),
    );
  }
}

