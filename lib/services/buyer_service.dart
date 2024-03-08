// buyer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Recyclo/services/firestore_service.dart';

class BuyerService {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<QuerySnapshot> getPickupRequestsStream(String buyerId) {
    return _firestoreService.getPickupRequests(buyerId);
  }

  Future<void> acceptPickupRequest(String requestId) async {
    await _firestoreService.updateTransactionStatus(requestId, 'accepted');
  }

  Future<void> rejectPickupRequest(String requestId) async {
    await _firestoreService.updateTransactionStatus(requestId, 'rejected');
  }
}
