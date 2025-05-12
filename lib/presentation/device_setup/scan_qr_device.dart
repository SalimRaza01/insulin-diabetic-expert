// import 'package:INSUL/core/services/bluetooth_service_provider.dart';
// import 'package:INSUL/core/utils/sharedpref_utils.dart';
// import 'package:INSUL/data/providers/device_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:provider/provider.dart';

// class QrScanner extends StatefulWidget {
//   const QrScanner({super.key});

//   @override
//   State<QrScanner> createState() => _QrScannerState();
// }

// class _QrScannerState extends State<QrScanner> {
//   bool isQRScanning = false;
//   final prefs = SharedPrefsHelper();





//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: isQRScanning
//           ? Stack(
//               children: [
               
//                 Positioned(
//                   top: 40,
//                   left: 16,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: _stopScanner,
//                   ),
//                 ),
//               ],
//             )
//           : SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Center(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 60),
//                       const Icon(Icons.bluetooth_searching,
//                           size: 100, color: Colors.blueAccent),
//                       const SizedBox(height: 30),
//                       const Text(
//                         "Let’s Connect Your Device",
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Scan your BLE device QR code to start setup",
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                         textAlign: TextAlign.center,
//                       ),
//                       const Spacer(),
//                       ElevatedButton.icon(
//                         onPressed: _startScanner,
//                         icon: const Icon(Icons.qr_code_scanner),
//                         label: const Text("Scan QR Code"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueAccent,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 32, vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
