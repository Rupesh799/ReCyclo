// seller_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Recyclo/services/firestore_service.dart';

class SellerService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> sendPickupRequest(String buyerId, String wasteDetails) async {
    await _firestoreService.addPickupRequest(buyerId, wasteDetails);
  }
}