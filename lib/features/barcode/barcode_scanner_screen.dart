import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Barcode scanner screen
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});
  
  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_hasScanned) return;
    
    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;
    
    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    
    if (rawValue != null && mounted) {
      setState(() => _hasScanned = true);
      copyToClipboard(rawValue, context, successMessage: 'Barcode copied');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _hasScanned = false);
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          // Overlay
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _hasScanned ? 'Barcode copied!' : 'Position barcode within the frame',
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
    
    final scanAreaWidth = size.width * 0.8;
    final scanAreaHeight = size.height * 0.3;
    final scanAreaLeft = (size.width - scanAreaWidth) / 2;
    final scanAreaTop = (size.height - scanAreaHeight) / 2;
    
    final scanArea = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            scanAreaLeft,
            scanAreaTop,
            scanAreaWidth,
            scanAreaHeight,
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
      Offset(scanAreaLeft + scanAreaWidth - cornerLength, scanAreaTop),
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop),
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaHeight - cornerLength),
      Offset(scanAreaLeft, scanAreaTop + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaHeight),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaHeight),
      cornerPaint,
    );
    
    // Bottom-right
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth - cornerLength, scanAreaTop + scanAreaHeight),
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight - cornerLength),
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight),
      cornerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

