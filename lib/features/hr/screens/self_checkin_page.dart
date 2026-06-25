import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hr_provider.dart';

import 'package:go_router/go_router.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SelfCheckinPage extends ConsumerStatefulWidget {
  const SelfCheckinPage({super.key});

  @override
  ConsumerState<SelfCheckinPage> createState() => _SelfCheckinPageState();
}

class _SelfCheckinPageState extends ConsumerState<SelfCheckinPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.startsWith('EMP-')) {
        setState(() => _isProcessing = true);
        final employeeId = code.replaceFirst('EMP-', '');

        final success = await ref.read(hrProvider.notifier).checkIn(employeeId);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-in Successful!'), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-in Failed. Try again.'), backgroundColor: Colors.red),
            );
          }
        }
        
        // Wait a bit before allowing another scan
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isRegisteringFace = (authState.isEmployee == true && authState.faceRegistered == false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRegisteringFace ? 'Register Face Data' : 'Face/ID Scanner Check-in'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _scannerController.switchCamera(),
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: isRegisteringFace ? (_) {} : _onDetect,
          ),
          
          // Overlay to make it look like a face/ID scanner
          Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: isRegisteringFace ? Colors.green : Colors.blue,
                borderWidth: 3,
                overlayColor: Colors.black54,
              ),
            ),
          ),
          
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _isProcessing 
                    ? 'Processing...' 
                    : isRegisteringFace ? 'Position Face to Register' : 'Position Face or ID Card in Frame',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          
          if (isRegisteringFace)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FilledButton.icon(
                  icon: const Icon(Icons.face),
                  label: const Text('Capture & Save Face Data'),
                  onPressed: () async {
                    setState(() => _isProcessing = true);
                    // In real app, we capture image and upload to server
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Face Registered Successfully!')));
                      // For demo, just go to dashboard. You'd update the backend too.
                      context.go('/');
                    }
                  },
                ),
              ),
            ),

          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.overlayColor = const Color(0x88000000),
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getClip(Size size) {
      Path path = Path();
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      
      // Face oval or ID card rectangle
      double w = size.width * 0.7;
      double h = size.height * 0.5;
      double x = (size.width - w) / 2;
      double y = (size.height - h) / 2;
      
      path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(20)));
      path.fillType = PathFillType.evenOdd;
      return path;
    }
    return _getClip(rect.size);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(getOuterPath(rect), paint);
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
      
    double w = rect.width * 0.7;
    double h = rect.height * 0.5;
    double x = (rect.width - w) / 2;
    double y = (rect.height - h) / 2;
    
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(20)), borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}
