import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:idn_pos/models/products.dart';
import 'package:idn_pos/screens/cashier/components/checkout_panel.dart';
import 'package:idn_pos/screens/cashier/components/printer_selector.dart';
import 'package:idn_pos/screens/cashier/components/product_card.dart';
import 'package:idn_pos/screens/cashier/components/qr_result_madal.dart';
import 'package:idn_pos/utils/currency_format.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;
  final Map<Product, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  // LOGIKA BLUETOOTH //
  Future<void> _initBluetooth() async {
    // minta izin ke lokasi & bluetooth (WAJIB)
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();

    List<BluetoothDevice> devices = [
      // list ini akan terisi otomatis, jika bt  di hp nyala dan sudah ada device yang siap di koneksikan
    ];
    try {
      devices = await bluetooth.getBondedDevices(); // jika ada koneksi yang siap di koneksikan
    } catch (e) {
      debugPrint('Error Bluetooth $e');
    }

    if (mounted) {
      setState(() {
        _devices = devices; // ini adalah state dari perubahan state
      });
    }

    bluetooth.onStateChanged().listen((state) { // biar hp mendengarkan apa yang terjadi pada bt
      if (mounted) {
        setState(() {
          _connected = state == BlueThermalPrinter.CONNECTED; // ini kalo misalkan btnya aktif, maka statusnya bakal berubah jadi connect
        });
      }
    });
  } 

    void _connectToDevice(BluetoothDevice? device) {
    // kalo list device ada di hp (ada device bluetoothnya)
    // nested if mirip sama widget tree (secara konsep)
    if (device != null) { // ibaratnya ini nenek
      // cek apakah device sudah terhubung
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == false) { // ini mama
          // jika tidak terhubung, tampilkan pesan error
          bluetooth.connect(device).catchError((error) {
            if (mounted) setState(() => _connected = false); // ini anak (karena nurut sama mama)
          });
          // simpan device yang terhubung
        if (mounted) setState(() => _selectedDevice = device); // ini bude (karena dia setara sama mama, tapi punya opini sendiri)
        }
      });
    }
  }

  // LOGIKA CART //
  void _addToCart(Product product) {
    setState(() {
      _cart.update(
        product, // unutk mendefinisikan produk yang ada di menu
        (value) => value + 1, // logika matematis yg dijalankan ketika user udh memilih 1 item ke keranjang, tapi nambahin jumlahnya, jadi bakal nambah lagi
        ifAbsent: () => 1);  // jika user tidak menambah lagi jumlah product (jumlah hanya 1) di keranjan, maka default jumlah dari barang tsb adalah 1
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cart.containsKey(product) && _cart[product] ! > 1) { // ini ada 2 kondisi dalam 1 if (operator AND)
        _cart[product] = _cart[product]! - 1; // INI PENTING! [perbedaan bank operator dan NOT, fungsi dan penempatannya beda walau simbolnya sama "!". kalo bank itu wajib, kalo NOT adalah kebalikan/negasi]
      } else {
        _cart.remove(product); // ini untuk dijalankan kalau misalkan codingannya ada error
      }
    });
  }

  int _calculateTotal() {
    int total = 0;
    _cart.forEach((key, value) => total += (key.price * value));
    return total;
  }

  // LOGIKA PRINTING //
  void _handlePrint() async {
    int total = _calculateTotal();
    if (total == 0) {
      ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Keranjang masih kosong!')));
    }

    String trxId = "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    String qrData = "PAY:$trxId:$total"; // untuk QR data
    bool isPrinting = false;

    // menyiapkan tanggal saat ini (current date)
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    
    // LAYOUTING STRUK
    if (_selectedDevice != null && await bluetooth.isConnected == true) {
      // header struk
      bluetooth.printNewLine(); // unutk ngasih enter
      bluetooth.printCustom("IDN CAFE", 3, 1); // judul besar (center)
      bluetooth.printNewLine();
      bluetooth.printCustom("Jl. Bagus Dayeuh", 1, 1);

      // tanggal & id
      bluetooth.printNewLine();
      bluetooth.printLeftRight("Waktu:", formattedDate, 1);

      // daftar items
      bluetooth.printCustom("--------------------------------", 1, 1);
      _cart.forEach((product, qty) {
        String priceTotal = formatRupiah(product.price * qty);
        // cetak nama barnag x qty
        bluetooth.printLeftRight("${product.name} x${qty}", priceTotal, 1);
      });
      bluetooth.printCustom("--------------------------------", 1, 1);

      // total dan QR
      bluetooth.printLeftRight("TOTAL", formatRupiah(total), 3);
      bluetooth.printNewLine();
      bluetooth.printCustom("Scan QR Dibawah:", 1, 1);
      bluetooth.printQRcode(qrData, 300, 300, 1); // ini nanti ganti jadi kotak ya
      bluetooth.printNewLine();
      bluetooth.printCustom("Makasi", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      isPrinting = true;
    }
    
    // unutk menampilkan modal hasil qr code yang bentuknya adalah pop up
    _showQrModal(qrData, total, isPrinting);
  }

  void _showQrModal(String qrData, int total, bool isPrinting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrResultMadal(
        qrData: qrData,
        total: total,
        isPrinting: isPrinting,
        onClose: () => Navigator.pop(context),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f7fa),
      appBar: AppBar(
        title: Text(
          "Menu Kasir",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      centerTitle: true,
      ),
      body: Column(
        children: [
          // DROPDOWN SELECT PRINTER
          PrinterSelector(
            devices: _devices, 
            selectedDevice: _selectedDevice,
            isConnected: _connected, 
            onSelected: _connectToDevice
          ),

          // GRID FOR PRODUCT LIST
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // ini biar jumlah grid kesampingnya 2 
                childAspectRatio: 0.8,
                crossAxisSpacing: 15, 
                mainAxisSpacing: 15
              ),
              itemCount: menus.length, // biar ngambil keseluruhan datanya
              itemBuilder: (context, index) {
                final product = menus[index];
                final qty = _cart[product] ?? 0; // defaultnya adalah 0

                // PEMANGGILAN PRODUCT LIST PADA PRODUCT CART
                return ProductCard(
                  product: product, 
                  qty: qty, 
                  onAdd: () => _addToCart(product), 
                  onRemove: () => _removeFromCart(product)
                );
              },
            ),
          ),


          // BOTTOM SHEET PANEL
          CheckoutPanel(
            total: _calculateTotal(), 
            onPressed: _handlePrint
          )
        ],
      ),
    );
  }
}