import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

/// QR Code scanner screen
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  
  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }
  
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isCheckingPermission = false;
      });
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
        _isCheckingPermission = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_hasScanned || !mounted) return;
    
    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;
    
    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    
    if (rawValue != null && rawValue.trim().isNotEmpty) {
      // Check if it's an otpauth URI
      if (rawValue.startsWith('otpauth://')) {
        setState(() => _hasScanned = true);
        _controller.stop();
        Navigator.pop(context, rawValue);
      } else {
        // Show error for non-otpauth QR codes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code. Please scan an authenticator QR code.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Camera Permission Required',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please grant camera permission to scan QR codes.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await openAppSettings();
                    _checkCameraPermission();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _controller.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          // Overlay with scanning area
          CustomPaint(
            painter: _ScannerOverlay(),
            child: Container(),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary.withOpacity(0.9),
                  borderRadius: BorderRadius.zero, // Sharp corners
                ),
                child: Text(
                  _hasScanned ? 'QR code scanned!' : 'Position QR code within the frame',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scanner overlay painter
class _ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;
    
    final scanArea = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            scanAreaLeft,
            scanAreaTop,
            scanAreaSize,
            scanAreaSize,
          ),
          const Radius.circular(12),
        ),
      );
    
    final clipPath = Path.combine(
      PathOperation.difference,
      path,
      scanArea,
    );
    
    canvas.drawPath(clipPath, paint);
    
    // Draw corner markers
    final cornerPaint = Paint()
      ..color = AppTheme.accentPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    
    final cornerLength = 30.0;
    
    // Top-left
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      Offset(scanAreaLeft, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );
    
    // Top-right
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    
    // Bottom-right
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize - cornerLength),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

