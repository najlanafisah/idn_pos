import 'package:flutter/material.dart';
import 'package:idn_pos/utils/currency_format.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrResultMadal extends StatefulWidget {
  final String qrData;
  final int total;
  final bool isPrinting;
  final VoidCallback onClose;

  const QrResultMadal({super.key, required this.qrData, required this.total, required this.isPrinting, required this.onClose});

  @override
  State<QrResultMadal> createState() => _QrResultMadalState();
}

class _QrResultMadalState extends State<QrResultMadal> {
  // variable untuk menyimpan status cetak
  late bool _printFininshed;

  @override
  void initState() {
    super.initState(); // jalur pembuka untuk menginisialisasikan state awal
    // awalnya, anggap proses print belom selesai
    _printFininshed = false;

    // jika mode mencetak/printer nyala, kita buat simulasi loading
    if (widget.isPrinting) {
      Future.delayed(Duration(seconds: 2), () {
        // cek jika proses delay sesuai dengan waktu yang dibutuhkan printer ketika mencetak
        if (mounted) {
          setState(() {
            _printFininshed = true; // ubah status jadi selesai
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // menntukan warna dan teks sesuai status
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    String statusText;

    if (!widget.isPrinting) {
      // kondisi 1: priter mati/mode tanpa printer
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.shade50;
      statusIcon = Icons.print_disabled;
      statusText = 'Mode Tanpa Printer';
    } else if (!_printFininshed) {
      // kondisi 2: ketika sedang proses mencetak struk
      statusColor = Colors.blue;
      statusBgColor = Colors.blue.shade50;
      statusIcon = Icons.print;
      statusText = 'Mencetak Struk Fisik...';
    } else {
      // kondisi 3: ketika sudah selesai mencetak struk
      statusColor = Colors.green;
      statusBgColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
      statusText = 'Cetak selesai';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.65, // untuk mengambil ukuran 65% dari layar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // handle bar
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          SizedBox(height: 20),
          // status mode
          AnimatedContainer(
            duration: Duration(milliseconds: 300), //unutk memeberikan eferk animasi halus
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 20, color: statusColor),
                SizedBox(width: 10),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'SCAN UNTUK MEMBAYAR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2E3192)
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Total: ${formatRupiah(widget.total)}', // ini nanti bakal jadi total
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 20),
          // QR code container
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 15
                )
              ]
            ),
            child: QrImageView(
              data: widget.qrData,
              version: QrVersions.auto,
              size: 220.0,
            ),
          ),
          Spacer(),
          //close button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black
              ),
              onPressed: widget.onClose,
              child: Text('Tutup'),
            ),
          )
        ],
      ),
    );
  }
}