import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Recyclo/screens/basic/buyer_home.dart';
import 'package:Recyclo/screens/basic/seller_home.dart';

enum UserType { Seller, Buyer }

class Login extends StatefulWidget {
  final Function? toggleView;

  const Login({Key? key, this.toggleView}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isShowPassword = true;

  // final AuthService _auth = AuthService();
  UserType selectedUserType = UserType.Seller;

  String email = "", password = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc;

      // Check the selected user type and retrieve user information accordingly
      if (selectedUserType == UserType.Seller) {
        userDoc = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(userCredential.user?.uid)
            .get();
      } else {
        userDoc = await FirebaseFirestore.instance
            .collection('buyers')
            .doc(userCredential.user?.uid)
            .get();
      }

      // Check if the user document exists and contains the 'userType' field
      if (userDoc.exists) {
        String? userType = userDoc.get('userType');

        // Check if the user's role matches the selected role
        if ((selectedUserType == UserType.Seller && userType == 'Seller') ||
            (selectedUserType == UserType.Buyer && userType == 'Buyer')) {
          if (selectedUserType == UserType.Buyer) {
            // If the user is a buyer, navigate to BuyerHome and exit the app
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BuyerHome()),
              
            );
          } else {
            // If the user is a seller, navigate to Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          }
          // Navigate to the appropriate home screen based on the user's role
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => selectedUserType == UserType.Seller
          //         ? const Home()
          //         : const BuyerHome(),
          //   ),
          //   (route) => false,
          // );
          return;
        }
      }

      // Handle cases where the document or field is null or the role doesn't match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid user role for login"),
          backgroundColor: Color.fromARGB(255, 8, 149, 128),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("No user found for that email"),
            backgroundColor: Color.fromARGB(255, 8, 149, 128)));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Wrong Password"),
            backgroundColor: Color.fromARGB(255, 8, 149, 128)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Image.asset(
                    "assets/images/Recyclo.png",
                    fit: BoxFit.contain,
                    width: 300,
                    height: 280,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: emailController,
                    autofocus: false,
                    validator: (value) {
                      if (value != null) {
                        if (value.contains('@') && value.endsWith('.com')) {
                          return null;
                        }
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !isShowPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(
                        Icons.password_outlined,
                        color: Color.fromARGB(255, 8, 149, 128),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isShowPassword = !isShowPassword;
                          });
                        },
                        icon: Icon(
                          isShowPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color.fromARGB(255, 8, 149, 128),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: UserType.Seller,
                      groupValue: selectedUserType,
                      onChanged: (UserType? value) {
                        if (value != null) {
                          setState(() {
                            selectedUserType = value;
                          });
                        }
                      },
                    ),
                    const Text('Seller'),
                    Radio(
                      value: UserType.Buyer,
                      groupValue: selectedUserType,
                      onChanged: (UserType? value) {
                        if (value != null) {
                          setState(() {
                            selectedUserType = value;
                          });
                        }
                      },
                    ),
                    const Text('Buyer'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        email = emailController.text;
                        password = passwordController.text;
                      });

                      // Call the login function
                      await userLogin();
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text("Didn't Have an Account?"),
                const SizedBox(
                  height: 12,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'signup_screen');
                  },
                  child: const Text(
                    "Create an Account.",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
