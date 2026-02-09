import 'package:flutter/material.dart';
import 'package:idn_pos/screens/scanner/components/payment_modal.dart';
import 'package:idn_pos/screens/scanner/components/scanner_header.dart';
import 'package:idn_pos/screens/scanner/components/scanner_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // untuk memebuat detection speesdnya gaada delay jadi cepet nangkep fotonya
    returnImage: false
  );

  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAMERA SCANNER
          MobileScanner(
            controller: controller,
            onDetect: (capture) {  // sebuah kondisi dimana kamera sedang mendetect
              if (_isScanned) return;
              // kondisi yang ada do perulangan for, adalah kondisi ketika QRCode sudah berhasil ditangkap oleh kamera
              for (final barcode in capture.barcodes) { // ngedetact barcode yang ada di kamera yang lagi ngescan
                _handleQRCode(barcode.rawValue);
              }
            }, 
          ),

          ScannerOverlay(),
          ScannerHeader(controller: controller),
        ],
      ),
    );
  }

  void _handleQRCode(String? code) {
    if (code != null) {
      if (code.startsWith("PAY:")) { // pokoknya nanti bakal penting banget PAY: ini, soalnya dia bakal jadi kunci biar qrnya bisa ke scan. karena bakal diacari id yang ada tulisan PAY: ini
        // QR code valid
        setState(() {
          _isScanned = true;

          final parts = code.split(":"); //
          final id = parts[1]; // jika sewaktu2 menghasilkan banyak kode dan mengahsilkan lebih dari 1 line, m aka tidak akan bisa. jadi cuma bisa 1 line
          final total = int.tryParse(parts[2]) ?? 0;

          _showPaymentModal(id, total);
        });
      } else {
        // QR code tidak valid
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // untuk menghindari munculnya snackBar 2 kali
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text("QR Tidak Dikenali $code", overflow: TextOverflow.ellipsis))
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(milliseconds: 1000),
          )
        );
      }
    }
  }

  // TAMPILKAN MODAL PAYMENT
  void _showPaymentModal(String id, int total) {
    showModalBottomSheet(
      context: context, // unutk mendifinisakn screen/ui yang aktif
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (paymentContext) => PaymentModal(
        id: id,
        total: total,
        onPay: () {
          Navigator.pop(paymentContext);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembayaran Berhasil'), backgroundColor: Colors.green,)
          );
        },
        onCancel: () {
          Navigator.pop(paymentContext);
          setState(() {
            _isScanned = false; // untuk mereset state agar bisa scan lagi dari awal
          });
        },
      )
    ).then((_) {
      if (_isScanned) setState(() => _isScanned = false);
    });
  }
}