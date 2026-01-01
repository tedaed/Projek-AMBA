import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print("⚠️ ScanController disabled");
  }

  @override
  void dispose() {
    super.dispose();
  }

  var isCameraInitialized = false.obs;
  var x, y, w, h = 0.0;
  var label = "";

  // Fungsi kosong supaya tidak error
  void navigateToCerita(BuildContext context, String label) {
    print("🚫 Scan feature temporarily disabled");
  }
}
