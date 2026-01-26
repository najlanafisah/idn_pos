import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack( // stack adalah tumpukan widget
      // OVERLAY GELAP TRANSPARANT
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.8),
            BlendMode.srcOut
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut
                ),
              ),
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                ),
              )
            ],
          ),
        ),

        // GARIS NEON DNA TEKS PETUNJUK
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyan, width: 2),
              borderRadius: BorderRadius.circular(20),
              boxShadow:[
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5 // untuk memberikan efek spreading
                )
              ]
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Arahkan ke QR struk",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8)
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}