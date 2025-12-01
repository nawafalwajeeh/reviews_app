// controllers/barcode_scanner_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../localization/app_localizations.dart';
import '../models/place_model.dart';

class BarcodeScannerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Reactive state for UI (optional)
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<PlaceModel> fetchPlaceById(String placeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final placesRef = _firestore.collection('Places');
      
      // METHOD 1: Direct document access
      var doc = await placesRef.doc(placeId).get();
      if (doc.exists && doc.data() != null) {
        return PlaceModel.fromSnapshot(doc);
      }

      // METHOD 2: Query by uniqueBarcode
      final uniqueBarcodeQuery = await placesRef
          .where('UniqueBarcode', isEqualTo: 'QR_$placeId')
          .limit(1)
          .get();
      
      if (uniqueBarcodeQuery.docs.isNotEmpty) {
        return PlaceModel.fromSnapshot(uniqueBarcodeQuery.docs.first);
      }
      throw Exception(txt.placeNotFound);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}