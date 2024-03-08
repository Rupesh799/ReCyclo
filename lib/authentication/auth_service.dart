import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Recyclo/screens/auth_ui/signup.dart';

  // enum UserType { Seller, Buyer }


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> signUpWithEmailAndPassword(
      String email, String password, UserType userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Assign user role to Firestore
      await _assignUserRole(result.user!.uid, userType);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _assignUserRole(String uid, UserType userType) async {
    // Use Firestore to store user roles
    // Example: 'users' collection with 'role' field
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': userType == UserType.Seller ? 'seller' : 'buyer',
    });
  }
}