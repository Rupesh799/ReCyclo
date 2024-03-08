import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:Recyclo/screens/basic/seller_home.dart';
import 'package:Recyclo/screens/basic/welcome.dart';

import 'exceptions/login_failure.dart';
import 'exceptions/registration_failure.dart';
// import 'exceptions/signup_email_password_failure.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  //Variables
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  //Will be load when app launches this func will be called and set the firebaseUser state
  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  /// If we are setting initial screen from here
  /// then in the main.dart => App() add CircularProgressIndicator()
  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() => const Welcome())
        : Get.offAll(() => const Home());
  }

  //FUNC
  Future<String?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      firebaseUser.value != null ? Get.to(() => const Home()) : Get.to(() => const Welcome());
       
    } on FirebaseAuthException catch (e) {
      final ex = RegistrationFailure.code(e.code);
      return ex.message;
    } catch (_) {
      const ex = RegistrationFailure();
      // print('EXCEPTION - ${ex.message}');
      return ex.message;
    }
    return null;
  }

  Future<String?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final ex = LoginFailure.fromCode(e.code);
      return ex.message;
    } catch (_) {
      // const ex = LogInWithEmailAndPasswordFailure();
      // return ex.message;
    }
    return null;
  }

  Future<void> logout() async => await _auth.signOut();
}
