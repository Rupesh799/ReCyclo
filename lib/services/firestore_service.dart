// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPickupRequest(String buyerId, String wasteDetails) async {
    await _firestore.collection('pickupRequests').add({
      'buyerId': buyerId,
      'wasteDetails': wasteDetails,
      'status': 'pending',
    });
  }

  Stream<QuerySnapshot> getPickupRequests(String buyerId) {
    return _firestore
        .collection('pickupRequests')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots();
  }

  Future<void> updateTransactionStatus(String requestId, String status) async {
    await _firestore
        .collection('pickupRequests')
        .doc(requestId)
        .update({'status': status});
  }
}